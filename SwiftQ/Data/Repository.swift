//
//  Database.swift
//  SwiftQ
//
//  Uğur Kılıç
//  www.linkedin.com/in/ugurkilic
//  www.youtube.com/@urklc
//

import Foundation

final class Repository {

	static let shared = Repository()

	private let firestore = FirestoreAPI()
	private var statsToSync: Set<StatQuestion> = []

	func retrieveNewQuestions(level: QuestionLevel) async throws -> [Question] {
		try await syncAnswers()
		return try await firestore.retrieveNewQuestions(level: level.rawValue)
	}

	func syncAnswers() async throws {
		try await firestore.syncAnswers(statsToSync)
		statsToSync = []
	}

	func retrieveStats() async throws -> GroupedStats {
		try await syncAnswers()
		return try await firestore.retrieveStats()
	}

	func saveUser(uid: String, email: String?) async throws {
		try await firestore.saveUser(uid: uid, email: email)
	}

	func deleteUser() async throws {
		try await firestore.deleteUser()
	}
}

// MARK: - Local State

extension Repository {
	func saveAnswer(stat: StatQuestion) {
		statsToSync.insert(stat)
	}
}
