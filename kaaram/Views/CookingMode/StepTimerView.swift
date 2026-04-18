//
//  StepTimerView.swift
//  kaaram
//
//  Countdown timer for a step. Big ring + monospaced time + three
//  controls (reset / primary / placeholder-for-symmetry). Success
//  haptic is fired by StepTimerModel when the countdown hits zero.
//

import SwiftUI

struct StepTimerView: View {
    @State private var model: StepTimerModel

    init(totalSeconds: Int) {
        _model = State(initialValue: StepTimerModel(totalSeconds: totalSeconds))
    }

    var body: some View {
        VStack(spacing: Spacing.xl) {
            ring
            controls
        }
        .animation(.snappy, value: model.status)
    }

    // MARK: - Ring

    private var ring: some View {
        ZStack {
            // Track
            Circle()
                .stroke(Color.kaaramSpice.opacity(0.15), lineWidth: 12)

            // Progress arc
            Circle()
                .trim(from: 0, to: model.progress)
                .stroke(
                    Color.kaaramSpice,
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: model.remainingSeconds)

            // Time readout
            VStack(spacing: Spacing.xs) {
                Text(Self.format(seconds: model.remainingSeconds))
                    .font(.system(.largeTitle, design: .rounded).monospacedDigit())
                    .fontWeight(.semibold)
                    .contentTransition(.numericText(countsDown: true))

                statusLabel
            }
        }
        .frame(width: 200, height: 200)
    }

    @ViewBuilder
    private var statusLabel: some View {
        switch model.status {
        case .idle:
            Text("Ready")
                .font(.caption)
                .foregroundStyle(.secondary)
        case .running:
            Text("Running")
                .font(.caption)
                .foregroundStyle(Color.kaaramSpice)
        case .paused:
            Text("Paused")
                .font(.caption)
                .foregroundStyle(.secondary)
        case .finished:
            Text("Done")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.kaaramSpice)
        }
    }

    // MARK: - Controls

    private var controls: some View {
        HStack(spacing: Spacing.xl) {
            // Reset (left)
            Button {
                model.reset()
            } label: {
                Image(systemName: "arrow.counterclockwise")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 56, height: 56)
                    .background(Color.kaaramSurface, in: Circle())
                    .overlay(
                        Circle().stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                    )
            }
            .accessibilityLabel("Reset timer")
            .disabled(model.status == .idle)
            .opacity(model.status == .idle ? 0.35 : 1)

            // Primary (center)
            Button {
                model.toggle()
            } label: {
                Image(systemName: primaryIcon)
                    .font(.title.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 72, height: 72)
                    .background(Color.kaaramSpice, in: Circle())
                    .shadow(color: Color.kaaramSpice.opacity(0.35), radius: 8, y: 4)
            }
            .accessibilityLabel(primaryAccessibilityLabel)

            // Symmetry placeholder
            Color.clear.frame(width: 56, height: 56)
        }
    }

    private var primaryIcon: String {
        switch model.status {
        case .idle, .paused: "play.fill"
        case .running:       "pause.fill"
        case .finished:      "arrow.counterclockwise"
        }
    }

    private var primaryAccessibilityLabel: String {
        switch model.status {
        case .idle:     "Start timer"
        case .running:  "Pause timer"
        case .paused:   "Resume timer"
        case .finished: "Restart timer"
        }
    }

    // MARK: - Formatting

    private static func format(seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%d:%02d", m, s)
    }
}

#Preview("Running (60s)") {
    StepTimerView(totalSeconds: 60)
        .padding()
        .background(Color.kaaramBackground)
}

#Preview("Long (7m)") {
    StepTimerView(totalSeconds: 420)
        .padding()
        .background(Color.kaaramBackground)
}
