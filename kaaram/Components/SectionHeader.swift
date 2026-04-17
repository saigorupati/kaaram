//
//  SectionHeader.swift
//  kaaram
//

import SwiftUI

struct SectionHeader: View {
    let title: String
    var action: (() -> Void)? = nil
    var actionLabel: String = "See All"

    var body: some View {
        HStack {
            Text(title)
                .font(.kaaramTitle)
            Spacer()
            if let action {
                Button(actionLabel, action: action)
                    .font(.kaaramCallout)
                    .foregroundStyle(Color.kaaramSpice)
            }
        }
    }
}

#Preview {
    VStack(spacing: Spacing.xl) {
        SectionHeader(title: "Featured today")
        SectionHeader(title: "Breakfast", action: {})
    }
    .padding()
    .background(Color.kaaramBackground)
}
