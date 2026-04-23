//
//  RecipeCard.swift
//  kaaram
//
//  Editorial recipe card — striped placeholder or hero image at top,
//  serif recipe name with a sub-label ("Tamarind rice · 30 min"), and
//  a favorite heart badge pinned to the top-right when the recipe is
//  saved. Matches the cards used in Home's "Browse by dish" grid and
//  the horizontal "Weeknight tiffins" carousel.
//

import SwiftUI

struct RecipeCard: View {
    let recipe: Recipe

    /// Override the default hero height (defaults to 140 — the grid size).
    var heroHeight: CGFloat = 140
    var flourish: Bool = true

    @Environment(\.favoriteSlugs) private var favoriteSlugs

    private var isFavorited: Bool {
        favoriteSlugs.contains(recipe.slug)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            hero
                .frame(height: heroHeight)

            VStack(alignment: .leading, spacing: 2) {
                Text(recipe.nameEN)
                    .font(.kaaramHeadline)
                    .tracking(-0.2)
                    .foregroundStyle(Color.kaaramInk)
                    .lineLimit(1)

                Text(subLabel)
                    .font(.system(size: 11.5))
                    .foregroundStyle(Color.kaaramInkMuted)
                    .lineLimit(1)
            }
        }
        .padding(10)
        .background(
            Color.kaaramSurface,
            in: RoundedRectangle(cornerRadius: 14, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.kaaramHairline2, lineWidth: 1)
        )
    }

    // MARK: - Hero

    @ViewBuilder
    private var hero: some View {
        ZStack(alignment: .topTrailing) {
            heroImage
            if isFavorited {
                heartBadge
                    .padding(6)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .animation(.snappy, value: isFavorited)
    }

    @ViewBuilder
    private var heroImage: some View {
        if let url = recipe.heroImageURL {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().aspectRatio(contentMode: .fill)
                default:
                    FoodPlaceholder(label: recipe.nameEN, flourish: flourish, cornerRadius: 10)
                }
            }
        } else {
            FoodPlaceholder(label: recipe.nameEN, flourish: flourish, cornerRadius: 10)
        }
    }

    private var heartBadge: some View {
        Image(systemName: "heart.fill")
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(.white)
            .padding(5)
            .background(Color.kaaramSpice, in: Circle())
            .shadow(color: .black.opacity(0.25), radius: 3, y: 1)
            .accessibilityLabel("Favorited")
    }

    private var subLabel: String {
        var parts: [String] = [recipe.category.displayName]
        if recipe.totalMinutes > 0 {
            parts.append("\(recipe.totalMinutes) min")
        }
        return parts.joined(separator: " · ")
    }
}

#Preview("Grid") {
    ScrollView {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
            ForEach(Recipe.previewSet) { recipe in
                RecipeCard(recipe: recipe, heroHeight: 68, flourish: false)
            }
        }
        .padding()
    }
    .background(Color.kaaramBackground)
    .environment(\.favoriteSlugs, ["palak-paneer", "pulihora"])
}

#Preview("Carousel card") {
    RecipeCard(recipe: .palakPaneer, heroHeight: 140)
        .frame(width: 168)
        .padding()
        .background(Color.kaaramBackground)
}
