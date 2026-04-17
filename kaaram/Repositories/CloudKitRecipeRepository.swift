//
//  CloudKitRecipeRepository.swift
//  kaaram
//
//  Live CloudKit implementation of `RecipeRepository`. Talks to the
//  Public database of container `iCloud.com.saigorupati.kaaram`.
//
//  No auth is required for reads — the Public DB grants _world READ
//  per our schema. Writes (authoring recipes) are done via cktool or
//  the CloudKit Console by the container owner, not by the app.
//

import CloudKit
import Foundation
import OSLog

private let log = Logger(subsystem: "com.saigorupati.kaaram", category: "CloudKitRecipes")

struct CloudKitRecipeRepository: RecipeRepository {
    private let database: CKDatabase

    init(container: CKContainer = .default()) {
        self.database = container.publicCloudDatabase
    }

    // MARK: - Fetch list

    func fetchPublished() async throws -> [Recipe] {
        let predicate = NSPredicate(format: "isPublished == 1")
        let query = CKQuery(recordType: "Recipe", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "publishedAt", ascending: false)]

        do {
            let (matchResults, _) = try await database.records(
                matching: query,
                resultsLimit: CKQueryOperation.maximumResults
            )

            let recipes: [Recipe] = matchResults.compactMap { _, result in
                switch result {
                case .success(let record):
                    return Self.recipe(from: record)
                case .failure(let error):
                    log.error("Skipping record with decode failure: \(error.localizedDescription)")
                    return nil
                }
            }

            log.info("Fetched \(recipes.count) published recipe(s)")
            return recipes
        } catch {
            throw Self.mapError(error)
        }
    }

    // MARK: - Fetch single

    func fetchRecipe(slug: String) async throws -> Recipe {
        let predicate = NSPredicate(format: "slug == %@", slug)
        let query = CKQuery(recordType: "Recipe", predicate: predicate)

        do {
            let (matchResults, _) = try await database.records(matching: query, resultsLimit: 1)
            guard
                let first = matchResults.first,
                case .success(let record) = first.1,
                let recipe = Self.recipe(from: record)
            else {
                throw RecipeRepositoryError.notFound
            }
            return recipe
        } catch let e as RecipeRepositoryError {
            throw e
        } catch {
            throw Self.mapError(error)
        }
    }

    // MARK: - CKRecord → Recipe

    /// Returns nil if required fields are missing. Logs what went wrong so
    /// a single malformed record can't nuke the whole fetch.
    private static func recipe(from record: CKRecord) -> Recipe? {
        guard
            let slug = record["slug"] as? String,
            let nameEN = record["nameEN"] as? String
        else {
            log.error("Recipe record \(record.recordID.recordName) missing required fields (slug/nameEN)")
            return nil
        }

        let ingredients = decodeIngredients(from: record["ingredientsJSON"] as? String)
        let steps = decodeSteps(from: record["stepsJSON"] as? String)

        return Recipe(
            nameEN:            nameEN,
            nameTE:            record["nameTE"] as? String ?? "",
            nameRomanized:     record["nameRomanized"] as? String ?? nameEN.lowercased(),
            slug:              slug,
            summary:           record["summary"] as? String ?? "",
            category:          Recipe.Category.from(record["category"] as? String ?? ""),
            region:            Recipe.Region.from(record["region"] as? String ?? ""),
            tags:              (record["tags"] as? [String]) ?? [],
            difficulty:        Int(record["difficulty"] as? Int64 ?? 1),
            totalMinutes:      Int(record["totalMinutes"] as? Int64 ?? 0),
            servings:          Int(record["servings"] as? Int64 ?? 1),
            heroImageURL:      assetURL(record["heroImage"]),
            thumbnailImageURL: assetURL(record["thumbnailImage"]),
            ingredients:       ingredients,
            steps:             steps,
            isPublished:       (record["isPublished"] as? Int64 ?? 0) == 1,
            publishedAt:       record["publishedAt"] as? Date,
            schemaVersion:     Int(record["schemaVersion"] as? Int64 ?? 1)
        )
    }

    private static func assetURL(_ any: Any?) -> URL? {
        (any as? CKAsset)?.fileURL
    }

    private static func decodeIngredients(from json: String?) -> [Recipe.Ingredient] {
        guard let json, let data = json.data(using: .utf8) else { return [] }
        do {
            return try JSONDecoder().decode([Recipe.Ingredient].self, from: data)
        } catch {
            log.error("Failed to decode ingredientsJSON: \(error.localizedDescription)")
            return []
        }
    }

    private static func decodeSteps(from json: String?) -> [Recipe.Step] {
        guard let json, let data = json.data(using: .utf8) else { return [] }
        do {
            return try JSONDecoder().decode([Recipe.Step].self, from: data)
        } catch {
            log.error("Failed to decode stepsJSON: \(error.localizedDescription)")
            return []
        }
    }

    // MARK: - Error mapping

    private static func mapError(_ error: Error) -> RecipeRepositoryError {
        guard let ck = error as? CKError else {
            return .underlying(error.localizedDescription)
        }
        switch ck.code {
        case .notAuthenticated:
            return .notSignedIntoICloud
        case .networkUnavailable, .networkFailure:
            return .networkUnavailable
        case .unknownItem, .invalidArguments:
            // Most common cause on first run: schema not deployed, or a
            // queryable index is missing on `isPublished` / `publishedAt`.
            return .schemaNotDeployed
        default:
            return .underlying(ck.localizedDescription)
        }
    }
}
