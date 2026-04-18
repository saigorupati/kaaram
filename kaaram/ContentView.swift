//
//  ContentView.swift
//  kaaram
//
//  App root. Hosts the TabView and fans out the injected repository to
//  the tabs that need it. Also runs a single @Query over FavoriteRecipe
//  and projects the slug set into the environment so leaf views
//  (RecipeCard, BrowseRow) can render heart badges without running
//  their own queries.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    let repository: RecipeRepository

    @Query private var favorites: [FavoriteRecipe]

    init(repository: RecipeRepository = CloudKitRecipeRepository()) {
        self.repository = repository
    }

    private var favoriteSlugs: Set<String> {
        Set(favorites.map(\.slug))
    }

    var body: some View {
        TabView {
            HomeView(repository: repository)
                .tabItem { Label("Home", systemImage: "house.fill") }

            BrowseView(repository: repository)
                .tabItem { Label("Browse", systemImage: "magnifyingglass") }
        }
        .tint(.kaaramSpice)
        .environment(\.favoriteSlugs, favoriteSlugs)
    }
}

#Preview("Loaded") {
    ContentView(repository: MockRecipeRepository())
        .modelContainer(for: [FavoriteRecipe.self, RecipeNote.self, CachedRecipe.self], inMemory: true)
}

#Preview("Empty") {
    ContentView(repository: MockRecipeRepository(recipes: []))
        .modelContainer(for: [FavoriteRecipe.self, RecipeNote.self, CachedRecipe.self], inMemory: true)
}
