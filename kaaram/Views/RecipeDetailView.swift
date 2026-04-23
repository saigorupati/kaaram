//
//  RecipeDetailView.swift
//  kaaram
//
//  Editorial recipe detail. A full-bleed hero pulls up under a rounded
//  content card. MonoCap region/category eyebrow, serif title, then a
//  four-up PREP / COOK / SERVES / HEAT grid sits between two hairlines.
//  Ingredients render with spice-dot avatars; steps are numbered and
//  reveal an inline timer badge when present. A sticky "Start cooking"
//  CTA lives at the bottom. Favorite is a bookmark in the top-right
//  glass chip, not a separate action row.
//

import SwiftData
import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query private var matchingFavorites: [FavoriteRecipe]
    @Query private var matchingNotes: [RecipeNote]

    @State private var isCookingModeActive = false
    @State private var isNotesEditorPresented = false

    private let haptic = UIImpactFeedbackGenerator(style: .soft)

    init(recipe: Recipe) {
        self.recipe = recipe
        let slug = recipe.slug
        _matchingFavorites = Query(filter: #Predicate<FavoriteRecipe> { $0.slug == slug })
        _matchingNotes = Query(filter: #Predicate<RecipeNote> { $0.slug == slug })
    }

    private var isFavorited: Bool { !matchingFavorites.isEmpty }
    private var userNote: RecipeNote? { matchingNotes.first }

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 0) {
                    hero
                    pulledCard
                }
            }
            .ignoresSafeArea(edges: .top)
            .background(Color.kaaramBackground)

            stickyCTA
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
        .overlay(alignment: .top) { floatingHeader }
        .fullScreenCover(isPresented: $isCookingModeActive) {
            CookingModeView(recipe: recipe)
        }
        .sheet(isPresented: $isNotesEditorPresented) {
            NoteEditorSheet(slug: recipe.slug)
        }
    }

    // MARK: - Hero

    private var hero: some View {
        Group {
            if let url = recipe.heroImageURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().aspectRatio(contentMode: .fill)
                    default:
                        FoodPlaceholder(label: recipe.nameEN, note: "overhead", cornerRadius: 0)
                    }
                }
            } else {
                FoodPlaceholder(label: recipe.nameEN, note: "overhead", cornerRadius: 0)
            }
        }
        .frame(height: 380)
        .clipped()
    }

    // MARK: - Floating nav row

    private var floatingHeader: some View {
        HStack {
            glassButton(systemImage: "chevron.left", accessibility: "Back") {
                dismiss()
            }
            Spacer()
            glassButton(
                systemImage: isFavorited ? "bookmark.fill" : "bookmark",
                tint: isFavorited ? .kaaramSpice : .kaaramInk,
                accessibility: isFavorited ? "Remove from saved" : "Save"
            ) {
                toggleFavorite()
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 56)
    }

    private func glassButton(
        systemImage: String,
        tint: Color = .kaaramInk,
        accessibility: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 38, height: 38)
                .background(
                    Circle()
                        .fill(Color.kaaramSurface.opacity(0.82))
                )
                .overlay(
                    Circle().stroke(Color.black.opacity(0.08), lineWidth: 1)
                )
        }
        .accessibilityLabel(accessibility)
    }

    // MARK: - Pulled-up content card

    private var pulledCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: Spacing.l) {
                MonoCap(eyebrow, color: .kaaramSpice)
                    .padding(.top, Spacing.xl)

                Text(recipe.nameEN)
                    .font(.system(size: 32, weight: .medium, design: .serif))
                    .tracking(-0.9)
                    .foregroundStyle(Color.kaaramInk)
                    .fixedSize(horizontal: false, vertical: true)

                if !recipe.summary.isEmpty {
                    Text(recipe.summary)
                        .font(.system(size: 14.5))
                        .foregroundStyle(Color.kaaramInkSoft)
                        .lineSpacing(3)
                }

                metaGrid

                if !recipe.tags.isEmpty {
                    tagsScroll
                }

                notesSection

                if !recipe.ingredients.isEmpty {
                    ingredientsSection
                }

                if !recipe.steps.isEmpty {
                    stepsSection
                }
            }
            .padding(.horizontal, 22)
            .padding(.bottom, 120)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            UnevenRoundedRectangle(
                cornerRadii: .init(
                    topLeading: 28,
                    bottomLeading: 0,
                    bottomTrailing: 0,
                    topTrailing: 28
                )
            )
            .fill(Color.kaaramBackground)
        )
        .offset(y: -28)
    }

    private var eyebrow: String {
        "\(recipe.region.displayName) · \(recipe.category.displayName)"
    }

    // MARK: - Meta grid

    private var metaGrid: some View {
        HStack(spacing: 0) {
            metaCell(label: "PREP", value: prepLabel)
            metaCell(label: "COOK", value: cookLabel)
            metaCell(label: "SERVES", value: recipe.servings > 0 ? "\(recipe.servings)" : "—")
            metaCell(label: "HEAT", value: heatLabel)
        }
        .padding(.vertical, 16)
        .overlay(alignment: .top) {
            Rectangle().fill(Color.kaaramHairline2).frame(height: 1)
        }
        .overlay(alignment: .bottom) {
            Rectangle().fill(Color.kaaramHairline2).frame(height: 1)
        }
    }

    private func metaCell(label: String, value: String) -> some View {
        VStack(spacing: 4) {
            MonoCap(label)
            Text(value)
                .font(.system(size: 16, weight: .medium, design: .serif))
                .foregroundStyle(Color.kaaramInk)
        }
        .frame(maxWidth: .infinity)
    }

    private var prepLabel: String {
        let prep = max(0, recipe.totalMinutes / 3)
        return prep > 0 ? "\(prep) min" : "—"
    }

    private var cookLabel: String {
        let cook = recipe.totalMinutes - max(0, recipe.totalMinutes / 3)
        if cook <= 0 { return "—" }
        if cook >= 60 {
            let h = cook / 60
            let m = cook % 60
            return m == 0 ? "\(h)h" : "\(h)h \(m)m"
        }
        return "\(cook) min"
    }

    private var heatLabel: String {
        // recipe.difficulty is 1–3 in the model; map to 4-dot visual.
        let level = min(4, max(0, recipe.difficulty + 1))
        let filled = String(repeating: "●", count: level)
        let empty = String(repeating: "○", count: max(0, 4 - level))
        return filled + empty
    }

    // MARK: - Tags

    private var tagsScroll: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(recipe.tags, id: \.self) { tag in
                    Chip(text: tag.capitalized)
                }
            }
        }
    }

    // MARK: - Notes

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
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
                    .foregroundStyle(Color.kaaramInk)
                    .multilineTextAlignment(.leading)
            } else {
                Text("Tap to add your own notes, tweaks, or memories.")
                    .font(.kaaramCallout)
                    .foregroundStyle(Color.kaaramInkMuted)
                    .multilineTextAlignment(.leading)
            }

            Spacer(minLength: Spacing.s)

            Image(systemName: hasNote ? "pencil" : "plus")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.kaaramSpice)
        }
        .padding(Spacing.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.kaaramSurface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.kaaramHairline2, lineWidth: 1)
        )
    }

    // MARK: - Ingredients

    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            SectionHeader(
                title: "Ingredients",
                trailing: recipe.servings > 0 ? "\(recipe.servings) SERVINGS" : nil
            )

            let groups = Self.grouped(recipe.ingredients)
            ForEach(Array(groups.enumerated()), id: \.offset) { _, group in
                VStack(alignment: .leading, spacing: 0) {
                    if let section = group.section {
                        MonoCap(section, color: .kaaramSpice)
                            .padding(.top, Spacing.s)
                            .padding(.bottom, 4)
                    }
                    ForEach(Array(group.items.enumerated()), id: \.offset) { _, ing in
                        ingredientRow(ing)
                    }
                }
            }
        }
    }

    private func ingredientRow(_ ing: Recipe.Ingredient) -> some View {
        HStack(alignment: .center, spacing: 12) {
            SpiceDot(label: ing.item, size: 28)
            VStack(alignment: .leading, spacing: 1) {
                Text(ing.item)
                    .font(.system(size: 14.5))
                    .foregroundStyle(Color.kaaramInk)
                if let notes = ing.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.system(size: 11.5))
                        .foregroundStyle(Color.kaaramInkMuted)
                }
            }
            Spacer(minLength: 0)
            Text(quantityText(ing))
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .tracking(0.4)
                .foregroundStyle(Color.kaaramInkMuted)
        }
        .padding(.vertical, 10)
        .overlay(alignment: .bottom) {
            Rectangle().fill(Color.kaaramHairline2).frame(height: 1)
        }
    }

    private func quantityText(_ ing: Recipe.Ingredient) -> String {
        let qty = ing.qty?.trimmingCharacters(in: .whitespaces) ?? ""
        let unit = ing.unit?.trimmingCharacters(in: .whitespaces) ?? ""
        if qty.isEmpty && unit.isEmpty { return "—" }
        if unit.isEmpty { return qty }
        if qty.isEmpty { return unit }
        return "\(qty) \(unit)"
    }

    // MARK: - Steps

    private var stepsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            SectionHeader(title: "Steps")

            VStack(alignment: .leading, spacing: Spacing.l) {
                ForEach(Array(recipe.steps.enumerated()), id: \.offset) { index, step in
                    stepRow(index: index + 1, step: step)
                }
            }
        }
    }

    private func stepRow(index: Int, step: Recipe.Step) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Text(String(format: "%02d", index))
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .tracking(0.5)
                .foregroundStyle(Color.kaaramSpice)
                .frame(width: 34, height: 34)
                .background(Color.kaaramSpiceWash, in: Circle())

            VStack(alignment: .leading, spacing: 6) {
                Text(step.text)
                    .font(.system(size: 14))
                    .foregroundStyle(Color.kaaramInkSoft)
                    .lineSpacing(3)

                if let seconds = step.durationSec {
                    HStack(spacing: 5) {
                        Image(systemName: "timer")
                            .font(.system(size: 10))
                        Text(Self.format(seconds: seconds))
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundStyle(Color.kaaramTurmeric)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.kaaramTurmeric.opacity(0.14), in: Capsule())
                }
            }
        }
    }

    // MARK: - Sticky CTA

    private var stickyCTA: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [Color.kaaramBackground.opacity(0), Color.kaaramBackground],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 24)

            Button {
                isCookingModeActive = true
            } label: {
                HStack(spacing: 10) {
                    Text("Start cooking")
                    Image(systemName: "play.fill")
                        .font(.system(size: 13))
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    recipe.steps.isEmpty ? Color.kaaramSpice.opacity(0.4) : Color.kaaramSpice,
                    in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                )
            }
            .disabled(recipe.steps.isEmpty)
            .padding(.horizontal, 20)
            .padding(.bottom, 26)
            .background(Color.kaaramBackground)
        }
    }

    // MARK: - Helpers

    private func toggleFavorite() {
        haptic.impactOccurred()
        if let existing = matchingFavorites.first {
            modelContext.delete(existing)
        } else {
            modelContext.insert(FavoriteRecipe(slug: recipe.slug))
        }
        try? modelContext.save()
    }

    private static func format(seconds: Int) -> String {
        if seconds < 60 { return "\(seconds)s" }
        let m = seconds / 60
        let s = seconds % 60
        return s == 0 ? "\(m) min" : "\(m)m \(s)s"
    }

    private struct IngredientGroup { let section: String?; let items: [Recipe.Ingredient] }

    private static func grouped(_ list: [Recipe.Ingredient]) -> [IngredientGroup] {
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

#Preview("Palak Paneer") {
    NavigationStack { RecipeDetailView(recipe: .palakPaneer) }
        .modelContainer(for: [FavoriteRecipe.self, RecipeNote.self, CachedRecipe.self, UserPreferences.self], inMemory: true)
}

#Preview("Sparse (Pappu)") {
    NavigationStack { RecipeDetailView(recipe: .pappu) }
        .modelContainer(for: [FavoriteRecipe.self, RecipeNote.self, CachedRecipe.self, UserPreferences.self], inMemory: true)
}
