//
//  BrowseView.swift
//  kaaram
//
//  Search & filter screen. Text search (.searchable in nav bar) +
//  region chip row below + toolbar menu combining Sort and Category.
//  All filtering happens client-side over the cached recipe set.
//

import SwiftUI

struct BrowseView: View {
    @State private var viewModel: BrowseViewModel

    init(repository: RecipeRepository) {
        _viewModel = State(initialValue: BrowseViewModel(repository: repository))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                regionFilterRow
                    .padding(.bottom, Spacing.s)

                content
            }
            .background(Color.kaaramBackground)
            .navigationTitle("Browse")
            .navigationBarTitleDisplayMode(.large)
            .searchable(
                text: $viewModel.searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search recipes, ingredients, tags"
            )
            .onSubmit(of: .search) {
                viewModel.commitSearch()
            }
            .searchSuggestions {
                recentSearchSuggestions
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    sortAndCategoryMenu
                }
            }
            .navigationDestination(for: Recipe.self) { recipe in
                RecipeDetailView(recipe: recipe)
            }
            .refreshable { await viewModel.reload() }
        }
        .task { await viewModel.loadIfNeeded() }
    }

    // MARK: - Region chips

    private var regionFilterRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.xs) {
                FilterChip(
                    title: "All",
                    isSelected: viewModel.selectedRegion == nil
                ) {
                    viewModel.selectedRegion = nil
                }

                ForEach(Recipe.Region.allCases.filter { $0 != .other }, id: \.self) { region in
                    FilterChip(
                        title: region.shortName,
                        isSelected: viewModel.selectedRegion == region
                    ) {
                        viewModel.selectedRegion =
                            (viewModel.selectedRegion == region) ? nil : region
                    }
                }
            }
            .padding(.horizontal, Spacing.l)
            .padding(.vertical, Spacing.s)
        }
    }

    // MARK: - Sort + Category menu

    private var sortAndCategoryMenu: some View {
        Menu {
            Section("Sort by") {
                Picker("Sort", selection: $viewModel.sort) {
                    ForEach(BrowseViewModel.Sort.allCases) { option in
                        Label(option.rawValue, systemImage: option.systemImage)
                            .tag(option)
                    }
                }
            }

            Section("Category") {
                Picker("Category", selection: $viewModel.selectedCategory) {
                    Text("All").tag(Recipe.Category?.none)
                    ForEach(Recipe.Category.allCases.filter { $0 != .other }, id: \.self) { category in
                        Text(category.displayName).tag(Recipe.Category?.some(category))
                    }
                }
            }

            if viewModel.hasActiveFilters {
                Divider()
                Button(role: .destructive) {
                    viewModel.clearFilters()
                } label: {
                    Label("Clear filters", systemImage: "xmark.circle")
                }
            }
        } label: {
            Image(systemName: viewModel.hasActiveFilters
                  ? "line.3.horizontal.decrease.circle.fill"
                  : "line.3.horizontal.decrease.circle")
                .foregroundStyle(
                    viewModel.hasActiveFilters ? Color.kaaramSpice : .primary
                )
        }
    }

    // MARK: - Search suggestions

    /// Rendered under the search field while focused. Shows recent
    /// searches (tap to fill and submit), with a Clear All row.
    @ViewBuilder
    private var recentSearchSuggestions: some View {
        if viewModel.searchText.isEmpty && !viewModel.recentSearches.isEmpty {
            ForEach(viewModel.recentSearches, id: \.self) { term in
                Label(term, systemImage: "clock.arrow.circlepath")
                    .searchCompletion(term)
            }

            Button(role: .destructive) {
                viewModel.clearRecents()
            } label: {
                Label("Clear recent searches", systemImage: "trash")
            }
        }
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

    private var loadingState: some View {
        VStack(spacing: Spacing.m) {
            ProgressView()
            Text("Loading recipes…")
                .font(.kaaramCallout)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private var resultsList: some View {
        let results = viewModel.results

        if results.isEmpty {
            noResultsState
        } else {
            ScrollView {
                LazyVStack(spacing: Spacing.m) {
                    ForEach(results) { recipe in
                        NavigationLink(value: recipe) {
                            BrowseRow(recipe: recipe)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, Spacing.l)
                .padding(.top, Spacing.xs)
                .padding(.bottom, Spacing.l)
            }
        }
    }

    @ViewBuilder
    private var noResultsState: some View {
        let isFiltering = !viewModel.searchText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty || viewModel.hasActiveFilters

        VStack(spacing: Spacing.m) {
            Image(systemName: isFiltering ? "magnifyingglass" : "tray")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text(isFiltering ? "No matches" : "No recipes yet")
                .font(.kaaramHeadline)

            Text(isFiltering
                 ? "Try a different word or clear filters."
                 : "Check back soon.")
                .font(.kaaramCallout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.xl)

            if isFiltering {
                Button("Clear filters") {
                    viewModel.searchText = ""
                    viewModel.clearFilters()
                }
                .font(.kaaramCallout)
                .padding(.top, Spacing.s)
                .foregroundStyle(Color.kaaramSpice)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func errorState(_ message: String) -> some View {
        VStack(spacing: Spacing.m) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundStyle(Color.kaaramSpice)
            Text("Something went wrong")
                .font(.kaaramHeadline)
            Text(message)
                .font(.kaaramCallout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Try again") {
                Task { await viewModel.reload() }
            }
            .buttonStyle(.borderedProminent)
            .tint(.kaaramSpice)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Row

/// Horizontal compact row optimized for dense scanning — different
/// from the Home grid's square RecipeCard.
private struct BrowseRow: View {
    let recipe: Recipe

    var body: some View {
        HStack(spacing: Spacing.m) {
            thumbnail

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(recipe.nameEN)
                    .font(.kaaramHeadline)
                    .lineLimit(1)
                if !recipe.nameTE.isEmpty {
                    Text(recipe.nameTE)
                        .font(.kaaramTelugu)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                HStack(spacing: Spacing.xs) {
                    Text(recipe.region.displayName)
                    if recipe.totalMinutes > 0 {
                        Text("·")
                        Text("\(recipe.totalMinutes) min")
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.footnote)
                .foregroundStyle(.tertiary)
        }
        .padding(Spacing.m)
        .background(
            Color.kaaramSurface,
            in: RoundedRectangle(cornerRadius: Radius.l, style: .continuous)
        )
    }

    @ViewBuilder
    private var thumbnail: some View {
        if let url = recipe.thumbnailImageURL ?? recipe.heroImageURL {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().aspectRatio(contentMode: .fill)
                default:
                    placeholderSquare
                }
            }
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: Radius.m, style: .continuous))
        } else {
            placeholderSquare
                .frame(width: 60, height: 60)
        }
    }

    private var placeholderSquare: some View {
        RoundedRectangle(cornerRadius: Radius.m, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [.kaaramSpice.opacity(0.4), .kaaramTurmeric.opacity(0.5)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay {
                Image(systemName: "fork.knife")
                    .font(.title3)
                    .foregroundStyle(.white)
            }
    }
}

// MARK: - Previews

#Preview("Loaded") {
    BrowseView(repository: MockRecipeRepository())
}

#Preview("Empty") {
    BrowseView(repository: MockRecipeRepository(recipes: []))
}
