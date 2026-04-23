//
//  FilterChip.swift
//  kaaram
//
//  Selectable pill used for horizontal filter rows. When selected, fills
//  with the deep ink color and flips text to cream; when unselected,
//  sits transparent behind a hairline border. Matches `KChip` in the
//  Claude Design mockups. Selection haptic on toggle.
//

import SwiftUI
import UIKit

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    private let haptic = UISelectionFeedbackGenerator()

    var body: some View {
        Button {
            haptic.selectionChanged()
            action()
        } label: {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .tracking(-0.1)
                .lineLimit(1)
                .foregroundStyle(isSelected ? Color.kaaramBackground : Color.kaaramInkSoft)
                .padding(.horizontal, 13)
                .padding(.vertical, 7)
                .background(
                    isSelected ? Color.kaaramInk : Color.clear,
                    in: Capsule()
                )
                .overlay(
                    Capsule()
                        .stroke(
                            isSelected ? Color.clear : Color.kaaramHairline,
                            lineWidth: 1
                        )
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HStack(spacing: Spacing.xs) {
        FilterChip(title: "All",       isSelected: true)  {}
        FilterChip(title: "Veg",       isSelected: false) {}
        FilterChip(title: "30 min",    isSelected: false) {}
        FilterChip(title: "Telangana", isSelected: false) {}
        FilterChip(title: "Festive",   isSelected: false) {}
    }
    .padding()
    .background(Color.kaaramBackground)
}
