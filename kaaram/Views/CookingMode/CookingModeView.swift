//
//  CookingModeView.swift
//  kaaram
//
//  Full-screen, swipeable step-by-step cooking mode. Presented via
//  .fullScreenCover from RecipeDetailView so no nav chrome distracts
//  from the recipe.
//
//  Keep-awake is enabled while this screen is visible, then released
//  on dismiss. Haptic on every step advance. A final "Completion" page
//  is appended after the last real step for a gratifying finish.
//

import SwiftUI
import UIKit

struct CookingModeView: View {
    let recipe: Recipe

    @Environment(\.dismiss) private var dismiss
    @State private var currentIndex: Int = 0

    private let haptic = UIImpactFeedbackGenerator(style: .soft)

    /// Total pages = real steps + 1 for the completion screen.
    private var totalPages: Int { recipe.steps.count + 1 }

    var body: some View {
        ZStack(alignment: .top) {
            Color.kaaramBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header

                TabView(selection: $currentIndex) {
                    ForEach(Array(recipe.steps.enumerated()), id: \.offset) { index, step in
                        StepPageView(
                            number: index + 1,
                            total: recipe.steps.count,
                            step: step
                        )
                        .tag(index)
                    }

                    CompletionView(onDismiss: { dismiss() })
                        .tag(recipe.steps.count)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.snappy, value: currentIndex)
            }
        }
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
            haptic.prepare()
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
        }
        .onChange(of: currentIndex) { _, _ in
            haptic.impactOccurred()
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: Spacing.m) {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .frame(width: 40, height: 40)
                        .background(Color.kaaramSurface, in: Circle())
                }
                .accessibilityLabel("Close cooking mode")

                Spacer()

                Text(recipe.nameEN)
                    .font(.kaaramCallout)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                Spacer()

                // Right-side placeholder keeps the title visually centered.
                Color.clear.frame(width: 40, height: 40)
            }

            progressBar
        }
        .padding(.horizontal, Spacing.l)
        .padding(.top, Spacing.s)
        .padding(.bottom, Spacing.m)
    }

    private var progressBar: some View {
        HStack(spacing: Spacing.s) {
            ForEach(0..<recipe.steps.count, id: \.self) { index in
                Capsule()
                    .fill(
                        index <= currentIndex
                            ? Color.kaaramSpice
                            : Color.kaaramSpice.opacity(0.15)
                    )
                    .frame(height: 4)
            }
        }
    }
}

// MARK: - Previews

#Preview {
    CookingModeView(recipe: .palakPaneer)
}
