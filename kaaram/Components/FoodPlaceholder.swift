//
//  FoodPlaceholder.swift
//  kaaram
//
//  Striped warm-toned placeholder used in place of real food photography.
//  The tone set is deterministic per seed string, so the same recipe
//  always resolves to the same palette. Optional "plate" flourish
//  (concentric circles) + a monospace caption in the bottom-left corner.
//
//  Drop-in background for AsyncImage failures / no-image cases; real
//  photos slot in later.
//

import SwiftUI

/// Trio of [bg, stripe, accent] that reads as a warm South-Indian palette.
private let toneSets: [(bg: Color, stripe: Color, accent: Color)] = [
    (Color(red: 0.776, green: 0.365, blue: 0.180),  // copper
     Color(red: 0.545, green: 0.180, blue: 0.122),
     Color(red: 0.851, green: 0.643, blue: 0.255)),
    (Color(red: 0.243, green: 0.361, blue: 0.184),  // curry leaf
     Color(red: 0.165, green: 0.251, blue: 0.125),
     Color(red: 0.478, green: 0.545, blue: 0.239)),
    (Color(red: 0.545, green: 0.353, blue: 0.169),  // tamarind
     Color(red: 0.361, green: 0.227, blue: 0.106),
     Color(red: 0.788, green: 0.541, blue: 0.361)),
    (Color(red: 0.851, green: 0.643, blue: 0.255),  // turmeric
     Color(red: 0.722, green: 0.514, blue: 0.173),
     Color(red: 0.941, green: 0.816, blue: 0.565)),
    (Color(red: 0.420, green: 0.227, blue: 0.122),  // clove
     Color(red: 0.227, green: 0.129, blue: 0.082),
     Color(red: 0.612, green: 0.290, blue: 0.165)),
    (Color(red: 0.651, green: 0.235, blue: 0.173),  // paprika
     Color(red: 0.435, green: 0.129, blue: 0.094),
     Color(red: 0.878, green: 0.651, blue: 0.416))
]

struct FoodPlaceholder: View {
    let label: String
    var note: String? = nil
    var flourish: Bool = true
    var cornerRadius: CGFloat = 16

    private var tone: (bg: Color, stripe: Color, accent: Color) {
        let seed = (label.isEmpty ? "dish" : label)
        var h = 0
        for ch in seed.unicodeScalars {
            h = (h &* 31) &+ Int(ch.value)
        }
        return toneSets[abs(h) % toneSets.count]
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                tone.bg

                DiagonalStripes(spacing: 14, stripeWidth: 6)
                    .fill(tone.stripe.opacity(0.55))

                if flourish {
                    let r = min(geo.size.width, geo.size.height)
                    Circle()
                        .fill(tone.accent.opacity(0.22))
                        .frame(width: r * 0.62, height: r * 0.62)
                        .offset(y: geo.size.height * 0.05)
                    Circle()
                        .fill(tone.stripe.opacity(0.35))
                        .frame(width: r * 0.42, height: r * 0.42)
                        .offset(y: geo.size.height * 0.05)
                }

                if !label.isEmpty {
                    captionTag
                        .padding(.leading, 10)
                        .padding(.bottom, 8)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }

    private var captionTag: some View {
        let composed = note.map { "\(label) · \($0)" } ?? label
        return Text(composed.uppercased())
            .font(.system(size: 9, weight: .semibold, design: .monospaced))
            .tracking(0.6)
            .foregroundStyle(Color(red: 1, green: 0.96, blue: 0.90).opacity(0.92))
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.black.opacity(0.32))
            )
    }
}

private struct DiagonalStripes: Shape {
    let spacing: CGFloat
    let stripeWidth: CGFloat

    func path(in rect: CGRect) -> Path {
        var p = Path()
        // Draw wider than the rect, rotated -30°, so edges stay filled.
        let rotation = CGAffineTransform(rotationAngle: -.pi / 6)
        let diagonal = sqrt(rect.width * rect.width + rect.height * rect.height) * 1.4
        let origin = CGPoint(x: rect.midX - diagonal / 2, y: rect.midY - diagonal / 2)

        var x: CGFloat = 0
        while x < diagonal {
            let stripe = CGRect(
                x: origin.x + x,
                y: origin.y,
                width: stripeWidth,
                height: diagonal
            )
            p.addRect(stripe)
            x += spacing
        }

        return p.applying(
            CGAffineTransform(translationX: -rect.midX, y: -rect.midY)
                .concatenating(rotation)
                .concatenating(CGAffineTransform(translationX: rect.midX, y: rect.midY))
        )
    }
}

#Preview {
    VStack(spacing: Spacing.m) {
        FoodPlaceholder(label: "GONGURA MAMSAM", note: "overhead")
            .frame(height: 240)
        HStack(spacing: Spacing.m) {
            FoodPlaceholder(label: "PAPPU", flourish: false)
                .frame(height: 120)
            FoodPlaceholder(label: "PULIHORA", flourish: false)
                .frame(height: 120)
        }
    }
    .padding()
    .background(Color.kaaramBackground)
}
