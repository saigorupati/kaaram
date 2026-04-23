//
//  BilingualName.swift
//  kaaram
//
//  Displays a recipe name as a serif editorial headline. Per the design
//  system the primary display is English — Telugu is optionally shown
//  beneath in a subtle serif subtitle as a cultural cue. Romanization
//  is hidden when it matches the English name.
//

import SwiftUI

struct BilingualName: View {
    let english: String
    let telugu: String
    let romanized: String
    var alignment: HorizontalAlignment = .leading
    var showTelugu: Bool = true

    var body: some View {
        VStack(alignment: alignment, spacing: Spacing.xs) {
            Text(english)
                .font(.kaaramDisplay)
                .tracking(-0.8)
                .foregroundStyle(Color.kaaramInk)
                .lineLimit(2)

            if showTelugu && !telugu.isEmpty {
                Text(telugu)
                    .font(.kaaramTelugu)
                    .foregroundStyle(Color.kaaramInkMuted)
            } else if romanized.lowercased() != english.lowercased() && !romanized.isEmpty {
                Text(romanized)
                    .font(.caption)
                    .italic()
                    .foregroundStyle(Color.kaaramInkMuted)
            }
        }
    }
}

#Preview {
    VStack(alignment: .leading, spacing: Spacing.xl) {
        BilingualName(english: "Gongura Mamsam", telugu: "గోంగూర మాంసం", romanized: "gongura mamsam")
        BilingualName(english: "Pulihora", telugu: "పులిహోర", romanized: "pulihora")
        BilingualName(english: "Pappu", telugu: "పప్పు", romanized: "pappu", showTelugu: false)
    }
    .padding()
    .background(Color.kaaramBackground)
}
