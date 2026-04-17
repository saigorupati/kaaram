//
//  ContentView.swift
//  kaaram
//
//  App root. Hosts the TabView and fans out the injected repository
//  to the tabs that need it. Phase 4 adds a Favorites tab; Phase 6
//  adds a More/Settings tab.
//

import SwiftUI

struct ContentView: View {
    let repository: RecipeRepository

    init(repository: RecipeRepository = CloudKitRecipeRepository()) {
        self.repository = repository
    }

    var body: some View {
        TabView {
            HomeView(repository: repository)
                .tabItem { Label("Home", systemImage: "house.fill") }

            BrowseView(repository: repository)
                .tabItem { Label("Browse", systemImage: "magnifyingglass") }
        }
        .tint(.kaaramSpice)
    }
}

#Preview("Loaded") {
    ContentView(repository: MockRecipeRepository())
}

#Preview("Empty") {
    ContentView(repository: MockRecipeRepository(recipes: []))
}
