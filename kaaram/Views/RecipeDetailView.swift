//
//  RecipeDetailView.swift
//  kaaram
//
//  Full recipe detail: hero image, bilingual name, meta chips, actions,
//  sectioned ingredients list, and numbered steps with timer badges.
//
//  Not yet persisted: favorite toggle (Phase 4 wires SwiftData sync).
//  Not yet functional: Start Cooking navigates to a stub until Phase 3.
//

import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe

    // Favorite state is ephemeral until Phase 4 introduces SwiftData
    // sync of user favorites to the CloudKit private database.
    @State private var isFavorited: Bool = false

    // Haptic generators for the favorite toggle.
    private let haptic = UIImpactFeedbackGenerator(style: .soft)

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

    // MARK: - Action row

    private var actionRow: some View {
        HStack(spacing: Spacing.m) {
            Button {
                haptic.impactOccurred()
                isFavorited.toggle()
            } label: {
                Image(systemName: isFavorited ? "heart.fill" : "heart")
                    .font(.title3)
                    .foregroundStyle(isFavorited ? Color.kaaramSpice : .secondary)
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
            .accessibilityLabel(isFavorited ? "Remove from favorites" : "Add to favorites")

            NavigationLink {
                CookingModeStub(recipe: recipe)
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
                    Color.kaaramSpice,
                    in: RoundedRectangle(cornerRadius: Radius.l, style: .continuous)
                )
            }
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

// MARK: - Cooking mode stub

/// Placeholder for Phase 3. Shown so navigation is wired today.
private struct CookingModeStub: View {
    let recipe: Recipe

    var body: some View {
        VStack(spacing: Spacing.l) {
            Image(systemName: "wrench.and.screwdriver")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("Step-by-step cooking mode")
                .font(.kaaramHeadline)
            Text("Coming in Phase 3 — full-screen steps, per-step timers, screen-awake.")
                .font(.kaaramCallout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.l)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.kaaramBackground)
        .navigationTitle(recipe.nameEN)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Previews

#Preview("Palak Paneer") {
    NavigationStack {
        RecipeDetailView(recipe: .palakPaneer)
    }
}

#Preview("Sparse (Pappu)") {
    NavigationStack {
        RecipeDetailView(recipe: .pappu)
    }
}
