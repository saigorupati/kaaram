//
//  StepPageView.swift
//  kaaram
//
//  One page of the cooking-mode TabView. Large serif instruction, a
//  MonoCap label ("SEAR · 4 MINUTES") as an eyebrow above it, then the
//  inline timer card when the step has a duration. Optimized for
//  reading at arm's length.
//

import SwiftUI

struct StepPageView: View {
    let number: Int
    let total: Int
    let step: Recipe.Step

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                MonoCap(eyebrow, color: .kaaramSpice)

                Text(instruction)
                    .font(.system(size: 34, weight: .medium, design: .serif))
                    .tracking(-1.0)
                    .foregroundStyle(Color.kaaramInk)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)

                if let seconds = step.durationSec {
                    StepTimerView(totalSeconds: seconds)
                        .padding(.top, Spacing.m)
                        .frame(maxWidth: .infinity)
                }

                Spacer(minLength: Spacing.xl)
            }
            .padding(.horizontal, 28)
            .padding(.top, Spacing.xl)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var eyebrow: String {
        if let seconds = step.durationSec {
            let min = max(1, seconds / 60)
            return "STEP \(number) OF \(total) · \(min) MIN"
        }
        return "STEP \(number) OF \(total)"
    }

    /// Show a short "title" (first sentence) if the step text is long,
    /// otherwise show the full text. Keeps the giant type from
    /// overflowing on small screens.
    private var instruction: String {
        let trimmed = step.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.count <= 120 { return trimmed }
        if let dot = trimmed.firstIndex(of: ".") {
            return String(trimmed[..<dot]) + "."
        }
        return trimmed
    }
}

#Preview("With timer") {
    StepPageView(
        number: 2,
        total: 9,
        step: .init(
            text: "Heat 1 tbsp oil. Add cinnamon, cloves, cardamom, and cashews. Sauté briefly.",
            durationSec: 300
        )
    )
    .background(Color.kaaramBackground)
}

#Preview("No timer") {
    StepPageView(
        number: 3,
        total: 9,
        step: .init(
            text: "Blend the cooked onion-tomato mixture with the spinach into a smooth paste.",
            durationSec: nil
        )
    )
    .background(Color.kaaramBackground)
}
