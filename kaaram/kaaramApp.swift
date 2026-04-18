//
//  kaaramApp.swift
//  kaaram
//
//  App entry point. Builds the repository graph (CloudKit + SwiftData
//  cache), configures a generous URLCache for image persistence, and
//  stands up a ModelContainer with two configurations:
//    - LocalCache: CachedRecipe, device-only (no CloudKit).
//    - UserData:   FavoriteRecipe + RecipeNote, synced to the user's
//                  CloudKit private database so it follows their Apple
//                  ID across devices.
//

import SwiftData
import SwiftUI

@main
struct kaaramApp: App {
    private let repository: RecipeRepository
    private let modelContainer: ModelContainer

    init() {
        Self.configureImageCache()
        let container = Self.buildModelContainer()
        self.modelContainer = container
        self.repository = Self.buildRepository(using: container)
    }

    var body: some Scene {
        WindowGroup {
            ContentView(repository: repository)
                .modelContainer(modelContainer)
        }
    }

    // MARK: - Image cache

    /// 50 MB RAM, 500 MB disk. Applies to URLSession.shared, including
    /// SwiftUI AsyncImage.
    private static func configureImageCache() {
        URLCache.shared = URLCache(
            memoryCapacity: 50 * 1024 * 1024,
            diskCapacity:  500 * 1024 * 1024,
            diskPath:      "kaaram.images"
        )
    }

    // MARK: - Model container

    /// Two stores in one container:
    ///   - LocalCache (CachedRecipe)         → device-only
    ///   - UserData   (FavoriteRecipe, Note) → CloudKit private DB
    ///
    /// If the real on-disk container fails to boot (rare — usually a
    /// corrupt store or low disk), falls back to an in-memory container
    /// so the app still runs. Favorites won't persist in the fallback,
    /// but nothing crashes.
    private static func buildModelContainer() -> ModelContainer {
        let localConfig = ModelConfiguration(
            "LocalCache",
            schema: Schema([CachedRecipe.self]),
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .none
        )

        let userDataConfig = ModelConfiguration(
            "UserData",
            schema: Schema([FavoriteRecipe.self, RecipeNote.self]),
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .private("iCloud.com.saigorupati.kaaram")
        )

        if let container = try? ModelContainer(
            for: CachedRecipe.self, FavoriteRecipe.self, RecipeNote.self,
            configurations: localConfig, userDataConfig
        ) {
            return container
        }

        // Fallback: in-memory, no CloudKit. Guarantees @Query works.
        let fallback = ModelConfiguration(isStoredInMemoryOnly: true)
        // swiftlint:disable:next force_try
        return try! ModelContainer(
            for: CachedRecipe.self, FavoriteRecipe.self, RecipeNote.self,
            configurations: fallback
        )
    }

    // MARK: - Repository

    private static func buildRepository(using container: ModelContainer) -> RecipeRepository {
        let remote = CloudKitRecipeRepository()
        let cache = RecipeCache(modelContainer: container)
        return CachingRecipeRepository(remote: remote, cache: cache)
    }
}
