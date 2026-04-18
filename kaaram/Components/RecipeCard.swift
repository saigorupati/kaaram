//
//  RecipeCard.swift
//  kaaram
//
//  Card view for a recipe. Shows a hero image via AsyncImage when the
//  recipe has one, otherwise a colorful category-based gradient with
//  an SF Symbol. Meta chips for region and cook time. Top-right corner
//  displays a heart badge when the recipe is in the user's favorites
//  (read from @Environment(\.favoriteSlugs)).
//

import SwiftUI

struct RecipeCard: View {
    let recipe: Recipe

    @Environment(\.favoriteSlugs) private var favoriteSlugs

    private var isFavorited: Bool {
        favoriteSlugs.contains(recipe.slug)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            hero

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(recipe.nameEN)
                    .font(.kaaramHeadline)
                    .lineLimit(1)
                if !recipe.nameTE.isEmpty {
                    Text(recipe.nameTE)
                        .font(.kaaramTelugu)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            HStack(spacing: Spacing.xs) {
                Chip(text: recipe.region.shortName, style: .curry, size: .compact)
                if recipe.totalMinutes > 0 {
                    Chip(text: "\(recipe.totalMinutes) min", style: .turmeric, size: .compact)
                }
            }
        }
        .padding(Spacing.m)
        .background(
            Color.kaaramSurface,
            in: RoundedRectangle(cornerRadius: Radius.xl, style: .continuous)
        )
        .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
    }

    // MARK: - Hero

    @ViewBuilder
    private var hero: some View {
        ZStack(alignment: .topTrailing) {
            heroImage

            if isFavorited {
                heartBadge
                    .padding(Spacing.s)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.snappy, value: isFavorited)
    }

    @ViewBuilder
    private var heroImage: some View {
        if let url = recipe.heroImageURL {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    placeholderGradient
                case .empty:
                    placeholderGradient
                        .overlay(ProgressView().tint(.white))
                @unknown default:
                    placeholderGradient
                }
            }
            .frame(height: 140)
            .clipShape(RoundedRectangle(cornerRadius: Radius.l, style: .continuous))
        } else {
            placeholderGradient
                .frame(height: 140)
        }
    }

    private var placeholderGradient: some View {
        RoundedRectangle(cornerRadius: Radius.l, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [.kaaramSpice.opacity(0.45), .kaaramTurmeric.opacity(0.55)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay {
                Image(systemName: Self.symbol(for: recipe.category))
                    .font(.system(size: 48, weight: .semibold))
                    .foregroundStyle(.white)
            }
    }

    private var heartBadge: some View {
        Image(systemName: "heart.fill")
            .font(.caption.weight(.bold))
            .foregroundStyle(.white)
            .padding(6)
            .background(Color.kaaramSpice, in: Circle())
            .shadow(color: .black.opacity(0.25), radius: 4, y: 2)
            .accessibilityLabel("Favorited")
    }

    /// Maps a category to an SF Symbol for the no-image fallback.
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
}

#Preview("Grid") {
    ScrollView {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.m) {
            ForEach(Recipe.previewSet) { recipe in
                RecipeCard(recipe: recipe)
            }
        }
        .padding()
    }
    .background(Color.kaaramBackground)
    // Simulate two recipes being favorited.
    .environment(\.favoriteSlugs, ["palak-paneer", "pulihora"])
}
