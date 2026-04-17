//
//  kaaramApp.swift
//  kaaram
//
//  App entry point. Builds the repository graph (CloudKit + SwiftData
//  cache) and configures a generous URLCache so image downloads persist
//  to disk across launches.
//

import SwiftData
import SwiftUI

@main
struct kaaramApp: App {
    private let repository: RecipeRepository
    private let modelContainer: ModelContainer?

    init() {
        Self.configureImageCache()
        let (repo, container) = Self.buildRepository()
        self.repository = repo
        self.modelContainer = container
    }

    var body: some Scene {
        WindowGroup {
            ContentView(repository: repository)
        }
    }

    // MARK: - Setup

    /// 50 MB RAM, 500 MB disk. Applies to every URLSession.shared request,
    /// which includes SwiftUI's AsyncImage.
    private static func configureImageCache() {
        URLCache.shared = URLCache(
            memoryCapacity: 50 * 1024 * 1024,
            diskCapacity:  500 * 1024 * 1024,
            diskPath:      "kaaram.images"
        )
    }

    /// Builds a caching repository when SwiftData is available. If the
    /// ModelContainer fails to initialize (corrupt store, upgrade bug,
    /// etc.) falls back to the remote-only repository so the app still
    /// runs online. Better degraded UX than a crash loop.
    private static func buildRepository() -> (RecipeRepository, ModelContainer?) {
        let remote = CloudKitRecipeRepository()

        guard let container = try? ModelContainer(for: CachedRecipe.self) else {
            return (remote, nil)
        }

        let cache = RecipeCache(modelContainer: container)
        let caching = CachingRecipeRepository(remote: remote, cache: cache)
        return (caching, container)
    }
}
