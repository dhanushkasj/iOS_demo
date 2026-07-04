//
//  TriviaModels.swift
//  iOS_Demo
//
//  Created by Dhanushka Jayakody on 2026-07-04.
//

import Foundation

struct TriviaResponse: Codable {
    let responseCode: Int
    let results: [TriviaQuestion]

    enum CodingKeys: String, CodingKey {
        case responseCode = "response_code"
        case results
    }
}

struct TriviaQuestion: Codable {
    let category: String
    let difficulty: String
    let question: String
    let correctAnswer: String
    let incorrectAnswers: [String]

    enum CodingKeys: String, CodingKey {
        case category, difficulty, question
        case correctAnswer = "correct_answer"
        case incorrectAnswers = "incorrect_answers"
    }
}

struct QuizItem: Identifiable {
    let id = UUID()
    let question: String
    let correctAnswer: String
    let answers: [String]

    init(from question: TriviaQuestion) {
        self.question = question.question.htmlDecoded
        self.correctAnswer = question.correctAnswer.htmlDecoded
        self.answers = ([question.correctAnswer] + question.incorrectAnswers)
            .map(\.htmlDecoded)
            .shuffled()
    }
}

extension String {
    var htmlDecoded: String {
        guard contains("&") else { return self }

        var result = ""
        result.reserveCapacity(count)
        var i = startIndex

        while i < endIndex {
            let ch = self[i]
            if ch == "&",
               let semi = self[i...].firstIndex(of: ";"),
               distance(from: i, to: semi) <= 12 {
                let entity = String(self[index(after: i)..<semi])
                if let decoded = String.decodeEntity(entity) {
                    result.append(decoded)
                    i = index(after: semi)
                    continue
                }
            }
            result.append(ch)
            i = index(after: i)
        }
        return result
    }

    private static func decodeEntity(_ entity: String) -> String? {
        if entity.hasPrefix("#") {
            let numPart = entity.dropFirst()
            let value: UInt32?
            if numPart.hasPrefix("x") || numPart.hasPrefix("X") {
                value = UInt32(numPart.dropFirst(), radix: 16)
            } else {
                value = UInt32(numPart)
            }
            if let value, let scalar = Unicode.Scalar(value) {
                return String(scalar)
            }
            return nil
        }
        return namedEntities[entity]
    }

    private static let namedEntities: [String: String] = [
        "quot": "\"", "amp": "&", "apos": "'", "lt": "<", "gt": ">",
        "nbsp": "\u{00A0}", "copy": "©", "reg": "®", "trade": "™",
        "hellip": "…", "mdash": "—", "ndash": "–",
        "lsquo": "\u{2018}", "rsquo": "\u{2019}", "ldquo": "\u{201C}", "rdquo": "\u{201D}",
        "laquo": "«", "raquo": "»", "deg": "°", "plusmn": "±",
        "times": "×", "divide": "÷", "frac12": "½", "frac14": "¼", "frac34": "¾",
        "sup1": "¹", "sup2": "²", "sup3": "³", "micro": "µ", "para": "¶", "sect": "§",
        "eacute": "é", "egrave": "è", "ecirc": "ê", "euml": "ë",
        "aacute": "á", "agrave": "à", "acirc": "â", "atilde": "ã", "auml": "ä", "aring": "å", "aelig": "æ",
        "ccedil": "ç", "iacute": "í", "igrave": "ì", "icirc": "î", "iuml": "ï",
        "ntilde": "ñ", "oacute": "ó", "ograve": "ò", "ocirc": "ô", "otilde": "õ", "ouml": "ö", "oslash": "ø",
        "uacute": "ú", "ugrave": "ù", "ucirc": "û", "uuml": "ü",
        "yacute": "ý", "yuml": "ÿ", "szlig": "ß",
        "Eacute": "É", "Egrave": "È", "Ecirc": "Ê", "Euml": "Ë",
        "Aacute": "Á", "Agrave": "À", "Acirc": "Â", "Atilde": "Ã", "Auml": "Ä", "Aring": "Å", "AElig": "Æ",
        "Ccedil": "Ç", "Iacute": "Í", "Igrave": "Ì", "Icirc": "Î", "Iuml": "Ï",
        "Ntilde": "Ñ", "Oacute": "Ó", "Ograve": "Ò", "Ocirc": "Ô", "Otilde": "Õ", "Ouml": "Ö", "Oslash": "Ø",
        "Uacute": "Ú", "Ugrave": "Ù", "Ucirc": "Û", "Uuml": "Ü", "Yacute": "Ý"
    ]
}
