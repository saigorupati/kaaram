//
//  CachingRecipeRepository.swift
//  kaaram
//
//  Wraps a remote RecipeRepository with an on-device cache.
//
//  Strategy (simple, network-first):
//    1. Ask the remote.
//    2. On success, replace the cache and return the fresh data.
//    3. On failure, return whatever's in the cache. If cache is empty,
//       rethrow the remote's error so the UI can show a real error.
//
//  This is intentionally NOT stale-while-revalidate — v1 keeps the logic
//  obvious, and the UI shows a single deterministic state. Phase 5+ can
//  layer SWR on top if warranted.
//

import Foundation
import OSLog

private let log = Logger(subsystem: "com.saigorupati.kaaram", category: "CachingRepo")

struct CachingRecipeRepository: RecipeRepository {
    let remote: RecipeRepository
    let cache: RecipeCache

    func fetchPublished() async throws -> [Recipe] {
        do {
            let fresh = try await remote.fetchPublished()
            try? await cache.replace(with: fresh)
            return fresh
        } catch {
            log.info("Remote fetch failed; falling back to cache. \(error.localizedDescription)")
            let cached = (try? await cache.fetchAll()) ?? []
            if cached.isEmpty { throw error }
            return cached
        }
    }

    func fetchRecipe(slug: String) async throws -> Recipe {
        do {
            return try await remote.fetchRecipe(slug: slug)
        } catch {
            if let cached = try? await cache.recipe(slug: slug) {
                return cached
            }
            throw error
        }
    }
}
