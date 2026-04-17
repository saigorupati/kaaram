//
//  RecipeCard.swift
//  kaaram
//
//  Card view for a recipe in lists and the Home grid. Uses a placeholder
//  gradient hero today — Phase 1 will swap in AsyncImage backed by CKAsset.
//

import SwiftUI

/// Placeholder model. Replaced by the real `Recipe` type in Phase 1.
struct RecipeCardModel: Identifiable {
    let id = UUID()
    let nameEN: String
    let nameTE: String
    let romanized: String
    let region: String
    let totalMinutes: Int
    let heroSystemImage: String
}

struct RecipeCard: View {
    let recipe: RecipeCardModel

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            hero

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(recipe.nameEN)
                    .font(.kaaramHeadline)
                Text(recipe.nameTE)
                    .font(.kaaramTelugu)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: Spacing.s) {
                Chip(text: recipe.region, systemImage: "map", style: .curry)
                Chip(text: "\(recipe.totalMinutes) min", systemImage: "clock", style: .turmeric)
            }
        }
        .padding(Spacing.m)
        .background(
            Color.kaaramSurface,
            in: RoundedRectangle(cornerRadius: Radius.xl, style: .continuous)
        )
        .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
    }

    private var hero: some View {
        RoundedRectangle(cornerRadius: Radius.l, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [.kaaramSpice.opacity(0.45), .kaaramTurmeric.opacity(0.55)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay {
                Image(systemName: recipe.heroSystemImage)
                    .font(.system(size: 48, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .frame(height: 140)
    }
}

#Preview {
    ScrollView {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.m) {
            RecipeCard(recipe: .init(
                nameEN: "Pappu", nameTE: "పప్పు", romanized: "pappu",
                region: "Andhra", totalMinutes: 25, heroSystemImage: "bowl.fill"
            ))
            RecipeCard(recipe: .init(
                nameEN: "Pulihora", nameTE: "పులిహోర", romanized: "pulihora",
                region: "South Indian", totalMinutes: 30, heroSystemImage: "leaf.fill"
            ))
        }
        .padding()
    }
    .background(Color.kaaramBackground)
}
