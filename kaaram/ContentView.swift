//
//  ContentView.swift
//  kaaram
//
//  Home screen. Fetches published recipes via HomeViewModel and renders
//  loading / loaded / empty / error states. Tapping a card pushes
//  RecipeDetailView (stub until Checkpoint 4).
//

import SwiftUI

struct ContentView: View {
    /// Repository injected via init so previews can pass a mock and the
    /// app can pass CloudKit. Default is CloudKit for the live build.
    @State private var viewModel: HomeViewModel

    init(repository: RecipeRepository = CloudKitRecipeRepository()) {
        _viewModel = State(initialValue: HomeViewModel(repository: repository))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    header
                    content
                    regions
                }
                .padding(Spacing.l)
            }
            .background(Color.kaaramBackground)
            .navigationTitle("Kaaram")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: Recipe.self) { recipe in
                RecipeDetailView(recipe: recipe)
            }
            .refreshable { await viewModel.reload() }
        }
        .task { await viewModel.loadIfNeeded() }
    }

    // MARK: - Subviews

    private var header: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("కారం")
                .font(.kaaramDisplay)
                .foregroundStyle(Color.kaaramSpice)
            Text("Telugu & South Indian recipes")
                .font(.kaaramBody)
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            loadingState
        case .loaded(let recipes):
            loadedGrid(recipes)
        case .empty:
            emptyState
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
        .frame(maxWidth: .infinity, minHeight: 280)
    }

    private func loadedGrid(_ recipes: [Recipe]) -> some View {
        VStack(alignment: .leading, spacing: Spacing.l) {
            SectionHeader(title: "Featured today")
            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: Spacing.m
            ) {
                ForEach(recipes) { recipe in
                    NavigationLink(value: recipe) {
                        RecipeCard(recipe: recipe)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: Spacing.m) {
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("No recipes yet.")
                .font(.kaaramHeadline)
            Text("Check back soon.")
                .font(.kaaramCallout)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 280)
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
        .frame(maxWidth: .infinity, minHeight: 280)
    }

    private var regions: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            SectionHeader(title: "Browse by region")
            HStack(spacing: Spacing.s) {
                Chip(text: "Andhra",       systemImage: "map",   style: .curry)
                Chip(text: "Telangana",    systemImage: "map",   style: .turmeric)
                Chip(text: "South Indian", systemImage: "globe", style: .spice)
            }
        }
    }
}

// MARK: - Previews

#Preview("Loaded") {
    ContentView(repository: MockRecipeRepository())
}

#Preview("Empty") {
    ContentView(repository: MockRecipeRepository(recipes: []))
}

#Preview("Error") {
    struct FailingRepo: RecipeRepository {
        func fetchPublished() async throws -> [Recipe] {
            throw RecipeRepositoryError.networkUnavailable
        }
        func fetchRecipe(slug: String) async throws -> Recipe {
            throw RecipeRepositoryError.notFound
        }
    }
    return ContentView(repository: FailingRepo())
}
