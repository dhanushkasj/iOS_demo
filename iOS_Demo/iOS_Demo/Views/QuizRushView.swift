//
//  QuizRushView.swift
//  iOS_Demo
//
//  Created by Dhanushka Jayakody on 2026-07-04.
//

import SwiftUI

struct QuizRushView: View {
    @StateObject private var viewModel = QuizRushViewModel()
    @AppStorage("highScore.quizRush") private var highScore = 0
    @AppStorage("settings.hapticsEnabled") private var hapticsEnabled = true
    @State private var isNewBest = false
    @Environment(\.dismiss) private var dismiss
    @Environment(SessionStore.self) private var sessions
    @Environment(LocationService.self) private var location

    private let accent: Color = .purple

    var body: some View {
        content
            .navigationTitle("Quiz Rush")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                if viewModel.items.isEmpty { await viewModel.load() }
            }
            .sensoryFeedback(trigger: viewModel.isShowingAnswer) { _, showing in
                guard hapticsEnabled, showing,
                      let item = viewModel.currentItem,
                      let selected = viewModel.selectedAnswer else { return nil }
                return selected == item.correctAnswer ? .success : .error
            }
            .onChange(of: viewModel.showResults) { _, showing in
                guard showing else { return }
                isNewBest = viewModel.score > highScore
                if isNewBest { highScore = viewModel.score }
                sessions.record(mode: .quizRush, score: viewModel.score, coordinate: location.lastCoordinate)
            }
            .fullScreenCover(isPresented: Binding(
                get: { viewModel.showResults },
                set: { if !$0 { viewModel.dismissResults() } }
            )) {
                GameResultsView(title: "Round Complete!",
                                score: viewModel.score,
                                best: highScore,
                                isNewBest: isNewBest) {
                    Task { await viewModel.load() }
                } onHome: {
                    dismiss()
                }
            }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            loadingView
        case .failed(let message):
            errorView(message)
        case .loaded:
            quizView
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .controlSize(.large)
            Text("Fetching questions…")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 52))
                .foregroundStyle(.secondary)
            Text("Couldn't load the quiz")
                .font(.title2.bold())
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button {
                Task { await viewModel.load() }
            } label: {
                Text("Retry")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 44)
                    .padding(.vertical, 12)
                    .background(accent, in: Capsule())
            }
            .padding(.top, 4)
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var quizView: some View {
        VStack(spacing: 20) {
            header

            if let item = viewModel.currentItem {
                Text(item.question)
                    .font(.title3.bold())
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.secondarySystemBackground),
                                in: RoundedRectangle(cornerRadius: 16))
                    .transition(.opacity)
                    .id(item.id)

                VStack(spacing: 12) {
                    ForEach(item.answers, id: \.self) { answer in
                        answerButton(answer, item: item)
                    }
                }
            }

            Spacer(minLength: 0)
        }
        .padding()
        .animation(.easeInOut(duration: 0.25), value: viewModel.index)
    }

    private var header: some View {
        VStack(spacing: 12) {
            HStack {
                stat("QUESTION", "\(viewModel.questionNumber) of \(viewModel.totalQuestions)")
                Spacer()
                stat("SCORE", "\(viewModel.score)")
                Spacer()
                stat("STREAK", streakLabel)
            }
            ProgressView(value: Double(viewModel.questionNumber),
                         total: Double(viewModel.totalQuestions))
                .tint(accent)
        }
    }

    private var streakLabel: String {
        viewModel.streak >= 2 ? "🔥 \(viewModel.streak)" : "\(viewModel.streak)"
    }

    private func stat(_ title: String, _ value: String) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title3.bold())
                .monospacedDigit()
        }
    }

    private func answerButton(_ answer: String, item: QuizItem) -> some View {
        let reveal = viewModel.isShowingAnswer
        let isCorrect = answer == item.correctAnswer
        let isSelected = viewModel.selectedAnswer == answer
        let isWrongPick = reveal && isSelected && !isCorrect

        let background: Color = {
            guard reveal else { return Color(.secondarySystemBackground) }
            if isCorrect { return .green }
            if isSelected { return .red }
            return Color(.secondarySystemBackground)
        }()
        let highlighted = reveal && (isCorrect || isSelected)

        return Button {
            viewModel.select(answer)
        } label: {
            HStack {
                Text(answer)
                    .font(.headline)
                    .multilineTextAlignment(.leading)
                Spacer(minLength: 8)
                if reveal && isCorrect {
                    Image(systemName: "checkmark.circle.fill")
                } else if isWrongPick {
                    Image(systemName: "xmark.circle.fill")
                }
            }
            .foregroundStyle(highlighted ? .white : .primary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(background, in: RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(.quaternary, lineWidth: highlighted ? 0 : 1)
            )
        }
        .buttonStyle(.plain)
        .disabled(reveal)
        .scaleEffect(reveal && isCorrect ? 1.04 : 1)
        .modifier(Shake(animatableData: isWrongPick ? 1 : 0))
        .animation(.easeInOut(duration: 0.2), value: reveal)
        .animation(.linear(duration: 0.4), value: isWrongPick)
    }
}

private struct Shake: GeometryEffect {
    var animatableData: CGFloat
    var amount: CGFloat = 8
    var shakes: CGFloat = 3

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(
            CGAffineTransform(translationX: amount * sin(animatableData * .pi * shakes),
                              y: 0)
        )
    }
}

#Preview {
    NavigationStack {
        QuizRushView()
    }
    .environment(SessionStore(context: PersistenceController(inMemory: true).viewContext))
    .environment(LocationService())
}
