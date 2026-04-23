//
//  Font+Kaaram.swift
//  kaaram
//
//  Typography tokens.
//  - Display / Title / Section use a serif (New York on iOS) to carry
//    the editorial warmth Fraunces gives the mockups.
//  - Body, Callout, Label use the default system sans.
//  - Mono is reserved for monospaced eyebrow captions (e.g. "ANDHRA · NON-VEG").
//
//  All tokens bind to a Dynamic Type style so they scale with the user's
//  preferred size.
//

import SwiftUI

extension Font {
    // MARK: Serif — editorial headlines

    /// 40–46pt serif — hero onboarding / cooking-mode step.
    static let kaaramHero = Font.system(size: 38, weight: .medium, design: .serif)

    /// 32pt serif — screen titles ("Explore", "Saved", recipe hero).
    static let kaaramDisplay = Font.system(size: 30, weight: .medium, design: .serif)

    /// 24pt serif — section headers inside a screen.
    static let kaaramTitle = Font.system(size: 22, weight: .medium, design: .serif)

    /// 18pt serif — card/row recipe names.
    static let kaaramHeadline = Font.system(size: 17, weight: .medium, design: .serif)

    /// Telugu / bilingual subtitle. Serif renders Telugu nicely too.
    static let kaaramTelugu = Font.system(size: 16, weight: .regular, design: .serif)

    // MARK: Sans — UI text

    /// 15pt body copy.
    static let kaaramBody = Font.system(size: 15, weight: .regular, design: .default)

    /// 13pt small copy, meta rows.
    static let kaaramCallout = Font.system(size: 13, weight: .medium, design: .default)

    /// 11pt tiny labels under thumbnails.
    static let kaaramLabel = Font.system(size: 11, weight: .medium, design: .default)

    // MARK: Mono — eyebrows, numeric meta

    /// Uppercase mono eyebrow used in `MonoCap`.
    static let kaaramMono = Font.system(size: 10, weight: .semibold, design: .monospaced)

    /// Slightly larger mono for step numbers, quantities.
    static let kaaramMonoStrong = Font.system(size: 12, weight: .semibold, design: .monospaced)
}
