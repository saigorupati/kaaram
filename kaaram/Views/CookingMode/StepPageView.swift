//
//  StepPageView.swift
//  kaaram
//
//  One page of the cooking-mode TabView. Optimized for reading at
//  arm's length while cooking: big serif body text, high contrast,
//  generous padding. Steps with a durationSec show a full interactive
//  StepTimerView beneath the instruction.
//

import SwiftUI

struct StepPageView: View {
    let number: Int
    let total: Int
    let step: Recipe.Step

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                stepLabel

                Text(step.text)
                    .font(.system(.title2, design: .serif))
                    .fontWeight(.regular)
                    .lineSpacing(4)
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)

                if let seconds = step.durationSec {
                    StepTimerView(totalSeconds: seconds)
                        .frame(maxWidth: .infinity)
                        .padding(.top, Spacing.m)
                }

                Spacer(minLength: Spacing.xl)
            }
            .padding(.horizontal, Spacing.xl)
            .padding(.top, Spacing.xl)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var stepLabel: some View {
        HStack(spacing: Spacing.s) {
            Text("Step \(number)")
                .font(.kaaramCallout)
                .foregroundStyle(Color.kaaramSpice)

            Text("of \(total)")
                .font(.kaaramCallout)
                .foregroundStyle(.tertiary)
        }
    }
}

#Preview("With timer") {
    StepPageView(
        number: 2,
        total: 9,
        step: .init(
            text: "Heat 1 tbsp oil. Add cinnamon, cloves, cardamom, and cashews. Sauté briefly. Add green chilies, onion, and tomato. Cover and cook on low for 5 minutes until soft.",
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
