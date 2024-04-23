//
//  UserDefaults.swift
//  SwiftQ
//
//  Uğur Kılıç
//  www.linkedin.com/in/ugurkilic
//  www.youtube.com/@urklc
//

import Foundation

extension UserDefaults {
	func saveSetForKey<T: Encodable>(_ key: String, _ set: Set<T>) {
		guard let data = try? JSONEncoder().encode(set) else {
			return
		}
		UserDefaults.standard.setValue(data, forKey: key)
	}

	func setForKey<T: Decodable>(_ key: String) -> Set<T> {
		if let data = UserDefaults.standard.data(forKey: key) {
			return Set((try? JSONDecoder().decode([T].self, from: data)) ?? [])
		}
		return []
	}
}
