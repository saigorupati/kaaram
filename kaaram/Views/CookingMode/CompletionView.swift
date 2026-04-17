//
//  CompletionView.swift
//  kaaram
//
//  Final page of cooking mode. Celebrates the cook and offers a Done
//  button that dismisses back to the recipe detail screen. Plays a
//  success haptic once when it appears.
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
                    .fill(Color.kaaramSpice.opacity(0.15))
                    .frame(width: 160, height: 160)

                Image(systemName: "checkmark")
                    .font(.system(size: 72, weight: .bold))
                    .foregroundStyle(Color.kaaramSpice)
            }

            VStack(spacing: Spacing.s) {
                Text("You did it!")
                    .font(.kaaramDisplay)
                    .foregroundStyle(Color.kaaramSpice)

                Text("Enjoy your meal.")
                    .font(.kaaramBody)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                onDismiss()
            } label: {
                Text("Done")
                    .font(.kaaramHeadline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        Color.kaaramSpice,
                        in: RoundedRectangle(cornerRadius: Radius.l, style: .continuous)
                    )
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
