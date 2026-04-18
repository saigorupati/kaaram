//
//  FavoriteSlugsEnvironment.swift
//  kaaram
//
//  SwiftUI environment key carrying the set of favorited recipe slugs.
//  Provided once at the TabView root from a @Query, consumed by leaf
//  views (RecipeCard, BrowseRow) to render a heart badge without each
//  view running its own database query.
//

import SwiftUI

private struct FavoriteSlugsKey: EnvironmentKey {
    static let defaultValue: Set<String> = []
}

extension EnvironmentValues {
    var favoriteSlugs: Set<String> {
        get { self[FavoriteSlugsKey.self] }
        set { self[FavoriteSlugsKey.self] = newValue }
    }
}
