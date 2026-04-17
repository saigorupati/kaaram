//
//  CachedRecipe.swift
//  kaaram
//
//  SwiftData mirror of a Recipe — used as the offline cache. Lives in
//  the user's on-device SwiftData store (local-only for now; Phase 4
//  will additionally sync favorites to the CloudKit private DB).
//
//  Conversion back to the pure `Recipe` value type happens in
//  `toRecipe()` so view code never touches SwiftData.
//

import Foundation
import SwiftData

@Model
final class CachedRecipe {
    @Attribute(.unique) var slug: String

    var nameEN: String
    var nameTE: String
    var nameRomanized: String
    var summary: String
    var categoryRaw: String
    var regionRaw: String
    var tags: [String]
    var difficulty: Int
    var totalMinutes: Int
    var servings: Int
    var heroImageURLString: String?
    var thumbnailImageURLString: String?
    var ingredientsJSON: String
    var stepsJSON: String
    var isPublished: Bool
    var publishedAt: Date?
    var schemaVersion: Int
    var cachedAt: Date

    init(from recipe: Recipe) {
        self.slug = recipe.slug
        self.nameEN = recipe.nameEN
        self.nameTE = recipe.nameTE
        self.nameRomanized = recipe.nameRomanized
        self.summary = recipe.summary
        self.categoryRaw = recipe.category.rawValue
        self.regionRaw = recipe.region.rawValue
        self.tags = recipe.tags
        self.difficulty = recipe.difficulty
        self.totalMinutes = recipe.totalMinutes
        self.servings = recipe.servings
        self.heroImageURLString = recipe.heroImageURL?.absoluteString
        self.thumbnailImageURLString = recipe.thumbnailImageURL?.absoluteString
        self.ingredientsJSON = Self.encode(recipe.ingredients)
        self.stepsJSON = Self.encode(recipe.steps)
        self.isPublished = recipe.isPublished
        self.publishedAt = recipe.publishedAt
        self.schemaVersion = recipe.schemaVersion
        self.cachedAt = Date()
    }

    /// Convert this cached row back to the pure value type.
    func toRecipe() -> Recipe {
        Recipe(
            nameEN:             nameEN,
            nameTE:             nameTE,
            nameRomanized:      nameRomanized,
            slug:               slug,
            summary:            summary,
            category:           Recipe.Category.from(categoryRaw),
            region:             Recipe.Region.from(regionRaw),
            tags:               tags,
            difficulty:         difficulty,
            totalMinutes:       totalMinutes,
            servings:           servings,
            heroImageURL:       heroImageURLString.flatMap(URL.init),
            thumbnailImageURL:  thumbnailImageURLString.flatMap(URL.init),
            ingredients:        Self.decodeIngredients(ingredientsJSON),
            steps:              Self.decodeSteps(stepsJSON),
            isPublished:        isPublished,
            publishedAt:        publishedAt,
            schemaVersion:      schemaVersion
        )
    }

    // MARK: - JSON helpers

    private static func encode<T: Encodable>(_ value: T) -> String {
        guard
            let data = try? JSONEncoder().encode(value),
            let str = String(data: data, encoding: .utf8)
        else { return "[]" }
        return str
    }

    private static func decodeIngredients(_ json: String) -> [Recipe.Ingredient] {
        guard let data = json.data(using: .utf8) else { return [] }
        return (try? JSONDecoder().decode([Recipe.Ingredient].self, from: data)) ?? []
    }

    private static func decodeSteps(_ json: String) -> [Recipe.Step] {
        guard let data = json.data(using: .utf8) else { return [] }
        return (try? JSONDecoder().decode([Recipe.Step].self, from: data)) ?? []
    }
}
