//
//  SpiceDot.swift
//  kaaram
//
//  Small radial-gradient dot used as an ingredient avatar. Hue is
//  deterministic per label, mirroring `FoodPlaceholder`'s tone sets.
//  Replaces a real ingredient image until we have photography.
//

import SwiftUI

struct SpiceDot: View {
    let label: String
    var size: CGFloat = 28

    private var tone: (bg: Color, stripe: Color, accent: Color) {
        let seed = (label.isEmpty ? "x" : label)
        var h = 0
        for ch in seed.unicodeScalars {
            h = (h &* 31) &+ Int(ch.value)
        }
        let sets: [(Color, Color, Color)] = [
            (Color(red: 0.776, green: 0.365, blue: 0.180),
             Color(red: 0.545, green: 0.180, blue: 0.122),
             Color(red: 0.851, green: 0.643, blue: 0.255)),
            (Color(red: 0.243, green: 0.361, blue: 0.184),
             Color(red: 0.165, green: 0.251, blue: 0.125),
             Color(red: 0.478, green: 0.545, blue: 0.239)),
            (Color(red: 0.545, green: 0.353, blue: 0.169),
             Color(red: 0.361, green: 0.227, blue: 0.106),
             Color(red: 0.788, green: 0.541, blue: 0.361)),
            (Color(red: 0.851, green: 0.643, blue: 0.255),
             Color(red: 0.722, green: 0.514, blue: 0.173),
             Color(red: 0.941, green: 0.816, blue: 0.565)),
            (Color(red: 0.420, green: 0.227, blue: 0.122),
             Color(red: 0.227, green: 0.129, blue: 0.082),
             Color(red: 0.612, green: 0.290, blue: 0.165)),
            (Color(red: 0.651, green: 0.235, blue: 0.173),
             Color(red: 0.435, green: 0.129, blue: 0.094),
             Color(red: 0.878, green: 0.651, blue: 0.416))
        ]
        let s = sets[abs(h) % sets.count]
        return (s.0, s.1, s.2)
    }

    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [tone.accent, tone.bg, tone.stripe],
                    center: UnitPoint(x: 0.35, y: 0.3),
                    startRadius: 1,
                    endRadius: size * 0.75
                )
            )
            .frame(width: size, height: size)
            .overlay(
                Circle().stroke(Color.black.opacity(0.08), lineWidth: 1)
            )
    }
}

#Preview {
    HStack(spacing: Spacing.s) {
        ForEach(["chilli", "turmeric", "mustard", "cumin", "curry leaf"], id: \.self) { s in
            SpiceDot(label: s, size: 36)
        }
    }
    .padding()
    .background(Color.kaaramBackground)
}
