//
//  Color+Kaaram.swift
//  kaaram
//
//  Semantic colors for the Kaaram design system. Palette is inspired by
//  Andhra/Telangana spice boxes: chili red, turmeric, curry leaf, warm cream.
//

import SwiftUI
import UIKit

extension Color {
    /// Primary brand color — chili red. Used for CTAs, accents, "favorite".
    static let kaaramSpice = Color(
        light: Color(red: 0.85, green: 0.23, blue: 0.15),
        dark:  Color(red: 1.00, green: 0.35, blue: 0.26)
    )

    /// Turmeric gold — warm highlights, timer rings, "new".
    static let kaaramTurmeric = Color(
        light: Color(red: 0.88, green: 0.66, blue: 0.18),
        dark:  Color(red: 0.96, green: 0.75, blue: 0.38)
    )

    /// Curry-leaf green — regional/veg indicators, success states.
    static let kaaramCurry = Color(
        light: Color(red: 0.18, green: 0.42, blue: 0.24),
        dark:  Color(red: 0.37, green: 0.68, blue: 0.44)
    )

    /// App background — warm off-white / near-black.
    static let kaaramBackground = Color(
        light: Color(red: 0.98, green: 0.96, blue: 0.93),
        dark:  Color(red: 0.08, green: 0.07, blue: 0.07)
    )

    /// Surface for cards and lifted content.
    static let kaaramSurface = Color(
        light: .white,
        dark:  Color(red: 0.14, green: 0.13, blue: 0.12)
    )
}

private extension Color {
    /// Build a dynamic color that resolves per interface style.
    init(light: Color, dark: Color) {
        self = Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(dark)
                : UIColor(light)
        })
    }
}
