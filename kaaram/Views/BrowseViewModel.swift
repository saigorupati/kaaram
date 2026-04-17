//
//  BrowseViewModel.swift
//  kaaram
//
//  Drives the Browse tab. Pulls the full recipe list once and filters
//  in-memory as the user types / picks filters / changes sort.
//
//  Server-side search is unnecessary while the total recipe count is
//  small — the offline cache already has everything.
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

    enum Sort: String, CaseIterable, Identifiable {
        case newest   = "Newest"
        case quickest = "Quickest"
        case easiest  = "Easiest"

        var id: String { rawValue }

        var systemImage: String {
            switch self {
            case .newest:   "sparkles"
            case .quickest: "bolt.fill"
            case .easiest:  "checkmark.seal.fill"
            }
        }
    }

    private(set) var state: State = .loading
    private(set) var allRecipes: [Recipe] = []

    /// Binding target for `.searchable`.
    var searchText: String = ""

    /// nil == "All regions".
    var selectedRegion: Recipe.Region? = nil

    /// nil == "All categories".
    var selectedCategory: Recipe.Category? = nil

    var sort: Sort = .newest

    private let repository: RecipeRepository

    init(repository: RecipeRepository) {
        self.repository = repository
    }

    // MARK: - Load

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

    // MARK: - Filtering + sorting

    /// Computed results after applying search + filters + sort.
    var results: [Recipe] {
        var list = allRecipes

        if let region = selectedRegion {
            list = list.filter { $0.region == region }
        }
        if let category = selectedCategory {
            list = list.filter { $0.category == category }
        }

        let query = searchText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        if !query.isEmpty {
            list = list.filter { recipe in
                recipe.nameEN.lowercased().contains(query) ||
                recipe.nameRomanized.lowercased().contains(query) ||
                recipe.nameTE.contains(searchText) ||
                recipe.summary.lowercased().contains(query) ||
                recipe.tags.contains { $0.lowercased().contains(query) }
            }
        }

        switch sort {
        case .newest:
            list.sort {
                ($0.publishedAt ?? .distantPast) > ($1.publishedAt ?? .distantPast)
            }
        case .quickest:
            // Recipes with 0 (unknown) minutes sink to the bottom.
            list.sort { a, b in
                let lhs = a.totalMinutes == 0 ? Int.max : a.totalMinutes
                let rhs = b.totalMinutes == 0 ? Int.max : b.totalMinutes
                return lhs < rhs
            }
        case .easiest:
            list.sort { $0.difficulty < $1.difficulty }
        }

        return list
    }

    var hasActiveFilters: Bool {
        selectedRegion != nil || selectedCategory != nil
    }

    func clearFilters() {
        selectedRegion = nil
        selectedCategory = nil
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
