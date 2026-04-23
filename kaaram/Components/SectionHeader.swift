//
//  SectionHeader.swift
//  kaaram
//
//  Section label: serif title on the left, optional monospace
//  "see-all" / count label on the right. Matches the pattern used
//  across Home ("Browse by dish · SEE ALL", "Weeknight tiffins · 12 RECIPES").
//

import SwiftUI

struct SectionHeader: View {
    let title: String
    var trailing: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.kaaramTitle)
                .foregroundStyle(Color.kaaramInk)

            Spacer(minLength: Spacing.s)

            if let trailing {
                if let action {
                    Button(action: action) {
                        MonoCap(trailing)
                    }
                } else {
                    MonoCap(trailing)
                }
            } else if let action {
                Button(action: action) {
                    MonoCap("See all")
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: Spacing.xl) {
        SectionHeader(title: "Browse by dish", action: {})
        SectionHeader(title: "Weeknight tiffins", trailing: "12 RECIPES")
        SectionHeader(title: "Ingredients", trailing: "4 SERVINGS")
    }
    .padding()
    .background(Color.kaaramBackground)
}
