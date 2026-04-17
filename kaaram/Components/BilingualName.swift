//
//  BilingualName.swift
//  kaaram
//
//  Displays a recipe name in English, Telugu script, and romanized form.
//  The romanized form is shown as a subtle subtitle only when it differs
//  from the English name (e.g., "Pappu" == "Pappu", so skip it).
//

import SwiftUI

struct BilingualName: View {
    let english: String
    let telugu: String
    let romanized: String
    var alignment: HorizontalAlignment = .leading

    var body: some View {
        VStack(alignment: alignment, spacing: Spacing.xs) {
            Text(english)
                .font(.kaaramTitle)
                .foregroundStyle(.primary)

            Text(telugu)
                .font(.kaaramTelugu)
                .foregroundStyle(.secondary)

            if romanized.lowercased() != english.lowercased() {
                Text(romanized)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .italic()
            }
        }
    }
}

#Preview {
    VStack(spacing: Spacing.xl) {
        BilingualName(english: "Pappu", telugu: "పప్పు", romanized: "pappu")
        BilingualName(english: "Sour Tamarind Stew", telugu: "పులుసు", romanized: "pulusu")
        BilingualName(english: "Gongura Pickle", telugu: "గోంగూర పచ్చడి", romanized: "gongura pachadi")
    }
    .padding()
    .background(Color.kaaramBackground)
}
