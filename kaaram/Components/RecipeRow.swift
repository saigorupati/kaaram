//
//  RecipeRow.swift
//  kaaram
//
//  Horizontal list row used by Explore, Saved, and Collection screens.
//  Thumbnail · serif name · "Region · time" sub-label · heat dots ·
//  bookmark affordance. No card chrome — the row sits on the canvas and
//  is separated from its neighbors by a hairline.
//

import SwiftUI

struct RecipeRow: View {
    let recipe: Recipe
    var showBookmark: Bool = true

    @Environment(\.favoriteSlugs) private var favoriteSlugs

    private var isFavorited: Bool {
        favoriteSlugs.contains(recipe.slug)
    }

    var body: some View {
        HStack(spacing: 14) {
            thumbnail
                .frame(width: 96, height: 76)

            VStack(alignment: .leading, spacing: 3) {
                Text(recipe.nameEN)
                    .font(.kaaramHeadline)
                    .tracking(-0.2)
                    .foregroundStyle(Color.kaaramInk)
                    .lineLimit(1)

                Text(subLabel)
                    .font(.system(size: 11.5))
                    .foregroundStyle(Color.kaaramInkMuted)
                    .lineLimit(1)

                HStack(spacing: 12) {
                    MetaRow(systemImage: "clock", label: timeLabel)
                    if recipe.difficulty > 0 {
                        HeatDots(level: recipe.difficulty + 1, max: 4, dotHeight: 9)
                    }
                }
                .padding(.top, 3)
            }

            Spacer(minLength: Spacing.s)

            if showBookmark {
                Image(systemName: isFavorited ? "bookmark.fill" : "bookmark")
                    .font(.system(size: 15))
                    .foregroundStyle(isFavorited ? Color.kaaramSpice : Color.kaaramInkMuted)
            }
        }
        .padding(.vertical, 12)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.kaaramHairline2)
                .frame(height: 1)
        }
        .animation(.snappy, value: isFavorited)
    }

    // MARK: - Thumbnail

    @ViewBuilder
    private var thumbnail: some View {
        if let url = recipe.thumbnailImageURL ?? recipe.heroImageURL {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().aspectRatio(contentMode: .fill)
                default:
                    FoodPlaceholder(label: recipe.nameEN, flourish: false, cornerRadius: 12)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        } else {
            FoodPlaceholder(label: recipe.nameEN, flourish: false, cornerRadius: 12)
        }
    }

    private var subLabel: String {
        "\(recipe.category.displayName) · \(recipe.region.shortName)"
    }

    private var timeLabel: String {
        recipe.totalMinutes > 0 ? "\(recipe.totalMinutes) min" : "—"
    }
}

#Preview {
    VStack(spacing: 0) {
        RecipeRow(recipe: .palakPaneer)
        RecipeRow(recipe: .pappu)
        RecipeRow(recipe: .pulihora)
    }
    .padding(.horizontal, Spacing.l)
    .background(Color.kaaramBackground)
    .environment(\.favoriteSlugs, ["palak-paneer"])
}
