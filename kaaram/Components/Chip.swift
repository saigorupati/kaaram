//
//  Chip.swift
//  kaaram
//
//  Small pill-shaped label with optional icon. Used for meta info
//  (time, difficulty, region) and filters.
//

import SwiftUI

struct Chip: View {
    let text: String
    var systemImage: String? = nil
    var style: ChipStyle = .neutral

    enum ChipStyle {
        case neutral, spice, turmeric, curry

        var background: Color {
            switch self {
            case .neutral:  return .kaaramSurface
            case .spice:    return .kaaramSpice.opacity(0.15)
            case .turmeric: return .kaaramTurmeric.opacity(0.18)
            case .curry:    return .kaaramCurry.opacity(0.15)
            }
        }

        var foreground: Color {
            switch self {
            case .neutral:  return .primary
            case .spice:    return .kaaramSpice
            case .turmeric: return .kaaramTurmeric
            case .curry:    return .kaaramCurry
            }
        }
    }

    var body: some View {
        HStack(spacing: Spacing.xs) {
            if let systemImage {
                Image(systemName: systemImage)
            }
            Text(text)
        }
        .font(.kaaramCallout)
        .padding(.horizontal, Spacing.m)
        .padding(.vertical, Spacing.s)
        .background(style.background, in: Capsule())
        .foregroundStyle(style.foreground)
    }
}

#Preview {
    VStack(spacing: Spacing.m) {
        Chip(text: "Andhra", systemImage: "map", style: .curry)
        Chip(text: "25 min", systemImage: "clock", style: .turmeric)
        Chip(text: "Spicy", systemImage: "flame", style: .spice)
        Chip(text: "Vegetarian", style: .neutral)
    }
    .padding()
    .background(Color.kaaramBackground)
}
