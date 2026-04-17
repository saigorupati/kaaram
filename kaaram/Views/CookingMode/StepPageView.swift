//
//  StepPageView.swift
//  kaaram
//
//  One page of the cooking-mode TabView. Optimized for reading
//  at arm's length while cooking: big serif body text, high contrast,
//  generous padding. Timer slot is placeholder today; CP2 adds the
//  real countdown component.
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
                    timerPlaceholder(seconds: seconds)
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

    /// Placeholder until CP2 swaps in a real countdown StepTimerView.
    private func timerPlaceholder(seconds: Int) -> some View {
        HStack(spacing: Spacing.s) {
            Image(systemName: "timer")
            Text(Self.format(seconds: seconds))
        }
        .font(.kaaramHeadline)
        .foregroundStyle(Color.kaaramTurmeric)
        .padding(.horizontal, Spacing.l)
        .padding(.vertical, Spacing.m)
        .background(
            Color.kaaramTurmeric.opacity(0.15),
            in: Capsule()
        )
    }

    private static func format(seconds: Int) -> String {
        if seconds < 60 { return "\(seconds) sec" }
        let m = seconds / 60
        let s = seconds % 60
        return s == 0 ? "\(m) min" : "\(m)m \(s)s"
    }
}

#Preview {
    StepPageView(
        number: 2,
        total: 9,
        step: .init(
            text: "Heat 1 tbsp oil. Add cinnamon, cloves, cardamom, and cashews. Sauté briefly. Add green chilies, onion, and tomato. Cover and cook on low for 5 minutes until soft.",
            durationSec: 420
        )
    )
    .background(Color.kaaramBackground)
}
