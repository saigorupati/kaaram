//
//  RecipeRow.swift
//  kaaram
//
//  Horizontal compact row used by the Browse and Favorites tabs.
//  Thumbnail + bilingual name (with inline heart if favorited) +
//  region/time meta + chevron disclosure.
//

import SwiftUI

struct RecipeRow: View {
    let recipe: Recipe

    @Environment(\.favoriteSlugs) private var favoriteSlugs

    private var isFavorited: Bool {
        favoriteSlugs.contains(recipe.slug)
    }

    var body: some View {
        HStack(spacing: Spacing.m) {
            thumbnail

            VStack(alignment: .leading, spacing: Spacing.xs) {
                HStack(spacing: Spacing.xs) {
                    Text(recipe.nameEN)
                        .font(.kaaramHeadline)
                        .lineLimit(1)
                    if isFavorited {
                        Image(systemName: "heart.fill")
                            .font(.caption)
                            .foregroundStyle(Color.kaaramSpice)
                            .transition(.scale.combined(with: .opacity))
                    }
                }

                if !recipe.nameTE.isEmpty {
                    Text(recipe.nameTE)
                        .font(.kaaramTelugu)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                HStack(spacing: Spacing.xs) {
                    Text(recipe.region.displayName)
                    if recipe.totalMinutes > 0 {
                        Text("·")
                        Text("\(recipe.totalMinutes) min")
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.footnote)
                .foregroundStyle(.tertiary)
        }
        .padding(Spacing.m)
        .background(
            Color.kaaramSurface,
            in: RoundedRectangle(cornerRadius: Radius.l, style: .continuous)
        )
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
                    placeholderSquare
                }
            }
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: Radius.m, style: .continuous))
        } else {
            placeholderSquare
                .frame(width: 60, height: 60)
        }
    }

    private var placeholderSquare: some View {
        RoundedRectangle(cornerRadius: Radius.m, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [.kaaramSpice.opacity(0.4), .kaaramTurmeric.opacity(0.5)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay {
                Image(systemName: "fork.knife")
                    .font(.title3)
                    .foregroundStyle(.white)
            }
    }
}

#Preview {
    VStack(spacing: Spacing.m) {
        RecipeRow(recipe: .palakPaneer)
        RecipeRow(recipe: .pappu)
    }
    .padding()
    .background(Color.kaaramBackground)
    .environment(\.favoriteSlugs, ["palak-paneer"])
}
