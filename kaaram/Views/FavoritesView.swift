//
//  FavoritesView.swift
//  kaaram
//
//  "Saved" tab — lists recipes the user has bookmarked. Matches the
//  Saved screen from the design: serif title with a subtitle count, a
//  Recipes/Collections/Grocery segmented control (only Recipes wired),
//  a recent-saved list separated by a kolam divider.
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
    @State private var segment: Segment = .recipes

    enum Segment: String, CaseIterable, Identifiable {
        case recipes = "Recipes"
        case collections = "Collections"
        case grocery = "Grocery"
        var id: String { rawValue }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                header
                segmented
                content
            }
            .background(Color.kaaramBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: Recipe.self) { recipe in
                RecipeDetailView(recipe: recipe)
            }
            .refreshable { await load() }
        }
        .task {
            if allRecipes.isEmpty { await load() }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Saved")
                .font(.kaaramDisplay)
                .tracking(-0.8)
                .foregroundStyle(Color.kaaramInk)
            Text(subtitle)
                .font(.system(size: 13))
                .foregroundStyle(Color.kaaramInkMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Spacing.l)
        .padding(.top, Spacing.s)
    }

    private var subtitle: String {
        let count = favoriteRecipes.count
        return "\(count) \(count == 1 ? "recipe" : "recipes")"
    }

    // MARK: - Segmented

    private var segmented: some View {
        HStack(spacing: 0) {
            ForEach(Segment.allCases) { s in
                let isSelected = segment == s
                Button {
                    segment = s
                } label: {
                    Text(s.rawValue)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(isSelected ? Color.kaaramInk : Color.kaaramInkMuted)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            Group {
                                if isSelected {
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .fill(Color.kaaramBackground)
                                        .shadow(color: .black.opacity(0.06), radius: 2, y: 1)
                                }
                            }
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(3)
        .background(Color.kaaramSurface2, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        .padding(.horizontal, Spacing.l)
        .padding(.vertical, Spacing.m)
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        switch segment {
        case .recipes:
            recipesContent
        case .collections:
            comingSoon("Collections")
        case .grocery:
            comingSoon("Grocery lists")
        }
    }

    @ViewBuilder
    private var recipesContent: some View {
        if favorites.isEmpty {
            emptyState
        } else if isLoading && allRecipes.isEmpty {
            loadingState
        } else if let errorMessage, favoriteRecipes.isEmpty {
            errorState(errorMessage)
        } else {
            savedList
        }
    }

    private var favoriteRecipes: [Recipe] {
        let bySlug = Dictionary(uniqueKeysWithValues: allRecipes.map { ($0.slug, $0) })
        return favorites.compactMap { bySlug[$0.slug] }
    }

    private var savedList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.l) {
                Text("Recently saved")
                    .font(.kaaramTitle)
                    .foregroundStyle(Color.kaaramInk)
                    .padding(.top, Spacing.s)

                KolamDivider()

                LazyVStack(spacing: 0) {
                    ForEach(favoriteRecipes) { recipe in
                        NavigationLink(value: recipe) {
                            RecipeRow(recipe: recipe)
                        }
                        .buttonStyle(.plain)
                        .contextMenu {
                            Button(role: .destructive) {
                                unfavorite(slug: recipe.slug)
                            } label: {
                                Label("Remove from saved", systemImage: "bookmark.slash")
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, Spacing.l)
            .padding(.bottom, Spacing.xl)
        }
    }

    private var emptyState: some View {
        VStack(spacing: Spacing.m) {
            Image(systemName: "bookmark")
                .font(.system(size: 40))
                .foregroundStyle(Color.kaaramInkMuted)
            Text("Nothing saved yet")
                .font(.kaaramHeadline)
                .foregroundStyle(Color.kaaramInk)
            Text("Tap the bookmark on any recipe to save it here.")
                .font(.kaaramCallout)
                .foregroundStyle(Color.kaaramInkMuted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.xl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var loadingState: some View {
        VStack(spacing: Spacing.m) {
            ProgressView().tint(Color.kaaramSpice)
            Text("Loading…")
                .font(.kaaramCallout)
                .foregroundStyle(Color.kaaramInkMuted)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func errorState(_ message: String) -> some View {
        VStack(spacing: Spacing.m) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 36))
                .foregroundStyle(Color.kaaramSpice)
            Text("Couldn't load saved recipes")
                .font(.kaaramHeadline)
                .foregroundStyle(Color.kaaramInk)
            Text(message)
                .font(.kaaramCallout)
                .foregroundStyle(Color.kaaramInkMuted)
                .multilineTextAlignment(.center)
            Button {
                Task { await load() }
            } label: {
                Text("Try again")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.kaaramBackground)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .background(Color.kaaramInk, in: Capsule())
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func comingSoon(_ what: String) -> some View {
        VStack(spacing: Spacing.m) {
            Image(systemName: "sparkles")
                .font(.system(size: 36))
                .foregroundStyle(Color.kaaramTurmeric)
            Text("\(what) · coming soon")
                .font(.kaaramHeadline)
                .foregroundStyle(Color.kaaramInk)
            Text("We're still cooking this up.")
                .font(.kaaramCallout)
                .foregroundStyle(Color.kaaramInkMuted)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Data

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

#Preview("With favorites") {
    FavoritesView(repository: MockRecipeRepository())
        .modelContainer(for: [FavoriteRecipe.self, RecipeNote.self, CachedRecipe.self], inMemory: true)
}

#Preview("Empty") {
    FavoritesView(repository: MockRecipeRepository())
        .modelContainer(for: [FavoriteRecipe.self, RecipeNote.self, CachedRecipe.self], inMemory: true)
}
