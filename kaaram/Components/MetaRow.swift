//
//  MetaRow.swift
//  kaaram
//
//  Small icon + label pair used in recipe meta rows ("1h 20m", "Telangana",
//  "Serves 4"). Mirrors `MiniMeta` from the Claude Design mockups.
//

import SwiftUI

struct MetaRow: View {
    let systemImage: String
    let label: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: systemImage)
                .font(.system(size: 11, weight: .medium))
            Text(label)
                .font(.system(size: 12.5))
        }
        .foregroundStyle(Color.kaaramInkMuted)
    }
}

/// Heat indicator (0–4 bars). Uses the chilli accent by default.
struct HeatDots: View {
    let level: Int
    var max: Int = 4
    var color: Color = .kaaramSpice
    var dotWidth: CGFloat = 3
    var dotHeight: CGFloat = 8

    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...max, id: \.self) { i in
                RoundedRectangle(cornerRadius: 1, style: .continuous)
                    .fill(i <= level ? color : Color.kaaramHairline)
                    .frame(width: dotWidth, height: dotHeight)
            }
        }
    }
}

#Preview {
    VStack(alignment: .leading, spacing: Spacing.m) {
        HStack(spacing: Spacing.l) {
            MetaRow(systemImage: "clock", label: "1h 20m")
            MetaRow(systemImage: "flame", label: "Telangana")
            MetaRow(systemImage: "fork.knife", label: "Serves 4")
        }
        HStack(spacing: Spacing.m) {
            HeatDots(level: 1)
            HeatDots(level: 2)
            HeatDots(level: 3)
            HeatDots(level: 4)
        }
    }
    .padding()
    .background(Color.kaaramBackground)
}
