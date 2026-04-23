//
//  MonoCap.swift
//  kaaram
//
//  Uppercase monospace "eyebrow" caption — used above titles, beside
//  counts, and anywhere metadata needs to feel numeric/editorial.
//  Matches the `MonoCap` primitive from the Claude Design mockups.
//

import SwiftUI

struct MonoCap: View {
    let text: String
    var color: Color = .kaaramInkMuted
    var tracking: CGFloat = 1.4
    var size: CGFloat = 10

    init(_ text: String, color: Color = .kaaramInkMuted, size: CGFloat = 10, tracking: CGFloat = 1.4) {
        self.text = text
        self.color = color
        self.size = size
        self.tracking = tracking
    }

    var body: some View {
        Text(text.uppercased())
            .font(.system(size: size, weight: .semibold, design: .monospaced))
            .tracking(tracking)
            .foregroundStyle(color)
    }
}

#Preview {
    VStack(alignment: .leading, spacing: Spacing.m) {
        MonoCap("TUESDAY · MARGASIRA")
        MonoCap("ANDHRA · NON-VEG", color: .kaaramSpice)
        MonoCap("420 RECIPES")
    }
    .padding()
    .background(Color.kaaramBackground)
}
