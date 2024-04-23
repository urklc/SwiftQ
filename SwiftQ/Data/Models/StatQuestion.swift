//
//  StatQuestion.swift
//  SwiftQ
//
//  Uğur Kılıç
//  www.linkedin.com/in/ugurkilic
//  www.youtube.com/@urklc
//

import Foundation

struct StatQuestion: Codable, Equatable, Hashable {
	enum CodingKeys: String, CodingKey {
		case questionId = "questionID"
		case level
		case isCorrect
	}
	let questionId: String
	let level: QuestionLevel
	let isCorrect: Bool

	static func == (lhs: StatQuestion, rhs: StatQuestion) -> Bool {
		lhs.questionId == rhs.questionId
	}
}
