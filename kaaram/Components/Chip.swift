//
//  Chip.swift
//  kaaram
//
//  Small pill-shaped label with optional icon. Used for meta info
//  (time, difficulty, region) and filters.
//
//  Two sizes:
//  - `.regular` (default): icon + text, generous padding. Used in
//    the Recipe Detail meta row.
//  - `.compact`: tighter padding, smaller caption text. Used on
//    Recipe cards in the Home grid where horizontal space is ~160pt.
//

import SwiftUI

struct Chip: View {
    let text: String
    var systemImage: String? = nil
    var style: ChipStyle = .neutral
    var size: ChipSize = .regular

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

    enum ChipSize {
        case regular, compact

        var font: Font {
            switch self {
            case .regular: .kaaramCallout
            case .compact: .caption.weight(.medium)
            }
        }

        var horizontalPadding: CGFloat {
            switch self {
            case .regular: Spacing.m
            case .compact: Spacing.s
            }
        }

        var verticalPadding: CGFloat {
            switch self {
            case .regular: Spacing.s
            case .compact: 4
            }
        }

        var iconSpacing: CGFloat {
            switch self {
            case .regular: Spacing.xs
            case .compact: 3
            }
        }
    }

    var body: some View {
        HStack(spacing: size.iconSpacing) {
            if let systemImage {
                Image(systemName: systemImage)
            }
            Text(text)
                .lineLimit(1)
                .fixedSize(horizontal: false, vertical: true)
        }
        .font(size.font)
        .padding(.horizontal, size.horizontalPadding)
        .padding(.vertical, size.verticalPadding)
        .background(style.background, in: Capsule())
        .foregroundStyle(style.foreground)
    }
}

#Preview {
    VStack(alignment: .leading, spacing: Spacing.l) {
        VStack(alignment: .leading, spacing: Spacing.s) {
            Text("Regular").font(.caption).foregroundStyle(.secondary)
            HStack(spacing: Spacing.s) {
                Chip(text: "Andhra", systemImage: "map", style: .curry)
                Chip(text: "25 min", systemImage: "clock", style: .turmeric)
                Chip(text: "Spicy", systemImage: "flame", style: .spice)
            }
        }

        VStack(alignment: .leading, spacing: Spacing.s) {
            Text("Compact").font(.caption).foregroundStyle(.secondary)
            HStack(spacing: Spacing.s) {
                Chip(text: "N. Indian", style: .curry, size: .compact)
                Chip(text: "40 min", style: .turmeric, size: .compact)
                Chip(text: "S. Indian", style: .curry, size: .compact)
            }
        }
    }
    .padding()
    .background(Color.kaaramBackground)
}
