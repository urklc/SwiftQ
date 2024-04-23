//
//  QuestionLevel.swift
//  SwiftQ
//
//  Uğur Kılıç
//  www.linkedin.com/in/ugurkilic
//  www.youtube.com/@urklc
//

import Foundation

enum QuestionLevel: Int, Codable, CaseIterable {
	case beginner
	case intermediate
	case advanced
	case random

	var text: String {
		switch self {
		case .beginner:
			return "Beginner"
		case .intermediate:
			return "Intermediate"
		case .advanced:
			return "Advanced"
		case .random:
			return "Random"
		}
	}
}
