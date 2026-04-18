//
//  RecipeNote.swift
//  kaaram
//
//  User's personal notes on a recipe, synced via the CloudKit private
//  database so the user sees the same notes on every device.
//
//  At most one note per recipe is expected. Dedup by `slug` in call
//  sites; inserting a new note when one exists will not create a
//  duplicate because writers read-before-write.
//

import Foundation
import SwiftData

@Model
final class RecipeNote {
    var slug: String = ""
    var body: String = ""
    var updatedAt: Date = Date()

    init(slug: String, body: String = "", updatedAt: Date = Date()) {
        self.slug = slug
        self.body = body
        self.updatedAt = updatedAt
    }
}
