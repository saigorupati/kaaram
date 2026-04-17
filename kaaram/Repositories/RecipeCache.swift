//
//  RecipeCache.swift
//  kaaram
//
//  @ModelActor wrapping SwiftData access for CachedRecipe. Ensures all
//  ModelContext reads/writes happen on a dedicated executor, off the
//  main thread. Callers are async.
//

import Foundation
import SwiftData

@ModelActor
actor RecipeCache {

    /// All cached recipes, newest first.
    func fetchAll() throws -> [Recipe] {
        var descriptor = FetchDescriptor<CachedRecipe>()
        descriptor.sortBy = [SortDescriptor(\.publishedAt, order: .reverse)]
        let rows = try modelContext.fetch(descriptor)
        return rows.map { $0.toRecipe() }
    }

    /// Single recipe by slug, or nil if not cached.
    func recipe(slug: String) throws -> Recipe? {
        var descriptor = FetchDescriptor<CachedRecipe>(
            predicate: #Predicate { $0.slug == slug }
        )
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first?.toRecipe()
    }

    /// Replace the entire cache with the given recipes. Simple full-sweep
    /// semantics: delete everything, insert everything. Fine while recipe
    /// count stays small (< a few thousand). Upgrade to upsert when it
    /// matters.
    func replace(with recipes: [Recipe]) throws {
        try modelContext.delete(model: CachedRecipe.self)
        for recipe in recipes {
            modelContext.insert(CachedRecipe(from: recipe))
        }
        try modelContext.save()
    }
}
