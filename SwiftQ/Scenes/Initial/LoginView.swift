//
//  LoginView.swift
//  SwiftQ
//
//  Uğur Kılıç
//  www.linkedin.com/in/ugurkilic
//  www.youtube.com/@urklc
//

import AuthenticationServices
import Firebase
import GoogleSignIn
import GoogleSignInSwift
import SwiftUI

struct LoginView: View {
	@StateObject var model = LoginViewModel()

	@State private var shouldLogout = false

	var body: some View {
		if model.user != nil {
			QuizStartView(shouldLogout: $shouldLogout)
				.onChange(of: shouldLogout) { _, newValue in
					if newValue {
						model.logout()
						shouldLogout.toggle()
					}
				}
		} else {
			ZStack {
				Color("Background").ignoresSafeArea()

				VStack {
					Spacer()

					SignInWithAppleButton { request in
						model.prepare(request)
					} onCompletion: { result in
						model.login(result: result)
					}
					.signInWithAppleButtonStyle(.black)
					.frame(maxHeight: 42)

					GoogleSignInButton(scheme: .dark, style: .wide) {
						presentGoogleLogin()
					}

					if let error = model.loginError {
						Text(error)
							.foregroundStyle(.red)
							.padding()
					}
				}
				.padding()
			}
		}
	}

	// MARK: - Google Login

	private func presentGoogleLogin() {
		model.loginError = nil

		guard let controller = UIApplication.shared.presentingViewController,
		let clientID = FirebaseApp.app()?.options.clientID else {
			return
		}
		let config = GIDConfiguration(clientID: clientID)
		GIDSignIn.sharedInstance.configuration = config
		GIDSignIn.sharedInstance.signIn(withPresenting: controller) { result, error in
			if let error {
				DispatchQueue.main.async {
					model.loginError = error.localizedDescription
				}
				return
			}
			if let result {
				model.login(result: result)
			}
		}
	}
}

struct LoginView_Previews: PreviewProvider {
	static var previews: some View {
		LoginView()
			.preferredColorScheme(.dark)
	}
}
