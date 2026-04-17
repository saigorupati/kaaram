//
//  BrowseViewModel.swift
//  kaaram
//
//  Drives the Browse tab. Pulls the full recipe list once and filters
//  in-memory as the user types. Server-side search is not needed
//  while the total recipe count is small — the cache already has them
//  all.
//

import Foundation
import Observation

@Observable
@MainActor
final class BrowseViewModel {
    enum State: Equatable {
        case loading
        case loaded
        case error(String)
    }

    private(set) var state: State = .loading
    private(set) var allRecipes: [Recipe] = []

    /// Current search query. Binding target for `.searchable`.
    var searchText: String = ""

    private let repository: RecipeRepository

    init(repository: RecipeRepository) {
        self.repository = repository
    }

    func loadIfNeeded() async {
        if case .loaded = state, !allRecipes.isEmpty { return }
        await load()
    }

    func reload() async {
        await load()
    }

    private func load() async {
        state = .loading
        do {
            let recipes = try await repository.fetchPublished()
            allRecipes = recipes
            state = .loaded
        } catch let error as RecipeRepositoryError {
            state = .error(Self.message(for: error))
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    // MARK: - Filtering

    /// Recipes after applying the current search text. Checkpoint 2
    /// extends this with category / region / tag filters and sort.
    var results: [Recipe] {
        let query = searchText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        guard !query.isEmpty else { return allRecipes }

        return allRecipes.filter { recipe in
            recipe.nameEN.lowercased().contains(query) ||
            recipe.nameRomanized.lowercased().contains(query) ||
            recipe.nameTE.contains(searchText) ||
            recipe.summary.lowercased().contains(query) ||
            recipe.tags.contains { $0.lowercased().contains(query) }
        }
    }

    // MARK: - Error mapping

    private static func message(for error: RecipeRepositoryError) -> String {
        switch error {
        case .notFound:
            "Recipe not found."
        case .notSignedIntoICloud:
            "Sign in to iCloud in Settings to load recipes."
        case .networkUnavailable:
            "You're offline. Connect and try again."
        case .schemaNotDeployed:
            "Recipes aren't available yet. Please try again later."
        case .underlying(let msg):
            "Something went wrong.\n\(msg)"
        }
    }
}
