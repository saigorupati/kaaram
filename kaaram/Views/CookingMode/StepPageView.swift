//
//  StepPageView.swift
//  kaaram
//
//  One page of the cooking-mode TabView. A MonoCap eyebrow, a large
//  serif headline that shows the full step text (scrolls if long), and
//  an inline timer card when the step has a duration. Optimized for
//  reading at arm's length while cooking.
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

                Text(step.text)
                    .font(.system(size: bodyFontSize, weight: .medium, design: .serif))
                    .tracking(-0.4)
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
            .padding(.bottom, Spacing.xxl)
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

    /// Scale the headline down as the step text gets longer so long,
    /// detailed instructions don't require excessive scrolling but
    /// short steps still feel like a magazine headline.
    private var bodyFontSize: CGFloat {
        let len = step.text.count
        switch len {
        case ..<80:       return 32
        case 80..<160:    return 26
        case 160..<280:   return 22
        default:          return 19
        }
    }
}

#Preview("Short step") {
    StepPageView(
        number: 1,
        total: 8,
        step: .init(
            text: "Soak 1 cup moong dal overnight. Drain in the morning.",
            durationSec: nil
        )
    )
    .background(Color.kaaramBackground)
}

#Preview("Medium step + timer") {
    StepPageView(
        number: 2,
        total: 8,
        step: .init(
            text: "Heat 1 tbsp oil. Add cinnamon, cloves, cardamom, and cashews. Sauté briefly, then add green chilies, onion, and tomato. Cover and cook on low for 5 minutes until soft.",
            durationSec: 300
        )
    )
    .background(Color.kaaramBackground)
}

#Preview("Long step (tomato rasam)") {
    StepPageView(
        number: 2,
        total: 8,
        step: .init(
            text: "Place a strainer over a large bowl. Pour in the ground mixture and gradually add about 4 cups (1 liter) of water, squeezing or pressing with a hand or ladle, to extract all the juice and separate the peels, seeds, and pulp completely. Set the strained tomato juice aside.",
            durationSec: nil
        )
    )
    .background(Color.kaaramBackground)
}
