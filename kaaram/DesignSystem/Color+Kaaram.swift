//
//  Color+Kaaram.swift
//  kaaram
//
//  Warm editorial palette drawn from the Telugu pantry — tamarind cream
//  canvas, deep chilli primary, copper/turmeric/curry-leaf accents, and
//  clove ink for text. Light and dark variants resolve through UIKit so
//  SwiftUI sees a single dynamic Color.
//

import SwiftUI
import UIKit

extension Color {
    // MARK: Surfaces

    /// Tamarind cream — the primary canvas.
    static let kaaramBackground = Color(
        light: Color(hex: 0xF5EFE6),
        dark:  Color(hex: 0x17110D)
    )

    /// Banana-leaf card surface.
    static let kaaramSurface = Color(
        light: Color(hex: 0xFBF6EC),
        dark:  Color(hex: 0x1F1814)
    )

    /// Raw-rice secondary surface / segmented background.
    static let kaaramSurface2 = Color(
        light: Color(hex: 0xF0E8D9),
        dark:  Color(hex: 0x2A211B)
    )

    // MARK: Ink

    /// Clove ink — primary text, tab-bar and button fills.
    static let kaaramInk = Color(
        light: Color(hex: 0x1C1714),
        dark:  Color(hex: 0xF5EFE6)
    )

    /// Body copy.
    static let kaaramInkSoft = Color(
        light: Color(hex: 0x4A3F37),
        dark:  Color(hex: 0xE6DAC8)
    )

    /// Muted labels / metadata.
    static let kaaramInkMuted = Color(
        light: Color(hex: 0x867769),
        dark:  Color(hex: 0x9A8A7B)
    )

    /// Strong hairline (borders on active controls).
    static let kaaramHairline = Color(
        light: Color(red: 28/255,  green: 23/255,  blue: 20/255,  opacity: 0.10),
        dark:  Color(red: 245/255, green: 239/255, blue: 230/255, opacity: 0.10)
    )

    /// Faint hairline (list separators, card borders).
    static let kaaramHairline2 = Color(
        light: Color(red: 28/255,  green: 23/255,  blue: 20/255,  opacity: 0.06),
        dark:  Color(red: 245/255, green: 239/255, blue: 230/255, opacity: 0.06)
    )

    // MARK: Accents

    /// Chilli — the primary brand accent.
    static let kaaramSpice = Color(
        light: Color(hex: 0x8B2E1F),
        dark:  Color(hex: 0xC26B54)
    )

    /// Soft wash behind chilli accents (accentInk in tokens).
    static let kaaramSpiceWash = Color(
        light: Color(hex: 0xFFF2EA),
        dark:  Color(hex: 0x3A1D16)
    )

    /// Copper — featured/warm highlight.
    static let kaaramCopper = Color(
        light: Color(hex: 0xC65D2E),
        dark:  Color(hex: 0xD67A4E)
    )

    /// Turmeric — festive/sweet cues, timers.
    static let kaaramTurmeric = Color(
        light: Color(hex: 0xD9A441),
        dark:  Color(hex: 0xE7B861)
    )

    /// Curry leaf — veg / fresh cues, success states.
    static let kaaramCurry = Color(
        light: Color(hex: 0x3E5C2F),
        dark:  Color(hex: 0x8BA35A)
    )

    /// Tamarind brown — deep accent, rarely used.
    static let kaaramTamarind = Color(
        light: Color(hex: 0x8B5A2B),
        dark:  Color(hex: 0xC08A5A)
    )
}

// MARK: - Helpers

private extension Color {
    init(light: Color, dark: Color) {
        self = Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(dark)
                : UIColor(light)
        })
    }

    init(hex: UInt32) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >>  8) & 0xFF) / 255.0
        let b = Double( hex        & 0xFF) / 255.0
        self = Color(red: r, green: g, blue: b)
    }
}
