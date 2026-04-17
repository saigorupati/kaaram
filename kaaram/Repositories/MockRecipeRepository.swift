//
//  MockRecipeRepository.swift
//  kaaram
//
//  In-memory repository used for SwiftUI previews and future unit tests.
//  The `.palakPaneer` fixture mirrors the row we seeded into CloudKit,
//  so previews look like production.
//

import Foundation

struct MockRecipeRepository: RecipeRepository {
    let recipes: [Recipe]

    init(recipes: [Recipe] = Recipe.previewSet) {
        self.recipes = recipes
    }

    func fetchPublished() async throws -> [Recipe] {
        recipes.filter(\.isPublished)
    }

    func fetchRecipe(slug: String) async throws -> Recipe {
        guard let found = recipes.first(where: { $0.slug == slug }) else {
            throw RecipeRepositoryError.notFound
        }
        return found
    }
}

// MARK: - Preview fixtures

extension Recipe {
    static var previewSet: [Recipe] {
        [.palakPaneer, .pappu, .pulihora, .gonguraPachadi]
    }

    static let palakPaneer = Recipe(
        nameEN: "Palak Paneer",
        nameTE: "పాలక్ పనీర్",
        nameRomanized: "palak paneer",
        slug: "palak-paneer",
        summary: "Creamy spinach-paneer curry with a smooth, aromatic gravy, soft paneer cubes, and a finishing touch of kasuri methi.",
        category: .curry,
        region: .northIndian,
        tags: ["vegetarian", "kidfriendly"],
        difficulty: 2,
        totalMinutes: 40,
        servings: 4,
        heroImageURL: nil,
        thumbnailImageURL: nil,
        ingredients: [
            .init(section: "For blanching",  qty: "400-500", unit: "g",     item: "spinach",             notes: nil),
            .init(section: "For blanching",  qty: "1",       unit: "liter", item: "water",               notes: nil),
            .init(section: "For the paste",  qty: "1",       unit: "tbsp",  item: "oil",                 notes: nil),
            .init(section: "For the paste",  qty: "1",       unit: "inch",  item: "cinnamon stick",      notes: nil),
            .init(section: "For the paste",  qty: "3",       unit: nil,     item: "cloves",              notes: nil),
            .init(section: "For the paste",  qty: "1/2",     unit: "cup",   item: "onion, sliced",       notes: nil),
            .init(section: "For the curry",  qty: "150",     unit: "g",     item: "paneer, cubed",       notes: nil),
            .init(section: "For the curry",  qty: "2",       unit: "tsp",   item: "kasuri methi",        notes: "crushed")
        ],
        steps: [
            .init(text: "Boil water. Blanch spinach for 2–3 minutes. Cool.", durationSec: 300),
            .init(text: "Heat oil. Add whole spices and cashews. Add onion and tomato. Cook 5 min.", durationSec: 420),
            .init(text: "Blend cooked mixture with spinach into a smooth paste.", durationSec: nil),
            .init(text: "Heat oil and butter. Add cumin, curry leaves, ginger-garlic paste.", durationSec: 120),
            .init(text: "Stir in turmeric, chili powder, salt. Add paste. Cook until oil separates.", durationSec: 300),
            .init(text: "Add water, simmer. Add paneer cubes, cover and simmer 5–10 min.", durationSec: 420),
            .init(text: "Finish with butter, cream, and crushed kasuri methi.", durationSec: nil)
        ],
        isPublished: true,
        publishedAt: Date(),
        schemaVersion: 1
    )

    static let pappu = Recipe(
        nameEN: "Pappu",
        nameTE: "పప్పు",
        nameRomanized: "pappu",
        slug: "pappu",
        summary: "Everyday Andhra lentil dal tempered with ghee, mustard, and curry leaves.",
        category: .curry,
        region: .andhra,
        tags: ["vegetarian", "glutenfree"],
        difficulty: 1,
        totalMinutes: 25,
        servings: 4,
        heroImageURL: nil,
        thumbnailImageURL: nil,
        ingredients: [],
        steps: [],
        isPublished: true,
        publishedAt: Date().addingTimeInterval(-86_400),
        schemaVersion: 1
    )

    static let pulihora = Recipe(
        nameEN: "Pulihora",
        nameTE: "పులిహోర",
        nameRomanized: "pulihora",
        slug: "pulihora",
        summary: "Tangy tamarind rice, a festive staple across Andhra and Telangana.",
        category: .rice,
        region: .southIndian,
        tags: ["vegetarian", "festive"],
        difficulty: 2,
        totalMinutes: 30,
        servings: 4,
        heroImageURL: nil,
        thumbnailImageURL: nil,
        ingredients: [],
        steps: [],
        isPublished: true,
        publishedAt: Date().addingTimeInterval(-172_800),
        schemaVersion: 1
    )

    static let gonguraPachadi = Recipe(
        nameEN: "Gongura Pachadi",
        nameTE: "గోంగూర పచ్చడి",
        nameRomanized: "gongura pachadi",
        slug: "gongura-pachadi",
        summary: "Sharp, spicy sorrel-leaf chutney — the flavor of home.",
        category: .chutney,
        region: .andhra,
        tags: ["vegetarian", "spicy"],
        difficulty: 2,
        totalMinutes: 40,
        servings: 6,
        heroImageURL: nil,
        thumbnailImageURL: nil,
        ingredients: [],
        steps: [],
        isPublished: true,
        publishedAt: Date().addingTimeInterval(-259_200),
        schemaVersion: 1
    )
}
