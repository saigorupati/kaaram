//
//  BrowseView.swift
//  kaaram
//
//  Explore tab — editorial, dense search surface. Serif "Explore" title
//  with a "N RECIPES" mono count, search pill, horizontal filter chips,
//  a category segmented control, then list rows. All filtering is
//  client-side over the cached recipe set.
//

import SwiftData
import SwiftUI

struct BrowseView: View {
    @State private var viewModel: BrowseViewModel

    @FocusState private var isSearchFocused: Bool

    init(repository: RecipeRepository) {
        _viewModel = State(initialValue: BrowseViewModel(repository: repository))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                header
                searchBar
                filterChips
                segmentedCategory
                content
            }
            .background(Color.kaaramBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: Recipe.self) { recipe in
                RecipeDetailView(recipe: recipe)
            }
        }
        .task { await viewModel.loadIfNeeded() }
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("Explore")
                .font(.kaaramDisplay)
                .tracking(-0.7)
                .foregroundStyle(Color.kaaramInk)
            Spacer()
            MonoCap("\(viewModel.allRecipes.count) RECIPES")
        }
        .padding(.horizontal, Spacing.l)
        .padding(.top, Spacing.s)
    }

    // MARK: - Search

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.kaaramInkMuted)

            TextField("", text: $viewModel.searchText, prompt: Text("Search \(max(viewModel.allRecipes.count, 1))+ recipes")
                .foregroundStyle(Color.kaaramInkMuted))
                .font(.system(size: 14.5))
                .foregroundStyle(Color.kaaramInk)
                .textInputAutocapitalization(.never)
                .focused($isSearchFocused)
                .submitLabel(.search)
                .onSubmit { viewModel.commitSearch() }

            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
                    isSearchFocused = false
                } label: {
                    Text("Cancel")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.kaaramInkMuted)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.kaaramSurface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.kaaramHairline2, lineWidth: 1)
        )
        .padding(.horizontal, Spacing.l)
        .padding(.top, Spacing.m)
    }

    // MARK: - Filter chips

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.s) {
                FilterChip(title: "All", isSelected: viewModel.selectedRegion == nil) {
                    viewModel.selectedRegion = nil
                }

                ForEach(Recipe.Region.allCases.filter { $0 != .other }, id: \.self) { region in
                    FilterChip(
                        title: region.shortName,
                        isSelected: viewModel.selectedRegion == region
                    ) {
                        viewModel.selectedRegion =
                            viewModel.selectedRegion == region ? nil : region
                    }
                }

                Rectangle().fill(Color.kaaramHairline).frame(width: 1, height: 18)
                    .padding(.horizontal, 2)

                ForEach(Self.quickTags, id: \.self) { tag in
                    FilterChip(
                        title: tag,
                        isSelected: viewModel.searchText == tag
                    ) {
                        viewModel.searchText = (viewModel.searchText == tag) ? "" : tag
                    }
                }
            }
            .padding(.horizontal, Spacing.l)
            .padding(.vertical, Spacing.m)
        }
    }

    // MARK: - Segmented category

    private var segmentedCategory: some View {
        HStack(spacing: 0) {
            ForEach(Self.segmentedCategories, id: \.self) { cat in
                let isSelected = viewModel.selectedCategory == cat
                Button {
                    viewModel.selectedCategory = isSelected ? nil : cat
                } label: {
                    Text(cat.displayName)
                        .font(.system(size: 11.5, weight: .semibold))
                        .tracking(0.2)
                        .foregroundStyle(isSelected ? Color.kaaramInk : Color.kaaramInkMuted)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 7)
                        .background(
                            Group {
                                if isSelected {
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .fill(Color.kaaramBackground)
                                        .shadow(color: .black.opacity(0.06), radius: 2, y: 1)
                                }
                            }
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(3)
        .background(
            Color.kaaramSurface2,
            in: RoundedRectangle(cornerRadius: 10, style: .continuous)
        )
        .padding(.horizontal, Spacing.l)
        .padding(.bottom, Spacing.m)
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            loadingState
        case .loaded:
            resultsList
        case .error(let message):
            errorState(message)
        }
    }

    @ViewBuilder
    private var resultsList: some View {
        let results = viewModel.results
        if results.isEmpty {
            noResultsState
        } else {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(results) { recipe in
                        NavigationLink(value: recipe) {
                            RecipeRow(recipe: recipe)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, Spacing.l)
                .padding(.bottom, Spacing.xl)
            }
        }
    }

    private var loadingState: some View {
        VStack(spacing: Spacing.m) {
            ProgressView().tint(Color.kaaramSpice)
            Text("Loading…")
                .font(.kaaramCallout)
                .foregroundStyle(Color.kaaramInkMuted)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private var noResultsState: some View {
        let isFiltering = !viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                          viewModel.hasActiveFilters
        VStack(spacing: Spacing.m) {
            Image(systemName: isFiltering ? "magnifyingglass" : "tray")
                .font(.system(size: 40))
                .foregroundStyle(Color.kaaramInkMuted)
            Text(isFiltering ? "No matches" : "No recipes yet")
                .font(.kaaramHeadline)
                .foregroundStyle(Color.kaaramInk)
            Text(isFiltering ? "Try a different word or clear filters." : "Check back soon.")
                .font(.kaaramCallout)
                .foregroundStyle(Color.kaaramInkMuted)
                .multilineTextAlignment(.center)
            if isFiltering {
                Button {
                    viewModel.searchText = ""
                    viewModel.clearFilters()
                } label: {
                    Text("Clear filters")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.kaaramSpice)
                        .padding(.top, Spacing.s)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Constants

    private static let quickTags = ["30 min", "Festive", "Sweet", "Breakfast"]

    private static let segmentedCategories: [Recipe.Category] = [
        .breakfast, .curry, .rice, .snack, .sweet
    ]
}

#Preview("Loaded") {
    BrowseView(repository: MockRecipeRepository())
        .modelContainer(for: [FavoriteRecipe.self, RecipeNote.self, CachedRecipe.self, UserPreferences.self], inMemory: true)
}

#Preview("Empty") {
    BrowseView(repository: MockRecipeRepository(recipes: []))
        .modelContainer(for: [FavoriteRecipe.self, RecipeNote.self, CachedRecipe.self, UserPreferences.self], inMemory: true)
}
