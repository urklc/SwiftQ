//
//  LoginViewModel.swift
//  SwiftQ @ 2023
// 
//  Uğur Kılıç 
//  www.linkedin.com/in/ugurkilic
//  www.youtube.com/@urklc
//

import AuthenticationServices
import Firebase
import Foundation
import GoogleSignIn

@MainActor
final class LoginViewModel: ObservableObject {
	@Published var user: User?
	@Published var loginError: String?

	private let repository = Repository.shared
	private var currentAppleNonce = ""

	init() {
		user = Auth.auth().currentUser
	}

	func prepare(_ request: ASAuthorizationAppleIDRequest) {
		DispatchQueue.main.async {
			self.loginError = nil
		}

		request.requestedScopes = [.email, .fullName]
		currentAppleNonce = String.randomNonce()
		request.nonce = currentAppleNonce.sha256()
	}

	func login(result: Result<ASAuthorization, Error>) {
		switch result {
		case .success(let result):
			if let appleIDCredential = result.credential as? ASAuthorizationAppleIDCredential {
				guard let appleIDToken = appleIDCredential.identityToken else {
					DispatchQueue.main.async {
						self.loginError = "Unable to fetch identity token"
					}
					return
				}
				guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
					DispatchQueue.main.async {
						self.loginError = "Unable to serialize token string from data: \(appleIDToken.debugDescription)"
					}
					return
				}

				let credential = OAuthProvider.appleCredential(
					withIDToken: idTokenString,
					rawNonce: currentAppleNonce,
					fullName: appleIDCredential.fullName)
				Auth.auth().signIn(with: credential) { (authResult, error) in
					self.handleUser(authResult?.user, error)
				}

			}

		case .failure(let error):
			loginError = error.localizedDescription
		}
	}

	func login(result: GIDSignInResult) {
		guard let idToken = result.user.idToken?.tokenString else {
			DispatchQueue.main.async {
				self.loginError = "User token not retrieved!"
			}
			return
		}

		let credential = GoogleAuthProvider.credential(
			withIDToken: idToken,
			accessToken: result.user.accessToken.tokenString)
		Auth.auth().signIn(with: credential) { result, error in
			self.handleUser(result?.user, error)
		}
	}

	func logout() {
		GIDSignIn.sharedInstance.signOut()
		try? Auth.auth().signOut()
		user = nil
	}

	private func handleUser(_ user: User?, _ error: Error?) {
		if let user {
			Task {
				try await repository.saveUser(uid: user.uid, email: user.email)
				await MainActor.run {
					self.user = user
				}
			}
		} else if let error {
			DispatchQueue.main.async {
				self.loginError = error.localizedDescription
			}
		}
	}
}
