//
//  CookingModeView.swift
//  kaaram
//
//  Full-screen, swipeable step-by-step cooking mode. Per the design,
//  the top chrome is a close-X on the left, a "{DISH} · STEP N / T"
//  mono eyebrow centered, and a clock affordance on the right; a 7-dot
//  progress strip runs beneath. Keep-awake while visible. Haptic on
//  every advance. A final Completion page is appended for a gratifying
//  finish.
//

import SwiftUI
import UIKit

struct CookingModeView: View {
    let recipe: Recipe

    @Environment(\.dismiss) private var dismiss
    @State private var currentIndex: Int = 0

    private let haptic = UIImpactFeedbackGenerator(style: .soft)

    private var totalPages: Int { recipe.steps.count + 1 }
    private var isOnCompletion: Bool { currentIndex == recipe.steps.count }

    var body: some View {
        ZStack(alignment: .top) {
            Color.kaaramBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header

                TabView(selection: $currentIndex) {
                    ForEach(Array(recipe.steps.enumerated()), id: \.offset) { index, step in
                        StepPageView(number: index + 1, total: recipe.steps.count, step: step)
                            .tag(index)
                    }
                    CompletionView(onDismiss: { dismiss() })
                        .tag(recipe.steps.count)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.snappy, value: currentIndex)

                if !isOnCompletion {
                    bottomNav
                }
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
        VStack(spacing: 16) {
            HStack(alignment: .center) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.kaaramInk)
                        .frame(width: 34, height: 34)
                }
                .accessibilityLabel("Close cooking mode")

                Spacer()

                MonoCap(eyebrow)

                Spacer()

                Image(systemName: "clock")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(Color.kaaramInk)
                    .frame(width: 34, height: 34)
            }
            .padding(.horizontal, Spacing.l)

            progressStrip
                .padding(.horizontal, Spacing.l)
        }
        .padding(.top, Spacing.s)
        .padding(.bottom, Spacing.m)
    }

    private var eyebrow: String {
        if isOnCompletion {
            return "\(recipe.nameEN.uppercased()) · DONE"
        }
        let n = String(format: "%02d", currentIndex + 1)
        let t = String(format: "%02d", recipe.steps.count)
        return "\(recipe.nameEN.uppercased()) · STEP \(n) / \(t)"
    }

    private var progressStrip: some View {
        HStack(spacing: 3) {
            ForEach(0..<recipe.steps.count, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .fill(index <= currentIndex ? Color.kaaramSpice : Color.kaaramHairline)
                    .frame(height: 3)
            }
        }
    }

    // MARK: - Bottom nav

    private var bottomNav: some View {
        HStack(spacing: 10) {
            Button {
                if currentIndex > 0 { currentIndex -= 1 }
            } label: {
                Text("← Previous")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.kaaramInk.opacity(currentIndex == 0 ? 0.35 : 1))
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.kaaramHairline, lineWidth: 1)
                    )
            }
            .disabled(currentIndex == 0)

            Button {
                if currentIndex < totalPages - 1 { currentIndex += 1 }
            } label: {
                Text(currentIndex == recipe.steps.count - 1 ? "Finish →" : "Next step →")
                    .font(.system(size: 15, weight: .semibold))
                    .tracking(-0.2)
                    .foregroundStyle(Color.kaaramBackground)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Color.kaaramInk, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
        }
        .padding(.horizontal, Spacing.l)
        .padding(.bottom, 26)
        .padding(.top, Spacing.m)
    }
}

#Preview {
    CookingModeView(recipe: .palakPaneer)
}
