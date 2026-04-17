//
//  HomeViewModel.swift
//  kaaram
//
//  Drives the Home screen. @Observable + @MainActor so view code can
//  bind to `state` directly without Combine boilerplate.
//

import Foundation
import Observation

@Observable
@MainActor
final class HomeViewModel {
    enum State: Equatable {
        case idle
        case loading
        case loaded([Recipe])
        case empty
        case error(String)
    }

    private(set) var state: State = .idle

    private let repository: RecipeRepository

    init(repository: RecipeRepository) {
        self.repository = repository
    }

    func loadIfNeeded() async {
        if case .loaded = state { return }
        await load()
    }

    func reload() async {
        await load()
    }

    private func load() async {
        state = .loading
        do {
            let recipes = try await repository.fetchPublished()
            state = recipes.isEmpty ? .empty : .loaded(recipes)
        } catch let error as RecipeRepositoryError {
            state = .error(Self.message(for: error))
        } catch {
            state = .error(error.localizedDescription)
        }
    }

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
