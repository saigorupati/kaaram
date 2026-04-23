//
//  ContentView.swift
//  kaaram
//
//  App root. Hosts the TabView with the four tabs from the design —
//  Home, Explore, Saved, Profile — tinted to the chilli accent.
//  Projects a single Set<String> of favorited slugs into the
//  environment so leaf views can render bookmark badges without each
//  running its own query.
//

import SwiftData
import SwiftUI
import UIKit

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
                .tabItem { Label("Explore", systemImage: "magnifyingglass") }

            FavoritesView(repository: repository)
                .tabItem { Label("Saved", systemImage: "bookmark.fill") }

            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.fill") }
        }
        .tint(Color.kaaramSpice)
        .environment(\.favoriteSlugs, favoriteSlugs)
        .background(Color.kaaramBackground.ignoresSafeArea())
        .onAppear { Self.styleTabBar() }
    }

    /// Lift the tab bar off the cream canvas with a hairline + warm tint.
    private static func styleTabBar() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.kaaramBackground)
        appearance.shadowColor = UIColor(Color.kaaramHairline)

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
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
