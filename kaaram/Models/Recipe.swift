//
//  Recipe.swift
//  kaaram
//
//  Domain model for a recipe. Mirrors the CloudKit `Recipe` record type
//  defined in scripts/cloudkit-schema.ckdb, but intentionally decoupled —
//  view code should never import CloudKit.
//

import Foundation

struct Recipe: Identifiable, Hashable, Sendable {
    /// Stable app-level id = the recipe's `slug`. CloudKit's `recordName`
    /// is not exposed to the UI layer.
    var id: String { slug }

    // Names
    let nameEN: String
    let nameTE: String
    let nameRomanized: String
    let slug: String

    // Description & classification
    let summary: String
    let category: Category
    let region: Region
    let tags: [String]

    // Meta
    let difficulty: Int          // 1...3
    let totalMinutes: Int
    let servings: Int

    // Images (URLs resolved from CKAsset in the repository layer)
    let heroImageURL: URL?
    let thumbnailImageURL: URL?

    // Content
    let ingredients: [Ingredient]
    let steps: [Step]

    // Publishing
    let isPublished: Bool
    let publishedAt: Date?
    let schemaVersion: Int
}

// MARK: - Ingredient

extension Recipe {
    struct Ingredient: Hashable, Sendable, Codable {
        /// Optional grouping header, e.g. "For the paste". Multiple ingredients
        /// in a row may share the same section.
        let section: String?
        let qty: String?            // "1", "1/2", "400-500"
        let unit: String?           // "cup", "g", "tsp", nil for unitless
        let item: String
        let notes: String?          // "optional", "more if needed"
    }
}

// MARK: - Step

extension Recipe {
    struct Step: Hashable, Sendable, Codable {
        let text: String
        /// Optional timer for this step. Phase 3 cooking mode uses this.
        let durationSec: Int?
    }
}

// MARK: - Category

extension Recipe {
    enum Category: String, CaseIterable, Hashable, Sendable, Codable {
        case breakfast
        case curry
        case pickle
        case sweet
        case festive
        case tiffin
        case rice
        case chutney
        case snack
        case other

        /// Human-readable label for UI.
        var displayName: String {
            switch self {
            case .breakfast: "Breakfast"
            case .curry:     "Curry"
            case .pickle:    "Pickle"
            case .sweet:     "Sweet"
            case .festive:   "Festive"
            case .tiffin:    "Tiffin"
            case .rice:      "Rice"
            case .chutney:   "Chutney"
            case .snack:     "Snack"
            case .other:     "Other"
            }
        }
    }
}

// MARK: - Region

extension Recipe {
    enum Region: String, CaseIterable, Hashable, Sendable, Codable {
        case andhra
        case telangana
        case southIndian  = "south-indian"
        case northIndian  = "north-indian"
        case other

        /// Full label for detail screens and places with room.
        var displayName: String {
            switch self {
            case .andhra:       "Andhra"
            case .telangana:    "Telangana"
            case .southIndian:  "South Indian"
            case .northIndian:  "North Indian"
            case .other:        "Other"
            }
        }

        /// Abbreviated label for narrow contexts (e.g. recipe cards in a grid).
        var shortName: String {
            switch self {
            case .southIndian:  "S. Indian"
            case .northIndian:  "N. Indian"
            default:            displayName
            }
        }
    }
}

// MARK: - Resilient enum decoding

extension Recipe.Category {
    /// Case-insensitive decode with a fallback to `.other` so an unknown value
    /// from CloudKit doesn't crash the whole fetch.
    static func from(_ raw: String) -> Self {
        Self(rawValue: raw.lowercased()) ?? .other
    }
}

extension Recipe.Region {
    static func from(_ raw: String) -> Self {
        Self(rawValue: raw.lowercased()) ?? .other
    }
}
