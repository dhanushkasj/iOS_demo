//
//  TriviaService.swift
//  iOS_Demo
//
//  Created by Dhanushka Jayakody on 2026-07-04.
//

import Foundation

enum TriviaError: LocalizedError {
    case badURL
    case requestFailed
    case decodingFailed
    case emptyResults

    var errorDescription: String? {
        switch self {
        case .badURL:        return "Something went wrong building the request."
        case .requestFailed: return "Couldn't reach the trivia server. Check your connection."
        case .decodingFailed: return "The trivia server sent something unexpected."
        case .emptyResults:  return "No questions came back. Give it another go."
        }
    }
}

struct TriviaService {
    private let endpoint = "https://opentdb.com/api.php?amount=10&type=multiple"

    func fetchQuestions() async throws -> [TriviaQuestion] {
        guard let url = URL(string: endpoint) else { throw TriviaError.badURL }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(from: url)
        } catch {
            throw TriviaError.requestFailed
        }

        guard let http = response as? HTTPURLResponse,
              200..<300 ~= http.statusCode else {
            throw TriviaError.requestFailed
        }

        let decoded: TriviaResponse
        do {
            decoded = try JSONDecoder().decode(TriviaResponse.self, from: data)
        } catch {
            throw TriviaError.decodingFailed
        }

        guard decoded.responseCode == 0, !decoded.results.isEmpty else {
            throw TriviaError.emptyResults
        }

        return decoded.results
    }
}
