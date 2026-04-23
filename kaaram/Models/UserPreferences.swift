//
//  UserPreferences.swift
//  kaaram
//
//  Single-row model holding the user's display name, spice tolerance,
//  dietary selections, and favored regions. Synced via the CloudKit
//  private database so preferences follow the Apple ID across devices
//  alongside FavoriteRecipe and RecipeNote.
//
//  Shape constraints (see FavoriteRecipe for context):
//    - every property has a default value so CloudKit mirroring is happy
//    - no unique attribute; the "single row" contract is enforced by
//      application code (ProfileView bootstraps one row if absent and
//      writes into the first row thereafter)
//

import Foundation
import SwiftData

@Model
final class UserPreferences {
    var displayName: String = ""
    /// 1 = Mild, 2 = Medium, 3 = Telangana, 4 = Fiery.
    var spiceLevel: Int = 2
    var diets: [String] = []
    var regions: [String] = []
    var updatedAt: Date = Date()

    init(
        displayName: String = "",
        spiceLevel: Int = 2,
        diets: [String] = [],
        regions: [String] = [],
        updatedAt: Date = Date()
    ) {
        self.displayName = displayName
        self.spiceLevel = spiceLevel
        self.diets = diets
        self.regions = regions
        self.updatedAt = updatedAt
    }
}
