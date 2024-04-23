//
//  String+Crypto.swift
//  SwiftQ @ 2023
// 
//  Uğur Kılıç 
//  www.linkedin.com/in/ugurkilic
//  www.youtube.com/@urklc
//

import CommonCrypto
import CryptoKit
import Foundation

extension String {
	static func randomNonce(length: Int = 32) -> String {
	  precondition(length > 0)
	  var randomBytes = [UInt8](repeating: 0, count: length)
	  let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
	  if errorCode != errSecSuccess {
		fatalError(
		  "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
		)
	  }

	  let charset: [Character] =
		Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

	  let nonce = randomBytes.map { byte in
		// Pick a random character from the set, wrapping around if needed.
		charset[Int(byte) % charset.count]
	  }

	  return String(nonce)
	}

	func sha256() -> String {
	  let inputData = Data(self.utf8)
	  let hashedData = SHA256.hash(data: inputData)
	  let hashString = hashedData.compactMap {
		String(format: "%02x", $0)
	  }.joined()

	  return hashString
	}
}
