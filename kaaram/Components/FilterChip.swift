//
//  FilterChip.swift
//  kaaram
//
//  Selectable pill used for filter rows (region, category, tags).
//  Different visual language from the meta Chip: border when
//  unselected, solid accent fill when selected. Haptic on toggle.
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
                .font(.caption.weight(.medium))
                .lineLimit(1)
                .foregroundStyle(isSelected ? Color.white : Color.primary)
                .padding(.horizontal, Spacing.m)
                .padding(.vertical, Spacing.s)
                .background(
                    isSelected ? Color.kaaramSpice : Color.kaaramSurface,
                    in: Capsule()
                )
                .overlay(
                    Capsule()
                        .stroke(
                            isSelected ? Color.clear : Color.secondary.opacity(0.25),
                            lineWidth: 1
                        )
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(alignment: .leading, spacing: Spacing.m) {
        HStack(spacing: Spacing.xs) {
            FilterChip(title: "All",        isSelected: true)  {}
            FilterChip(title: "Andhra",     isSelected: false) {}
            FilterChip(title: "Telangana",  isSelected: false) {}
            FilterChip(title: "S. Indian",  isSelected: false) {}
        }
    }
    .padding()
    .background(Color.kaaramBackground)
}
