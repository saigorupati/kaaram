//
//  ProfileView.swift
//  kaaram
//
//  The Profile tab. Reads a single-row UserPreferences model (synced to
//  the user's CloudKit private DB alongside favorites and notes) and
//  writes preferences back as the user toggles chips / taps the spice
//  bar. On first launch — when no row exists — a default row is
//  inserted so the UI has something to bind to.
//
//  Tap the header (avatar + name) to edit the display name via
//  NameEditorSheet. Tapping a chip toggles membership in the
//  diets / regions arrays. Tapping a spice bar sets the level 1–4.
//

import SwiftData
import SwiftUI

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \UserPreferences.updatedAt, order: .reverse)
    private var rows: [UserPreferences]

    @State private var isNameEditorPresented = false
    @State private var nameDraft: String = ""

    // Choice lists — kept static so they live outside the model.
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
        .task { bootstrapIfNeeded() }
        .sheet(isPresented: $isNameEditorPresented) {
            NameEditorSheet(name: $nameDraft) { newValue in
                guard let row = currentOrBootstrap() else { return }
                row.displayName = newValue
                row.updatedAt = Date()
                try? modelContext.save()
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        Button {
            nameDraft = prefs?.displayName ?? ""
            isNameEditorPresented = true
        } label: {
            HStack(alignment: .center, spacing: Spacing.m) {
                Circle()
                    .fill(Color.kaaramSpiceWash)
                    .frame(width: 56, height: 56)
                    .overlay(
                        Text(avatarLetter)
                            .font(.system(size: 22, weight: .semibold, design: .serif))
                            .foregroundStyle(Color.kaaramSpice)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    MonoCap("YOUR PROFILE")
                    Text(displayNameOrPlaceholder)
                        .font(.kaaramDisplay)
                        .tracking(-0.6)
                        .foregroundStyle(hasName ? Color.kaaramInk : Color.kaaramInkMuted)
                }
                Spacer()

                Image(systemName: "pencil")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.kaaramInkMuted)
            }
        }
        .buttonStyle(.plain)
    }

    private var avatarLetter: String {
        guard
            let first = prefs?.displayName
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .first
        else {
            return "·"
        }
        return String(first).uppercased()
    }

    private var displayNameOrPlaceholder: String {
        let trimmed = (prefs?.displayName ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Tap to add your name" : trimmed
    }

    private var hasName: Bool {
        !(prefs?.displayName ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty
    }

    // MARK: - Spice

    private var spiceCard: some View {
        let level = prefs?.spiceLevel ?? 2
        return card(title: "Spice tolerance", trailing: spiceLabels[clamp(level) - 1]) {
            HStack(spacing: 6) {
                ForEach(1...4, id: \.self) { n in
                    Button {
                        setSpice(level: n)
                    } label: {
                        RoundedRectangle(cornerRadius: 2, style: .continuous)
                            .fill(n <= level ? Color.kaaramSpice : Color.kaaramHairline)
                            .frame(height: 22)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, Spacing.s)
        }
    }

    // MARK: - Diets

    private var dietsCard: some View {
        let selected = Set(prefs?.diets ?? [])
        return card(title: "Diets") {
            FlowLayout(spacing: 8) {
                ForEach(allDiets, id: \.self) { d in
                    let on = selected.contains(d)
                    Button {
                        toggleDiet(d)
                    } label: {
                        Chip(text: d, style: on ? .ink : .outline)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Regions

    private var regionsCard: some View {
        let selected = Set(prefs?.regions ?? [])
        return card(title: "Regions you love") {
            FlowLayout(spacing: 8) {
                ForEach(allRegions, id: \.self) { r in
                    let on = selected.contains(r)
                    Button {
                        toggleRegion(r)
                    } label: {
                        Chip(text: r, style: on ? .ink : .outline)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - About

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

    // MARK: - Data plumbing

    private var prefs: UserPreferences? { rows.first }

    /// Ensure at least one row exists; returns the row we should write to.
    @discardableResult
    private func currentOrBootstrap() -> UserPreferences? {
        if let existing = rows.first { return existing }
        let new = UserPreferences()
        modelContext.insert(new)
        try? modelContext.save()
        return new
    }

    private func bootstrapIfNeeded() {
        guard rows.isEmpty else { return }
        currentOrBootstrap()
    }

    private func setSpice(level: Int) {
        guard let row = currentOrBootstrap() else { return }
        row.spiceLevel = clamp(level)
        row.updatedAt = Date()
        try? modelContext.save()
    }

    private func toggleDiet(_ d: String) {
        guard let row = currentOrBootstrap() else { return }
        if row.diets.contains(d) {
            row.diets.removeAll { $0 == d }
        } else {
            row.diets.append(d)
        }
        row.updatedAt = Date()
        try? modelContext.save()
    }

    private func toggleRegion(_ r: String) {
        guard let row = currentOrBootstrap() else { return }
        if row.regions.contains(r) {
            row.regions.removeAll { $0 == r }
        } else {
            row.regions.append(r)
        }
        row.updatedAt = Date()
        try? modelContext.save()
    }

    private func clamp(_ n: Int) -> Int {
        min(4, max(1, n))
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

#Preview("Empty (first run)") {
    ProfileView()
        .modelContainer(for: [FavoriteRecipe.self, RecipeNote.self, CachedRecipe.self, UserPreferences.self], inMemory: true)
}

#Preview("Seeded") {
    let container = try! ModelContainer(
        for: FavoriteRecipe.self, RecipeNote.self, CachedRecipe.self, UserPreferences.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    container.mainContext.insert(
        UserPreferences(
            displayName: "Sai",
            spiceLevel: 3,
            diets: ["Vegetarian"],
            regions: ["Telangana", "Andhra"]
        )
    )
    return ProfileView()
        .modelContainer(container)
}
