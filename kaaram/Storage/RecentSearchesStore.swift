//
//  RecentSearchesStore.swift
//  kaaram
//
//  UserDefaults-backed store for recent search terms. Most-recent first,
//  case-insensitive dedup, capped at `maxCount`. Small enough that
//  UserDefaults is the right home — SwiftData would be over-engineering.
//

import Foundation

struct RecentSearchesStore {
    private let defaults: UserDefaults
    private let key: String
    private let maxCount: Int

    init(
        defaults: UserDefaults = .standard,
        key: String = "kaaram.recentSearches",
        maxCount: Int = 10
    ) {
        self.defaults = defaults
        self.key = key
        self.maxCount = maxCount
    }

    func all() -> [String] {
        defaults.stringArray(forKey: key) ?? []
    }

    func add(_ term: String) {
        let trimmed = term.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        // Case-insensitive dedup; keep the new casing.
        var current = all().filter {
            $0.caseInsensitiveCompare(trimmed) != .orderedSame
        }
        current.insert(trimmed, at: 0)
        if current.count > maxCount {
            current = Array(current.prefix(maxCount))
        }
        defaults.set(current, forKey: key)
    }

    func remove(_ term: String) {
        let current = all().filter {
            $0.caseInsensitiveCompare(term) != .orderedSame
        }
        defaults.set(current, forKey: key)
    }

    func clear() {
        defaults.removeObject(forKey: key)
    }
}
