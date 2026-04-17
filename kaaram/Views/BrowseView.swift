//
//  BrowseView.swift
//  kaaram
//
//  Search & filter screen. Checkpoint 1 ships text search over the
//  cached recipe set; Checkpoint 2 will add filter chips and sort.
//

import SwiftUI

struct BrowseView: View {
    @State private var viewModel: BrowseViewModel

    init(repository: RecipeRepository) {
        _viewModel = State(initialValue: BrowseViewModel(repository: repository))
    }

    var body: some View {
        NavigationStack {
            content
                .background(Color.kaaramBackground)
                .navigationTitle("Browse")
                .navigationBarTitleDisplayMode(.large)
                .searchable(
                    text: $viewModel.searchText,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "Search recipes, ingredients, tags"
                )
                .navigationDestination(for: Recipe.self) { recipe in
                    RecipeDetailView(recipe: recipe)
                }
                .refreshable { await viewModel.reload() }
        }
        .task { await viewModel.loadIfNeeded() }
    }

    // MARK: - Subviews

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
                .padding(Spacing.l)
            }
        }
    }

    @ViewBuilder
    private var noResultsState: some View {
        let isSearching = !viewModel.searchText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty

        VStack(spacing: Spacing.m) {
            Image(systemName: isSearching ? "magnifyingglass" : "tray")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text(isSearching ? "No matches" : "No recipes yet")
                .font(.kaaramHeadline)

            Text(isSearching
                 ? "Try a different word — recipe names, ingredients, or tags."
                 : "Check back soon.")
                .font(.kaaramCallout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.xl)
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
