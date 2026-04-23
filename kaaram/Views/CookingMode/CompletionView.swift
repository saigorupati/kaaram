//
//  CompletionView.swift
//  kaaram
//
//  Final page of cooking mode. Soft celebration: a circled check mark
//  inside the chilli wash, serif "You did it!" headline, mono sub-label,
//  and a Done button. Plays a success haptic once when it appears.
//

import SwiftUI
import UIKit

struct CompletionView: View {
    let onDismiss: () -> Void

    @State private var didPlayHaptic = false

    var body: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.kaaramSpiceWash)
                    .frame(width: 160, height: 160)
                Circle()
                    .stroke(Color.kaaramSpice.opacity(0.25), lineWidth: 1)
                    .frame(width: 180, height: 180)
                Image(systemName: "checkmark")
                    .font(.system(size: 56, weight: .bold))
                    .foregroundStyle(Color.kaaramSpice)
            }

            VStack(spacing: Spacing.s) {
                MonoCap("DONE · ENJOY", color: .kaaramSpice)
                Text("You did it!")
                    .font(.system(size: 40, weight: .medium, design: .serif))
                    .tracking(-1.0)
                    .foregroundStyle(Color.kaaramInk)
                Text("Serve hot. Share generously.")
                    .font(.system(size: 14.5))
                    .foregroundStyle(Color.kaaramInkSoft)
            }

            Spacer()

            Button {
                onDismiss()
            } label: {
                Text("Done")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Color.kaaramSpice, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .padding(.horizontal, Spacing.xl)
            .padding(.bottom, Spacing.xl)
        }
        .onAppear {
            guard !didPlayHaptic else { return }
            didPlayHaptic = true
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }
}

#Preview {
    CompletionView(onDismiss: {})
        .background(Color.kaaramBackground)
}
