//
//  KolamDivider.swift
//  kaaram
//
//  Subtle kolam-inspired divider — a dashed line with alternating
//  diamonds and circles. Purely ornamental; the only motif the design
//  system uses. Matches `KolamDivider` from the Claude Design mockups.
//

import SwiftUI

struct KolamDivider: View {
    enum Density { case subtle, rich }

    var color: Color = .kaaramInkMuted
    var density: Density = .subtle

    private var dots: Int { density == .subtle ? 7 : 11 }

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let cy = geo.size.height / 2
            let step: CGFloat = 14
            let centers: [CGFloat] = (0..<dots).map { i in
                w / 2 + (CGFloat(i) - CGFloat(dots - 1) / 2) * step
            }

            ZStack {
                // Dashed base line.
                Path { p in
                    p.move(to: CGPoint(x: 4, y: cy))
                    p.addLine(to: CGPoint(x: w - 4, y: cy))
                }
                .stroke(
                    color.opacity(0.55),
                    style: StrokeStyle(lineWidth: 0.6, lineCap: .round, dash: [2, 3])
                )

                // Alternating motifs.
                ForEach(Array(centers.enumerated()), id: \.offset) { index, x in
                    if index.isMultiple(of: 2) {
                        Circle()
                            .fill(color)
                            .frame(width: 2.8, height: 2.8)
                            .position(x: x, y: cy)
                    } else {
                        Diamond()
                            .fill(color)
                            .frame(width: 6, height: 6)
                            .position(x: x, y: cy)
                    }
                }
            }
            .opacity(0.55)
        }
        .frame(height: 12)
    }
}

private struct Diamond: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.midX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        p.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        p.closeSubpath()
        return p
    }
}

#Preview {
    VStack(spacing: Spacing.xl) {
        KolamDivider()
        KolamDivider(color: .kaaramSpice)
        KolamDivider(density: .rich)
    }
    .padding()
    .background(Color.kaaramBackground)
}
