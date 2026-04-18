//
//  FavoritesView.swift
//  kaaram
//
//  The Favorites tab. Lists recipes the user has hearted, most-recent
//  favorite first. Pulls recipe data from the repository (which is
//  cache-backed so works offline) and intersects with the @Query over
//  FavoriteRecipe to preserve favoritedAt ordering.
//

import SwiftData
import SwiftUI

struct FavoritesView: View {
    let repository: RecipeRepository

    @Environment(\.modelContext) private var modelContext

    @Query(sort: \FavoriteRecipe.favoritedAt, order: .reverse)
    private var favorites: [FavoriteRecipe]

    @State private var allRecipes: [Recipe] = []
    @State private var isLoading: Bool = true
    @State private var errorMessage: String? = nil

    var body: some View {
        NavigationStack {
            content
                .background(Color.kaaramBackground)
                .navigationTitle("Favorites")
                .navigationBarTitleDisplayMode(.large)
                .navigationDestination(for: Recipe.self) { recipe in
                    RecipeDetailView(recipe: recipe)
                }
                .refreshable { await load() }
        }
        .task {
            if allRecipes.isEmpty {
                await load()
            }
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if favorites.isEmpty {
            emptyState
        } else if isLoading && allRecipes.isEmpty {
            loadingState
        } else if let errorMessage, favoriteRecipes.isEmpty {
            errorState(errorMessage)
        } else {
            list
        }
    }

    /// Intersect the live favorites list with the fetched recipe set,
    /// preserving the favoritedAt order from @Query.
    private var favoriteRecipes: [Recipe] {
        let recipeBySlug = Dictionary(
            uniqueKeysWithValues: allRecipes.map { ($0.slug, $0) }
        )
        return favorites.compactMap { recipeBySlug[$0.slug] }
    }

    private var list: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.m) {
                ForEach(favoriteRecipes) { recipe in
                    NavigationLink(value: recipe) {
                        RecipeRow(recipe: recipe)
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button(role: .destructive) {
                            unfavorite(slug: recipe.slug)
                        } label: {
                            Label("Remove from favorites", systemImage: "heart.slash")
                        }
                    }
                }
            }
            .padding(.horizontal, Spacing.l)
            .padding(.top, Spacing.xs)
            .padding(.bottom, Spacing.l)
        }
    }

    private var emptyState: some View {
        VStack(spacing: Spacing.m) {
            Image(systemName: "heart")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("No favorites yet")
                .font(.kaaramHeadline)
            Text("Tap the heart on any recipe to save it here.")
                .font(.kaaramCallout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.xl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var loadingState: some View {
        VStack(spacing: Spacing.m) {
            ProgressView()
            Text("Loading…")
                .font(.kaaramCallout)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func errorState(_ message: String) -> some View {
        VStack(spacing: Spacing.m) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundStyle(Color.kaaramSpice)
            Text("Couldn't load favorites")
                .font(.kaaramHeadline)
            Text(message)
                .font(.kaaramCallout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Try again") {
                Task { await load() }
            }
            .buttonStyle(.borderedProminent)
            .tint(.kaaramSpice)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Actions

    private func load() async {
        isLoading = true
        errorMessage = nil
        do {
            allRecipes = try await repository.fetchPublished()
        } catch let error as RecipeRepositoryError {
            errorMessage = Self.message(for: error)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    private func unfavorite(slug: String) {
        guard let row = favorites.first(where: { $0.slug == slug }) else { return }
        modelContext.delete(row)
        try? modelContext.save()
    }

    private static func message(for error: RecipeRepositoryError) -> String {
        switch error {
        case .notFound:              "Recipe not found."
        case .notSignedIntoICloud:   "Sign in to iCloud in Settings."
        case .networkUnavailable:    "You're offline."
        case .schemaNotDeployed:     "Recipes aren't available yet."
        case .underlying(let msg):   msg
        }
    }
}

// MARK: - Previews

#Preview("With favorites") {
    FavoritesView(repository: MockRecipeRepository())
        .modelContainer(for: [FavoriteRecipe.self, RecipeNote.self, CachedRecipe.self], inMemory: true)
}

#Preview("Empty") {
    FavoritesView(repository: MockRecipeRepository())
        .modelContainer(for: [FavoriteRecipe.self, RecipeNote.self, CachedRecipe.self], inMemory: true)
}
