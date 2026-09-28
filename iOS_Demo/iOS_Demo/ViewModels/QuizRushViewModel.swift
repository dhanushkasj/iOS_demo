//
//  QuizRushViewModel.swift
//  iOS_Demo
//
//  Created by Dhanushka Jayakody on 2026-07-04.
//

import Foundation
import Combine

@MainActor
final class QuizRushViewModel: ObservableObject {

    enum ViewState {
        case loading
        case loaded
        case failed(String)
    }

    @Published private(set) var state: ViewState = .loading
    @Published private(set) var items: [QuizItem] = []
    @Published private(set) var index = 0
    @Published private(set) var score = 0
    @Published private(set) var streak = 0
    @Published private(set) var bestStreak = 0

    @Published private(set) var selectedAnswer: String?
    @Published private(set) var isShowingAnswer = false

    @Published var showResults = false

    let totalQuestions = 10
    private let service = TriviaService()
    private let basePoints = 10
    private let wrongPenalty = 5
    private let streakBonus = 2

    var currentItem: QuizItem? {
        items.indices.contains(index) ? items[index] : nil
    }

    var questionNumber: Int { min(index + 1, totalQuestions) }

    func load() async {
        state = .loading
        showResults = false
        resetProgress()

        do {
            let questions = try await service.fetchQuestions()
            items = questions.map(QuizItem.init(from:))
            state = .loaded
        } catch {
            let message = (error as? TriviaError)?.errorDescription
                ?? "Something went wrong. Please try again."
            state = .failed(message)
        }
    }

    func select(_ answer: String) {
        guard !isShowingAnswer, let item = currentItem else { return }

        selectedAnswer = answer
        isShowingAnswer = true

        if answer == item.correctAnswer {
            streak += 1
            bestStreak = max(bestStreak, streak)
            score += basePoints + max(0, streak - 1) * streakBonus
        } else {
            streak = 0
            score = max(0, score - wrongPenalty)
        }

        Task {
            try? await Task.sleep(for: .seconds(1.1))
            advance()
        }
    }

    private func advance() {
        guard isShowingAnswer else { return }
        selectedAnswer = nil
        isShowingAnswer = false

        if index + 1 >= items.count {
            showResults = true
        } else {
            index += 1
        }
    }

    func dismissResults() {
        showResults = false
    }

    private func resetProgress() {
        items = []
        index = 0
        score = 0
        streak = 0
        bestStreak = 0
        selectedAnswer = nil
        isShowingAnswer = false
    }
}
