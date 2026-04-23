//
//  StepTimerModel.swift
//  kaaram
//
//  Observable countdown backing a StepTimerView. Driven by a 1-second
//  async Task that decrements `remainingSeconds` on the main actor.
//
//  Background behavior (v1): when the app is suspended, the Task stops
//  ticking and the timer effectively pauses. When the app resumes, it
//  picks up from where it left off. A future improvement: wall-clock
//  math + local notifications for true background completion alerts.
//

import Foundation
import Observation
import UIKit

@Observable
@MainActor
final class StepTimerModel {
    enum Status: Equatable {
        case idle
        case running
        case paused
        case finished
    }

    let totalSeconds: Int
    private(set) var remainingSeconds: Int
    private(set) var status: Status = .idle

    @ObservationIgnored
    private var tickerTask: Task<Void, Never>?

    init(totalSeconds: Int) {
        self.totalSeconds = max(0, totalSeconds)
        self.remainingSeconds = self.totalSeconds
    }

    /// 0.0 ... 1.0 — fraction of the countdown completed.
    var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return 1.0 - Double(remainingSeconds) / Double(totalSeconds)
    }

    // MARK: - Control

    func toggle() {
        switch status {
        case .idle, .paused: start()
        case .running:       pause()
        case .finished:      reset()
        }
    }

    func start() {
        guard status != .running else { return }
        guard remainingSeconds > 0 else { return }
        status = .running
        tickerTask?.cancel()
        tickerTask = Task { [weak self] in
            while let self {
                try? await Task.sleep(for: .seconds(1))
                if Task.isCancelled { return }
                self.tick()
                if self.status != .running { return }
            }
        }
    }

    func pause() {
        guard status == .running else { return }
        tickerTask?.cancel()
        tickerTask = nil
        status = .paused
    }

    func reset() {
        tickerTask?.cancel()
        tickerTask = nil
        remainingSeconds = totalSeconds
        status = .idle
    }

    // MARK: - Private

    private func tick() {
        guard status == .running else { return }
        if remainingSeconds > 0 {
            remainingSeconds -= 1
        }
        if remainingSeconds == 0 {
            status = .finished
            tickerTask?.cancel()
            tickerTask = nil
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }

    deinit {
        tickerTask?.cancel()
    }
}
