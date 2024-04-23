//
//  QuizViewModel.swift
//  SwiftQ
//
//  Uğur Kılıç
//  www.linkedin.com/in/ugurkilic
//  www.youtube.com/@urklc
//

import Foundation

@MainActor
final class QuizViewModel: ObservableObject {
	private enum Constant {
		static let batchCount = 10
	}

	@Published var isLoading = false
	@Published var question: Question?
	@Published var errorString: String?

	var explanation: AnswerExplanation? {
		question?.answerExplanation
	}

	private let repository = Repository.shared

	private var questions: [Question] = []
	private var currentIndex: Int = 0
	private var level: QuestionLevel = .random

	func retrieveQuestions(level: QuestionLevel) async throws {
		self.level = level

		isLoading = true
		let newQuestions = try await repository.retrieveNewQuestions(level: level)

		questions.append(contentsOf: newQuestions)
		if questions.count > currentIndex {
			question = questions[currentIndex]
		} else {
			errorString = "You've completed all questions! Please come back later... :)"
		}
		isLoading = false
	}

	func set(answerIndex: Int) -> Bool {
		if let question {
			let isCorrect = question.correctAnswerIndex == answerIndex
			repository.saveAnswer(
				stat: StatQuestion(questionId: question.id, level: question.level, isCorrect: isCorrect)
			)
			return isCorrect
		}
		return false
	}

	func getNextQuestion() async throws {
		currentIndex += 1
		if questions.count > currentIndex {
			question = questions[currentIndex]
		} else {
			try await retrieveQuestions(level: level)
		}
	}

	func quit() {
		level = .random
		questions = []
		question = nil
		currentIndex = 0
	}

	func deleteAccount() async throws {
		isLoading = true
		try await repository.deleteUser()
		isLoading = false
	}

	func syncAnswers() {
		Task {
			try? await repository.syncAnswers()
		}
	}
}
