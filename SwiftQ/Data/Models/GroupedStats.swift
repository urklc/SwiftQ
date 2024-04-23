//
//  GroupedStats.swift
//  SwiftQ
//
//  Uğur Kılıç
//  www.linkedin.com/in/ugurkilic
//  www.youtube.com/@urklc
//

import Foundation

struct GroupedStats: Codable, Equatable {
	let correctMap: [Int: Int]
	let wrongMap: [Int: Int]

	static func == (lhs: GroupedStats, rhs: GroupedStats) -> Bool {
		lhs.correctMap == rhs.correctMap && lhs.wrongMap == rhs.wrongMap
	}
}
