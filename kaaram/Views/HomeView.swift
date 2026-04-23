//
//  HomeView.swift
//  kaaram
//
//  Home tab — editorial layout. A warm, magazine-style page:
//  mono "day · month" eyebrow, serif greeting, a featured hero card,
//  a "Browse by dish" grid of category tiles, and a horizontal
//  "Weeknight tiffins" carousel separated by a kolam divider.
//

import SwiftData
import SwiftUI

struct HomeView: View {
    @State private var viewModel: HomeViewModel

    init(repository: RecipeRepository) {
        _viewModel = State(initialValue: HomeViewModel(repository: repository))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    header
                        .padding(.horizontal, Spacing.l)
                        .padding(.top, Spacing.s)

                    content
                }
                .padding(.bottom, Spacing.xxl)
            }
            .background(Color.kaaramBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: Recipe.self) { recipe in
                RecipeDetailView(recipe: recipe)
            }
            .refreshable { await viewModel.reload() }
        }
        .task { await viewModel.loadIfNeeded() }
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                MonoCap(Self.todayEyebrow)
                Text("Namaskaram")
                    .font(.kaaramDisplay)
                    .tracking(-0.6)
                    .foregroundStyle(Color.kaaramInk)
            }
            Spacer()

            Circle()
                .fill(Color.kaaramSurface2)
                .frame(width: 38, height: 38)
                .overlay(
                    Text("K")
                        .font(.system(size: 15, weight: .semibold, design: .serif))
                        .foregroundStyle(Color.kaaramSpice)
                )
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            loadingState
                .padding(.horizontal, Spacing.l)
        case .loaded(let recipes):
            loaded(recipes)
        case .empty:
            emptyState
                .padding(.horizontal, Spacing.l)
        case .error(let message):
            errorState(message)
                .padding(.horizontal, Spacing.l)
        }
    }

    private func loaded(_ recipes: [Recipe]) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xl) {
            if let featured = recipes.first {
                NavigationLink(value: featured) {
                    featureCard(featured)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, Spacing.l)
            }

            categoriesGrid(recipes)
                .padding(.horizontal, Spacing.l)

            KolamDivider()
                .padding(.horizontal, Spacing.l)

            tiffinsCarousel(recipes)
        }
    }

    // MARK: - Featured card

    private func featureCard(_ recipe: Recipe) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topLeading) {
                heroMedia(for: recipe)
                    .frame(height: 240)
                    .clipShape(
                        UnevenRoundedRectangle(
                            cornerRadii: .init(
                                topLeading: 24,
                                bottomLeading: 0,
                                bottomTrailing: 0,
                                topTrailing: 24
                            )
                        )
                    )

                Text("★ Editor's Pick")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.kaaramInk)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Color.kaaramSurface.opacity(0.92),
                        in: Capsule()
                    )
                    .padding(14)
            }

            VStack(alignment: .leading, spacing: Spacing.s) {
                MonoCap("\(recipe.region.displayName) · WEEKEND SPECIAL", color: .kaaramSpice)

                Text(recipe.nameEN)
                    .font(.system(size: 26, weight: .medium, design: .serif))
                    .tracking(-0.5)
                    .foregroundStyle(Color.kaaramInk)
                    .fixedSize(horizontal: false, vertical: true)

                if !recipe.summary.isEmpty {
                    Text(recipe.summary)
                        .font(.system(size: 14))
                        .foregroundStyle(Color.kaaramInkSoft)
                        .lineSpacing(2)
                        .lineLimit(2)
                }

                HStack(spacing: 18) {
                    if recipe.totalMinutes > 0 {
                        MetaRow(systemImage: "clock", label: "\(recipe.totalMinutes) min")
                    }
                    MetaRow(systemImage: "flame", label: recipe.region.displayName)
                    if recipe.servings > 0 {
                        MetaRow(systemImage: "fork.knife", label: "Serves \(recipe.servings)")
                    }
                }
                .padding(.top, 4)
            }
            .padding(18)
        }
        .background(
            Color.kaaramSurface,
            in: RoundedRectangle(cornerRadius: 24, style: .continuous)
        )
        .shadow(color: Color(red: 0.235, green: 0.118, blue: 0.039).opacity(0.08), radius: 16, y: 6)
    }

    @ViewBuilder
    private func heroMedia(for recipe: Recipe) -> some View {
        if let url = recipe.heroImageURL {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().aspectRatio(contentMode: .fill)
                default:
                    FoodPlaceholder(label: recipe.nameEN, note: "feature", cornerRadius: 0)
                }
            }
        } else {
            FoodPlaceholder(label: recipe.nameEN, note: "feature", cornerRadius: 0)
        }
    }

    // MARK: - Categories grid

    private func categoriesGrid(_ recipes: [Recipe]) -> some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            SectionHeader(title: "Browse by dish", trailing: "SEE ALL")

            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
                spacing: 10
            ) {
                ForEach(Array(recipes.prefix(6))) { recipe in
                    NavigationLink(value: recipe) {
                        RecipeCard(recipe: recipe, heroHeight: 68, flourish: false)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Tiffins carousel

    private func tiffinsCarousel(_ recipes: [Recipe]) -> some View {
        let tiffins = recipes.filter { $0.category == .tiffin || $0.category == .breakfast }
        let list = tiffins.isEmpty ? Array(recipes.prefix(6)) : Array(tiffins.prefix(6))

        return VStack(alignment: .leading, spacing: Spacing.m) {
            SectionHeader(title: "Weeknight tiffins", trailing: "\(list.count) RECIPES")
                .padding(.horizontal, Spacing.l)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 12) {
                    ForEach(list) { recipe in
                        NavigationLink(value: recipe) {
                            VStack(alignment: .leading, spacing: Spacing.s) {
                                heroMedia(for: recipe)
                                    .frame(width: 168, height: 140)
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                Text(recipe.nameEN)
                                    .font(.kaaramHeadline)
                                    .tracking(-0.2)
                                    .foregroundStyle(Color.kaaramInk)
                                    .lineLimit(1)
                                Text("\(recipe.totalMinutes > 0 ? "\(recipe.totalMinutes) min" : "—") · \(recipe.region.shortName)")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color.kaaramInkMuted)
                            }
                            .frame(width: 168, alignment: .leading)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, Spacing.l)
            }
        }
    }

    // MARK: - State screens

    private var loadingState: some View {
        VStack(spacing: Spacing.m) {
            ProgressView().tint(Color.kaaramSpice)
            Text("Loading recipes…")
                .font(.kaaramCallout)
                .foregroundStyle(Color.kaaramInkMuted)
        }
        .frame(maxWidth: .infinity, minHeight: 280)
    }

    private var emptyState: some View {
        VStack(spacing: Spacing.m) {
            Image(systemName: "tray")
                .font(.system(size: 40))
                .foregroundStyle(Color.kaaramInkMuted)
            Text("No recipes yet.")
                .font(.kaaramHeadline)
                .foregroundStyle(Color.kaaramInk)
            Text("Check back soon.")
                .font(.kaaramCallout)
                .foregroundStyle(Color.kaaramInkMuted)
        }
        .frame(maxWidth: .infinity, minHeight: 280)
    }

    private func errorState(_ message: String) -> some View {
        VStack(spacing: Spacing.m) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 36))
                .foregroundStyle(Color.kaaramSpice)
            Text("Something went wrong")
                .font(.kaaramHeadline)
                .foregroundStyle(Color.kaaramInk)
            Text(message)
                .font(.kaaramCallout)
                .foregroundStyle(Color.kaaramInkMuted)
                .multilineTextAlignment(.center)
            Button {
                Task { await viewModel.reload() }
            } label: {
                Text("Try again")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.kaaramBackground)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .background(Color.kaaramInk, in: Capsule())
            }
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 280)
    }

    // MARK: - Eyebrow

    private static var todayEyebrow: String {
        let df = DateFormatter()
        df.dateFormat = "EEEE"
        let day = df.string(from: Date()).uppercased()
        df.dateFormat = "MMMM"
        let month = df.string(from: Date()).uppercased()
        return "\(day) · \(month)"
    }
}

#Preview("Loaded") {
    HomeView(repository: MockRecipeRepository())
        .modelContainer(for: [FavoriteRecipe.self, RecipeNote.self, CachedRecipe.self], inMemory: true)
}

#Preview("Empty") {
    HomeView(repository: MockRecipeRepository(recipes: []))
        .modelContainer(for: [FavoriteRecipe.self, RecipeNote.self, CachedRecipe.self], inMemory: true)
}
