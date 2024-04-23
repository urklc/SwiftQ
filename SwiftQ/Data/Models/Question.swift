//
//  Question.swift
//  SwiftQ
//
//  Uğur Kılıç
//  www.linkedin.com/in/ugurkilic
//  www.youtube.com/@urklc
//

import Foundation

struct Question: Identifiable, Codable, Equatable, Hashable {
	enum CodingKeys: String, CodingKey {
		case id = "questionID"
		case answers
		case correctAnswerIndex
		case level
		case text
		case imageURL
		case answerExplanation
	}

	let id: String
	let level: QuestionLevel
	let text: String?
	let imageURL: URL?
	let answers: [String]
	let correctAnswerIndex: Int
	let answerExplanation: AnswerExplanation?

	var answersAreImages: Bool {
		return answers.first?.contains("https://") ?? false
	}

	static func == (lhs: Question, rhs: Question) -> Bool {
		lhs.id == rhs.id
	}

	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
		hasher.combine(level)
		hasher.combine(text)
	}
}
