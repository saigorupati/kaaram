//
//  RecipeDetailView.swift
//  kaaram
//
//  Placeholder detail screen — Checkpoint 4 replaces this with the
//  full layout (hero, bilingual name, ingredients, steps).
//

import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.l) {
                BilingualName(
                    english:  recipe.nameEN,
                    telugu:   recipe.nameTE,
                    romanized: recipe.nameRomanized
                )

                if !recipe.summary.isEmpty {
                    Text(recipe.summary)
                        .font(.kaaramBody)
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: Spacing.s) {
                    Chip(text: recipe.region.displayName, systemImage: "map", style: .curry)
                    Chip(text: "\(recipe.totalMinutes) min", systemImage: "clock", style: .turmeric)
                    Chip(text: "Serves \(recipe.servings)", systemImage: "person.2", style: .neutral)
                }

                Text("Full detail view coming in Checkpoint 4.")
                    .font(.footnote)
                    .foregroundStyle(.tertiary)
                    .padding(.top, Spacing.xl)
            }
            .padding(Spacing.l)
        }
        .background(Color.kaaramBackground)
        .navigationTitle(recipe.nameEN)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        RecipeDetailView(recipe: .palakPaneer)
    }
}
