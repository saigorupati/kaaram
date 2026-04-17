//
//  RecipeRepository.swift
//  kaaram
//
//  Protocol for fetching recipes. The view layer depends only on this
//  protocol — swap CloudKit for a mock in previews, or cache in Phase 5.
//

import Foundation

protocol RecipeRepository: Sendable {
    /// All published recipes, newest first.
    /// Pagination is a Phase 2 concern — v1 fetches everything.
    func fetchPublished() async throws -> [Recipe]

    /// A single recipe by slug. Throws `.notFound` if missing.
    func fetchRecipe(slug: String) async throws -> Recipe
}

enum RecipeRepositoryError: Error, Equatable {
    case notFound
    case notSignedIntoICloud
    case networkUnavailable
    case schemaNotDeployed
    case underlying(String)
}
