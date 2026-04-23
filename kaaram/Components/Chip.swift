//
//  Chip.swift
//  kaaram
//
//  Small pill label for meta info (time, region, difficulty). Two styles:
//  - `.ink` — solid ink fill with cream text. Used as the "active" state
//    on filter chips and primary CTAs at the chip level.
//  - `.outline` — transparent with a hairline border. The default resting
//    state. Text color is `kaaramInkSoft`.
//
//  Two sizes (regular / compact). Optional system-image icon.
//

import SwiftUI

struct Chip: View {
    let text: String
    var systemImage: String? = nil
    var style: ChipStyle = .outline
    var size: ChipSize = .regular

    enum ChipStyle {
        case outline, ink, spice, curry, turmeric

        var background: Color {
            switch self {
            case .outline:  return .clear
            case .ink:      return .kaaramInk
            case .spice:    return .kaaramSpiceWash
            case .curry:    return .kaaramCurry.opacity(0.14)
            case .turmeric: return .kaaramTurmeric.opacity(0.18)
            }
        }

        var foreground: Color {
            switch self {
            case .outline:  return .kaaramInkSoft
            case .ink:      return .kaaramBackground
            case .spice:    return .kaaramSpice
            case .curry:    return .kaaramCurry
            case .turmeric: return .kaaramTurmeric
            }
        }

        var hasBorder: Bool {
            switch self {
            case .outline:  return true
            default:        return false
            }
        }
    }

    enum ChipSize {
        case regular, compact

        var font: Font {
            switch self {
            case .regular: .system(size: 13, weight: .medium)
            case .compact: .system(size: 11.5, weight: .medium)
            }
        }

        var horizontalPadding: CGFloat {
            switch self {
            case .regular: 13
            case .compact: 9
            }
        }

        var verticalPadding: CGFloat {
            switch self {
            case .regular: 7
            case .compact: 4
            }
        }
    }

    var body: some View {
        HStack(spacing: 5) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.system(size: size == .regular ? 11 : 10, weight: .medium))
            }
            Text(text)
                .lineLimit(1)
        }
        .font(size.font)
        .tracking(-0.1)
        .padding(.horizontal, size.horizontalPadding)
        .padding(.vertical, size.verticalPadding)
        .foregroundStyle(style.foreground)
        .background(style.background, in: Capsule())
        .overlay(
            Capsule().stroke(
                style.hasBorder ? Color.kaaramHairline : Color.clear,
                lineWidth: 1
            )
        )
    }
}

#Preview {
    VStack(alignment: .leading, spacing: Spacing.l) {
        HStack(spacing: Spacing.s) {
            Chip(text: "All", style: .ink)
            Chip(text: "Veg")
            Chip(text: "30 min")
            Chip(text: "Telangana")
        }
        HStack(spacing: Spacing.s) {
            Chip(text: "Telangana",  systemImage: "map",   style: .curry)
            Chip(text: "25 min",  systemImage: "clock", style: .turmeric)
            Chip(text: "Spicy",   systemImage: "flame", style: .spice)
        }
    }
    .padding()
    .background(Color.kaaramBackground)
}
