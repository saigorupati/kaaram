//
//  ContentView.swift
//  kaaram
//
//  Home screen placeholder. Renders the design system against mock
//  recipe data — Phase 1 swaps the mocks for a CloudKit-backed repository.
//

import SwiftUI

struct ContentView: View {
    // Mock data — replaced in Phase 1.
    private let featured: [RecipeCardModel] = [
        .init(nameEN: "Pappu", nameTE: "పప్పు", romanized: "pappu",
              region: "Andhra", totalMinutes: 25, heroSystemImage: "bowl.fill"),
        .init(nameEN: "Pulihora", nameTE: "పులిహోర", romanized: "pulihora",
              region: "South Indian", totalMinutes: 30, heroSystemImage: "leaf.fill"),
        .init(nameEN: "Gongura Pachadi", nameTE: "గోంగూర పచ్చడి", romanized: "gongura pachadi",
              region: "Andhra", totalMinutes: 40, heroSystemImage: "flame.fill"),
        .init(nameEN: "Bobbatlu", nameTE: "బొబ్బట్లు", romanized: "bobbatlu",
              region: "Telangana", totalMinutes: 90, heroSystemImage: "moon.stars.fill")
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    header

                    SectionHeader(title: "Featured today", action: {})
                    LazyVGrid(
                        columns: [GridItem(.flexible()), GridItem(.flexible())],
                        spacing: Spacing.m
                    ) {
                        ForEach(featured) { RecipeCard(recipe: $0) }
                    }

                    SectionHeader(title: "Browse by region")
                    HStack(spacing: Spacing.s) {
                        Chip(text: "Andhra",       systemImage: "map",   style: .curry)
                        Chip(text: "Telangana",    systemImage: "map",   style: .turmeric)
                        Chip(text: "South Indian", systemImage: "globe", style: .spice)
                    }
                }
                .padding(Spacing.l)
            }
            .background(Color.kaaramBackground)
            .navigationTitle("Kaaram")
            .navigationBarTitleDisplayMode(.large)
        }
    }

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
}

#Preview {
    ContentView()
}
