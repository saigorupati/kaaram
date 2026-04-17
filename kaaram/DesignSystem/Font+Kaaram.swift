//
//  Font+Kaaram.swift
//  kaaram
//
//  Typography tokens. Uses system serif for display (feels editorial/warm)
//  and rounded for labels. All tokens map to a Dynamic Type text style
//  so they scale with the user's preferred size.
//

import SwiftUI

extension Font {
    /// Hero headline — recipe detail title.
    static let kaaramDisplay = Font.system(.largeTitle, design: .serif).weight(.bold)

    /// Section titles, card headers.
    static let kaaramTitle = Font.system(.title2, design: .serif).weight(.semibold)

    /// Recipe card names, list row titles.
    static let kaaramHeadline = Font.system(.headline, design: .rounded).weight(.semibold)

    /// Body copy — recipe steps, descriptions.
    static let kaaramBody = Font.system(.body, design: .default)

    /// Small labels, meta (time, difficulty), chips.
    static let kaaramCallout = Font.system(.callout, design: .default).weight(.medium)

    /// Telugu script rendering. Serif tends to look better for తెలుగు.
    static let kaaramTelugu = Font.system(.title3, design: .serif)
}
