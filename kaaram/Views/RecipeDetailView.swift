//
//  RecipeDetailView.swift
//  kaaram
//
//  Full recipe detail: hero image, bilingual name, meta chips, actions,
//  sectioned ingredients list, and numbered steps with timer badges.
//
//  Favorite state is persisted via SwiftData (FavoriteRecipe model),
//  synced to the user's CloudKit private database.
//  Start Cooking opens the full-screen step-by-step cooking mode.
//

import SwiftData
import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe

    @Environment(\.modelContext) private var modelContext

    /// Live query for this recipe's favorite row. Either empty or size 1.
    @Query private var matchingFavorites: [FavoriteRecipe]

    /// Live query for this recipe's note. Either empty or size 1.
    @Query private var matchingNotes: [RecipeNote]

    // Full-screen cooking mode presentation.
    @State private var isCookingModeActive: Bool = false

    // Notes editor sheet.
    @State private var isNotesEditorPresented: Bool = false

    // Haptic generators for the favorite toggle.
    private let haptic = UIImpactFeedbackGenerator(style: .soft)

    init(recipe: Recipe) {
        self.recipe = recipe
        let slug = recipe.slug
        _matchingFavorites = Query(
            filter: #Predicate<FavoriteRecipe> { $0.slug == slug }
        )
        _matchingNotes = Query(
            filter: #Predicate<RecipeNote> { $0.slug == slug }
        )
    }

    private var userNote: RecipeNote? { matchingNotes.first }

    private var isFavorited: Bool {
        !matchingFavorites.isEmpty
    }

    private func toggleFavorite() {
        haptic.impactOccurred()
        if let existing = matchingFavorites.first {
            modelContext.delete(existing)
        } else {
            modelContext.insert(FavoriteRecipe(slug: recipe.slug))
        }
        // SwiftData autosaves, but an explicit save lets CloudKit
        // sync fire sooner on device.
        try? modelContext.save()
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                hero
                    .padding(.horizontal, Spacing.l)

                VStack(alignment: .leading, spacing: Spacing.xl) {
                    namesSection
                    metaSection
                    if !recipe.summary.isEmpty {
                        Text(recipe.summary)
                            .font(.kaaramBody)
                            .foregroundStyle(.secondary)
                    }
                    tagsSection
                    actionRow
                    notesSection
                    ingredientsSection
                    stepsSection
                }
                .padding(.horizontal, Spacing.l)
                .padding(.bottom, Spacing.xxl)
            }
            .padding(.top, Spacing.m)
        }
        .background(Color.kaaramBackground)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(recipe.nameEN)
                    .font(.kaaramCallout)
            }
            ToolbarItem(placement: .topBarTrailing) {
                ShareLink(item: shareText) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .fullScreenCover(isPresented: $isCookingModeActive) {
            CookingModeView(recipe: recipe)
        }
        .sheet(isPresented: $isNotesEditorPresented) {
            NoteEditorSheet(slug: recipe.slug)
        }
    }

    // MARK: - Hero

    @ViewBuilder
    private var hero: some View {
        if let url = recipe.heroImageURL {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().aspectRatio(contentMode: .fill)
                case .failure, .empty:
                    placeholderGradient
                @unknown default:
                    placeholderGradient
                }
            }
            .frame(height: 260)
            .clipShape(RoundedRectangle(cornerRadius: Radius.xl, style: .continuous))
        } else {
            placeholderGradient
                .frame(height: 260)
        }
    }

    private var placeholderGradient: some View {
        RoundedRectangle(cornerRadius: Radius.xl, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [.kaaramSpice.opacity(0.5), .kaaramTurmeric.opacity(0.65)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay {
                Image(systemName: Self.symbol(for: recipe.category))
                    .font(.system(size: 96, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.9))
            }
    }

    // MARK: - Name & meta

    private var namesSection: some View {
        BilingualName(
            english:  recipe.nameEN,
            telugu:   recipe.nameTE,
            romanized: recipe.nameRomanized
        )
    }

    private var metaSection: some View {
        HStack(spacing: Spacing.s) {
            Chip(
                text: recipe.region.displayName,
                systemImage: "map",
                style: .curry
            )
            if recipe.totalMinutes > 0 {
                Chip(
                    text: "\(recipe.totalMinutes) min",
                    systemImage: "clock",
                    style: .turmeric
                )
            }
            if recipe.difficulty > 0 {
                Chip(
                    text: Self.difficultyLabel(recipe.difficulty),
                    systemImage: "flame",
                    style: .spice
                )
            }
            if recipe.servings > 0 {
                Chip(
                    text: "Serves \(recipe.servings)",
                    systemImage: "person.2",
                    style: .neutral
                )
            }
        }
    }

    @ViewBuilder
    private var tagsSection: some View {
        if !recipe.tags.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.s) {
                    ForEach(recipe.tags, id: \.self) { tag in
                        Chip(text: tag.capitalized, style: .neutral)
                    }
                }
            }
        }
    }

    // MARK: - Notes

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            SectionHeader(title: "Your notes")

            Button {
                isNotesEditorPresented = true
            } label: {
                noteCard
            }
            .buttonStyle(.plain)
        }
    }

    private var noteCard: some View {
        let body = userNote?.body ?? ""
        let hasNote = !body.isEmpty

        return HStack(alignment: .top, spacing: Spacing.m) {
            if hasNote {
                Text(body)
                    .font(.kaaramBody)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
            } else {
                Text("Tap to add your own notes, tweaks, or memories.")
                    .font(.kaaramCallout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
            }

            Spacer(minLength: Spacing.s)

            Image(systemName: hasNote ? "pencil" : "plus.circle.fill")
                .font(.title3)
                .foregroundStyle(Color.kaaramSpice)
        }
        .padding(Spacing.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            Color.kaaramSurface,
            in: RoundedRectangle(cornerRadius: Radius.l, style: .continuous)
        )
    }

    // MARK: - Action row

    private var actionRow: some View {
        HStack(spacing: Spacing.m) {
            Button {
                toggleFavorite()
            } label: {
                Image(systemName: isFavorited ? "heart.fill" : "heart")
                    .font(.title3)
                    .foregroundStyle(isFavorited ? Color.kaaramSpice : .secondary)
                    .contentTransition(.symbolEffect(.replace))
                    .frame(width: 56, height: 56)
                    .background(
                        Color.kaaramSurface,
                        in: RoundedRectangle(cornerRadius: Radius.l, style: .continuous)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: Radius.l, style: .continuous)
                            .stroke(Color.kaaramSpice.opacity(isFavorited ? 0.5 : 0), lineWidth: 1)
                    )
            }
            .animation(.snappy, value: isFavorited)
            .accessibilityLabel(isFavorited ? "Remove from favorites" : "Add to favorites")

            Button {
                isCookingModeActive = true
            } label: {
                HStack(spacing: Spacing.s) {
                    Image(systemName: "play.fill")
                    Text("Start Cooking")
                }
                .font(.kaaramHeadline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    recipe.steps.isEmpty
                        ? Color.kaaramSpice.opacity(0.4)
                        : Color.kaaramSpice,
                    in: RoundedRectangle(cornerRadius: Radius.l, style: .continuous)
                )
            }
            .disabled(recipe.steps.isEmpty)
            .accessibilityLabel(
                recipe.steps.isEmpty
                    ? "Start Cooking (no steps available)"
                    : "Start Cooking"
            )
        }
    }

    // MARK: - Ingredients

    @ViewBuilder
    private var ingredientsSection: some View {
        if !recipe.ingredients.isEmpty {
            VStack(alignment: .leading, spacing: Spacing.m) {
                SectionHeader(title: "Ingredients")

                let groups = Self.groupedIngredients(recipe.ingredients)
                ForEach(Array(groups.enumerated()), id: \.offset) { _, group in
                    VStack(alignment: .leading, spacing: Spacing.s) {
                        if let section = group.section {
                            Text(section)
                                .font(.kaaramCallout)
                                .foregroundStyle(Color.kaaramSpice)
                                .padding(.top, Spacing.s)
                        }
                        ForEach(Array(group.items.enumerated()), id: \.offset) { _, ingredient in
                            IngredientRow(ingredient: ingredient)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Steps

    @ViewBuilder
    private var stepsSection: some View {
        if !recipe.steps.isEmpty {
            VStack(alignment: .leading, spacing: Spacing.m) {
                SectionHeader(title: "Steps")

                VStack(alignment: .leading, spacing: Spacing.l) {
                    ForEach(Array(recipe.steps.enumerated()), id: \.offset) { index, step in
                        StepRow(number: index + 1, step: step)
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private var shareText: String {
        "\(recipe.nameEN) (\(recipe.nameTE))\n\n\(recipe.summary)"
    }

    private static func difficultyLabel(_ level: Int) -> String {
        switch level {
        case 1: "Easy"
        case 2: "Medium"
        case 3: "Involved"
        default: "—"
        }
    }

    private static func symbol(for category: Recipe.Category) -> String {
        switch category {
        case .breakfast: "sunrise.fill"
        case .curry:     "bowl.fill"
        case .pickle:    "leaf.fill"
        case .sweet:     "birthday.cake.fill"
        case .festive:   "sparkles"
        case .tiffin:    "cup.and.saucer.fill"
        case .rice:      "circle.grid.2x2.fill"
        case .chutney:   "drop.fill"
        case .snack:     "takeoutbag.and.cup.and.straw.fill"
        case .other:     "fork.knife"
        }
    }

    // Groups adjacent ingredients that share the same `section` value.
    // Preserves author order. Ingredients with no section become their
    // own untitled group.
    private struct IngredientGroup { let section: String?; let items: [Recipe.Ingredient] }

    private static func groupedIngredients(_ list: [Recipe.Ingredient]) -> [IngredientGroup] {
        var groups: [IngredientGroup] = []
        for ing in list {
            if let last = groups.last, last.section == ing.section {
                groups[groups.count - 1] = IngredientGroup(
                    section: last.section,
                    items: last.items + [ing]
                )
            } else {
                groups.append(IngredientGroup(section: ing.section, items: [ing]))
            }
        }
        return groups
    }
}

// MARK: - Ingredient row

private struct IngredientRow: View {
    let ingredient: Recipe.Ingredient

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.m) {
            Text(quantityText)
                .font(.kaaramCallout)
                .foregroundStyle(Color.kaaramSpice)
                .frame(minWidth: 72, alignment: .leading)

            VStack(alignment: .leading, spacing: 2) {
                Text(ingredient.item)
                    .font(.kaaramBody)
                if let notes = ingredient.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer(minLength: 0)
        }
    }

    private var quantityText: String {
        let qty = ingredient.qty?.trimmingCharacters(in: .whitespaces) ?? ""
        let unit = ingredient.unit?.trimmingCharacters(in: .whitespaces) ?? ""
        if qty.isEmpty && unit.isEmpty { return "—" }
        if unit.isEmpty { return qty }
        if qty.isEmpty { return unit }
        return "\(qty) \(unit)"
    }
}

// MARK: - Step row

private struct StepRow: View {
    let number: Int
    let step: Recipe.Step

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.m) {
            numberBadge

            VStack(alignment: .leading, spacing: Spacing.s) {
                Text(step.text)
                    .font(.kaaramBody)
                    .fixedSize(horizontal: false, vertical: true)

                if let seconds = step.durationSec {
                    HStack(spacing: Spacing.xs) {
                        Image(systemName: "timer")
                        Text(Self.format(seconds: seconds))
                    }
                    .font(.caption)
                    .foregroundStyle(Color.kaaramTurmeric)
                    .padding(.horizontal, Spacing.s)
                    .padding(.vertical, 4)
                    .background(
                        Color.kaaramTurmeric.opacity(0.15),
                        in: Capsule()
                    )
                }
            }
        }
    }

    private var numberBadge: some View {
        Text("\(number)")
            .font(.kaaramHeadline)
            .foregroundStyle(.white)
            .frame(width: 32, height: 32)
            .background(Color.kaaramSpice, in: Circle())
    }

    private static func format(seconds: Int) -> String {
        if seconds < 60 { return "\(seconds)s" }
        let m = seconds / 60
        let s = seconds % 60
        return s == 0 ? "\(m) min" : "\(m)m \(s)s"
    }
}

// MARK: - Previews

#Preview("Palak Paneer") {
    NavigationStack {
        RecipeDetailView(recipe: .palakPaneer)
    }
    .modelContainer(for: [FavoriteRecipe.self, RecipeNote.self, CachedRecipe.self], inMemory: true)
}

#Preview("Sparse (Pappu)") {
    NavigationStack {
        RecipeDetailView(recipe: .pappu)
    }
    .modelContainer(for: [FavoriteRecipe.self, RecipeNote.self, CachedRecipe.self], inMemory: true)
}
