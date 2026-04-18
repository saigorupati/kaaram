//
//  FavoriteRecipe.swift
//  kaaram
//
//  One row per favorited recipe, synced to the user's CloudKit private
//  database (→ iCloud across devices signed into the same Apple ID).
//
//  Shape constraints for CloudKit-synced SwiftData models:
//    - every property must have a default value or be optional
//    - no @Attribute(.unique) — dedup happens in application code
//    - relationships must be optional and use inverse explicitly
//
//  Dedup by `slug` is enforced by the toggle call sites (see
//  FavoritesStore / Views that read @Query).
//

import Foundation
import SwiftData

@Model
final class FavoriteRecipe {
    var slug: String = ""
    var favoritedAt: Date = Date()

    init(slug: String, favoritedAt: Date = Date()) {
        self.slug = slug
        self.favoritedAt = favoritedAt
    }
}
