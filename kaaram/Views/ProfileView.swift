//
//  ProfileView.swift
//  kaaram
//
//  Minimal Profile tab placeholder. Shows a simple editorial header with
//  preference rows (spice level, diet, regions) — static for now. The
//  Onboarding preferences land here once user-editable preferences are
//  wired up.
//

import SwiftUI

struct ProfileView: View {
    @State private var spiceLevel: Int = 3
    @State private var selectedDiets: Set<String> = ["Vegetarian"]
    @State private var selectedRegions: Set<String> = ["Andhra", "Telangana"]

    private let allDiets = ["Vegetarian", "Vegan", "Non-veg", "Jain", "No onion/garlic", "Gluten-free"]
    private let allRegions = ["Andhra", "Telangana", "Tamil", "Kerala", "Karnataka", "North Indian"]
    private let spiceLabels = ["Mild", "Medium", "Telangana", "Fiery"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    header
                    spiceCard
                    dietsCard
                    regionsCard
                    aboutCard
                }
                .padding(.horizontal, Spacing.l)
                .padding(.top, Spacing.s)
                .padding(.bottom, Spacing.xl)
            }
            .background(Color.kaaramBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .center, spacing: Spacing.m) {
            Circle()
                .fill(Color.kaaramSpiceWash)
                .frame(width: 56, height: 56)
                .overlay(
                    Text("K")
                        .font(.system(size: 22, weight: .semibold, design: .serif))
                        .foregroundStyle(Color.kaaramSpice)
                )

            VStack(alignment: .leading, spacing: 2) {
                MonoCap("YOUR TABLE")
                Text("Priya")
                    .font(.kaaramDisplay)
                    .tracking(-0.6)
                    .foregroundStyle(Color.kaaramInk)
            }
            Spacer()
        }
    }

    // MARK: - Spice level

    private var spiceCard: some View {
        card(title: "Spice tolerance", trailing: spiceLabels[spiceLevel - 1]) {
            HStack(spacing: 6) {
                ForEach(1...4, id: \.self) { n in
                    Button {
                        spiceLevel = n
                    } label: {
                        RoundedRectangle(cornerRadius: 2, style: .continuous)
                            .fill(n <= spiceLevel ? Color.kaaramSpice : Color.kaaramHairline)
                            .frame(height: 22)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, Spacing.s)
        }
    }

    private var dietsCard: some View {
        card(title: "Diets") {
            FlowLayout(spacing: 8) {
                ForEach(allDiets, id: \.self) { d in
                    let on = selectedDiets.contains(d)
                    Button {
                        if on { selectedDiets.remove(d) } else { selectedDiets.insert(d) }
                    } label: {
                        Chip(text: d, style: on ? .ink : .outline)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var regionsCard: some View {
        card(title: "Regions you love") {
            FlowLayout(spacing: 8) {
                ForEach(allRegions, id: \.self) { r in
                    let on = selectedRegions.contains(r)
                    Button {
                        if on { selectedRegions.remove(r) } else { selectedRegions.insert(r) }
                    } label: {
                        Chip(text: r, style: on ? .ink : .outline)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var aboutCard: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            KolamDivider()
            Text("About Kaaram")
                .font(.kaaramTitle)
                .foregroundStyle(Color.kaaramInk)
            Text("Kaaram — కారం — means ‘spice’ in Telugu. A small, opinionated collection of Telugu and Indian recipes, from everyday pappu to festival pulusu.")
                .font(.system(size: 14))
                .foregroundStyle(Color.kaaramInkSoft)
                .lineSpacing(3)
        }
        .padding(.top, Spacing.s)
    }

    // MARK: - Card scaffold

    @ViewBuilder
    private func card<Content: View>(
        title: String,
        trailing: String? = nil,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .font(.system(size: 17, weight: .medium, design: .serif))
                    .tracking(-0.2)
                    .foregroundStyle(Color.kaaramInk)
                Spacer()
                if let trailing {
                    MonoCap(trailing, color: .kaaramSpice)
                }
            }
            content()
        }
        .padding(Spacing.l)
        .background(Color.kaaramSurface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.kaaramHairline2, lineWidth: 1)
        )
    }
}

// MARK: - Simple flow layout

private struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .greatestFiniteMagnitude
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        for sub in subviews {
            let size = sub.sizeThatFits(.unspecified)
            if x + size.width > maxWidth {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        return CGSize(width: maxWidth, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0
        for sub in subviews {
            let size = sub.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            sub.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

#Preview {
    ProfileView()
}
