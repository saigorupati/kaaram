//
//  RecipeCard.swift
//  kaaram
//
//  Card view for a recipe. Shows a hero image via AsyncImage when the
//  recipe has one, otherwise a colorful category-based gradient with
//  an SF Symbol. Meta chips for region and cook time.
//

import SwiftUI

struct RecipeCard: View {
    let recipe: Recipe

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

    @ViewBuilder
    private var hero: some View {
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
}
