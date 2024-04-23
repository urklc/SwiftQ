//
//  FirestoreAPI.swift
//  SwiftQ
//
//  Uğur Kılıç
//  www.linkedin.com/in/ugurkilic
//  www.youtube.com/@urklc
//

import Foundation
import Firebase
import FirebaseFunctions

enum FirestoreError: Error {
	case functions(Int, String)
	case decodeError(String)
	case unexpectedData
}

final class FirestoreAPI {
	lazy var functions = Functions.functions(region: "europe-west3")

	func retrieveNewQuestions(level: Int) async throws -> [Question] {
		return try await withCheckedThrowingContinuation { continuation in
			functions
				.httpsCallable("getUnansweredQuestions")
				.call(["level": level]) { [weak self] result, error in
					guard let self else { return }
					do {
						try self.check(error)
						let questions: [Question] = try self.parseResponse(result, "questions")
						continuation.resume(returning: questions)
					} catch {
						continuation.resume(throwing: error)
					}
				}
		}
	}

	func syncAnswers(_ answers: Set<StatQuestion>) async throws {
		guard let data = try? JSONEncoder().encode(answers),
			  let answersDict = try? JSONSerialization.jsonObject(with: data) else {
			return
		}
		try await withCheckedThrowingContinuation { continuation in
			functions
				.httpsCallable("syncAnswers")
				.call(["answers": answersDict]) { [weak self] _, error in
					guard let self else { return }
					do {
						try self.check(error)
						continuation.resume()
						print("Synchronizing answers done...")
					} catch {
						print("Synchronizing answers failed: \(error)")
						continuation.resume(throwing: error)
					}
				}
		}
	}

	func retrieveStats() async throws -> GroupedStats {
		return try await withCheckedThrowingContinuation { continuation in
			functions
				.httpsCallable("retrieveStats")
				.call { [weak self] result, error in
					guard let self else { return }
					do {
						try self.check(error)
						let stats: [GroupedStats] = try self.parseResponse(result, "stats")
						if stats.isEmpty {
							continuation.resume(returning: GroupedStats(correctMap: [:], wrongMap: [:]))
						} else {
							continuation.resume(returning: stats[0])
						}
						print("Retrieving stats done...")
					} catch {
						print("Retrieving stats failed: \(error)")
						continuation.resume(throwing: error)
					}
				}
		}
	}

	func saveUser(uid: String, email: String?) async throws {
		// TODO
	}

	func deleteUser() async throws {
        // TODO
        // TODO: Delete from apple also
		try await Task.sleep(nanoseconds: NSEC_PER_SEC * 3)
	}
}

private extension FirestoreAPI {
	func check(_ error: Error?) throws {
		if let error = error as NSError? {
			throw FirestoreError.functions(error.code, error.localizedDescription)
		}
	}

	func parseResponse<T: Decodable>(_ result: HTTPSCallableResult?, _ key: String) throws -> T {
		if let resultData = result?.data as? [String: Any],
		   let questionsData = resultData[key] {
			do {
				let jsonData = try JSONSerialization.data(withJSONObject: questionsData, options: [])
				return try JSONDecoder().decode(T.self, from: jsonData)
			} catch {
				throw FirestoreError.decodeError(error.localizedDescription)
			}
		}
		throw FirestoreError.unexpectedData
	}
}
