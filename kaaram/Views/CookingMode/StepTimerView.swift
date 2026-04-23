//
//  StepTimerView.swift
//  kaaram
//
//  Inline countdown timer for a step. Matches the cooking-mode mockup:
//  a circular chip on the left showing the time remaining in serif,
//  a title + subtitle in the middle ("Timer ready · Tap to start"),
//  and a large play/pause accent button on the right.
//

import SwiftUI

struct StepTimerView: View {
    @State private var model: StepTimerModel

    init(totalSeconds: Int) {
        _model = State(initialValue: StepTimerModel(totalSeconds: totalSeconds))
    }

    var body: some View {
        HStack(spacing: 18) {
            ZStack {
                Circle()
                    .stroke(Color.kaaramSpice, lineWidth: 3)
                    .frame(width: 72, height: 72)
                Text(Self.format(seconds: model.remainingSeconds))
                    .font(.system(size: 20, weight: .medium, design: .serif))
                    .tracking(-0.5)
                    .foregroundStyle(Color.kaaramInk)
                    .contentTransition(.numericText(countsDown: true))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .medium, design: .serif))
                    .tracking(-0.2)
                    .foregroundStyle(Color.kaaramInk)
                Text(subtitle)
                    .font(.system(size: 12.5))
                    .foregroundStyle(Color.kaaramInkMuted)
            }

            Spacer(minLength: 0)

            Button {
                model.toggle()
            } label: {
                Image(systemName: primaryIcon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 52, height: 52)
                    .background(Color.kaaramSpice, in: Circle())
                    .shadow(color: Color.kaaramSpice.opacity(0.25), radius: 6, y: 3)
            }
            .accessibilityLabel(primaryAccessibilityLabel)
        }
        .padding(20)
        .background(Color.kaaramSurface, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.kaaramHairline2, lineWidth: 1)
        )
        .contextMenu {
            Button(role: .destructive) { model.reset() } label: {
                Label("Reset timer", systemImage: "arrow.counterclockwise")
            }
        }
        .animation(.snappy, value: model.status)
    }

    private var title: String {
        switch model.status {
        case .idle:     return "Timer ready"
        case .running:  return "Running"
        case .paused:   return "Paused"
        case .finished: return "Done"
        }
    }

    private var subtitle: String {
        switch model.status {
        case .idle:     return "Tap to start · Vibrates when done"
        case .running:  return "Long-press to reset"
        case .paused:   return "Tap to resume"
        case .finished: return "Tap to restart"
        }
    }

    private var primaryIcon: String {
        switch model.status {
        case .idle, .paused: return "play.fill"
        case .running:       return "pause.fill"
        case .finished:      return "arrow.counterclockwise"
        }
    }

    private var primaryAccessibilityLabel: String {
        switch model.status {
        case .idle:     return "Start timer"
        case .running:  return "Pause timer"
        case .paused:   return "Resume timer"
        case .finished: return "Restart timer"
        }
    }

    private static func format(seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%d:%02d", m, s)
    }
}

#Preview("60 seconds") {
    StepTimerView(totalSeconds: 60)
        .padding()
        .background(Color.kaaramBackground)
}

#Preview("4 minutes") {
    StepTimerView(totalSeconds: 240)
        .padding()
        .background(Color.kaaramBackground)
}
