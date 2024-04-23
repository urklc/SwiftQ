//
//  StatsViewModel.swift
//  SwiftQ
//
//  Uğur Kılıç
//  www.linkedin.com/in/ugurkilic
//  www.youtube.com/@urklc
//

import Foundation

@MainActor
final class StatsViewModel: ObservableObject {
	@Published var stats: GroupedStats?

	private let repository = Repository.shared

	func retrieveStats() async throws {
		stats = (try? await repository.retrieveStats())
	}
}
