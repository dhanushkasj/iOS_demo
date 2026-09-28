//
//  TapFrenzyViewModel.swift
//  iOS_Demo
//
//  Created by Dhanushka Jayakody on 2026-06-06.
//

import SwiftUI

@Observable
final class TapFrenzyViewModel {
    var countDown: Double = 10
    var tappedCount = 0
    var isRunning = false
    var showResults = false
    var multiplier = 1
    var mode: TapMode = .bonus

    var buttonPosition = CGPoint(x: 0.5, y: 0.5)

    var progress: Double { max(0, min(1, countDown / duration)) }

    private let duration: Double = 10
    private let windowLength: Double = 0.5
    private let switchInterval: ClosedRange<Double> = 1.5...3.0
    private let moveInterval: Double = 2
    private var startedAt: Date?
    private var currentWindow = -1
    private var nextSwitchAt: Date?
    private var nextMoveAt: Date?
    private var timerTask: Task<Void, Never>?

    func tap() {
        if !isRunning {
            begin()
        }
        guard let startedAt else { return }

        let window = Int(Date().timeIntervalSince(startedAt) / windowLength)
        if window == currentWindow {
            multiplier += 1
        } else {
            multiplier = 1
            currentWindow = window
        }

        switch mode {
        case .bonus:
            tappedCount += multiplier * 2
        case .penalty:
            tappedCount = max(0, tappedCount - multiplier)
        }
    }

    func begin() {
        isRunning = true
        countDown = duration
        multiplier = 1
        currentWindow = -1
        mode = .bonus
        buttonPosition = CGPoint(x: 0.5, y: 0.5)

        let begin = Date()
        startedAt = begin
        nextSwitchAt = begin.addingTimeInterval(Double.random(in: switchInterval))
        nextMoveAt = begin.addingTimeInterval(moveInterval)
        let endDate = begin.addingTimeInterval(duration)

        timerTask?.cancel()
        timerTask = Task { @MainActor in
            while !Task.isCancelled {
                let now = Date()
                let remaining = endDate.timeIntervalSinceNow
                if remaining <= 0 { break }
                countDown = remaining

                if let next = nextSwitchAt, now >= next {
                    mode = (mode == .bonus) ? .penalty : .bonus
                    nextSwitchAt = now.addingTimeInterval(Double.random(in: switchInterval))
                }

                if let next = nextMoveAt, now >= next {
                    buttonPosition = CGPoint(x: Double.random(in: 0...1),
                                             y: Double.random(in: 0...1))
                    nextMoveAt = now.addingTimeInterval(moveInterval)
                }

                let window = Int(now.timeIntervalSince(begin) / windowLength)
                if window != currentWindow {
                    multiplier = 1
                }

                do {
                    try await Task.sleep(for: .milliseconds(16))
                } catch {
                    return
                }
            }

            guard !Task.isCancelled else { return }
            countDown = 0
            isRunning = false
            showResults = true
        }
    }

    func reset() {
        timerTask?.cancel()
        tappedCount = 0
        countDown = duration
        isRunning = false
        multiplier = 1
        currentWindow = -1
        startedAt = nil
        nextSwitchAt = nil
        nextMoveAt = nil
        mode = .bonus
        buttonPosition = CGPoint(x: 0.5, y: 0.5)
    }
}
