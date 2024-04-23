//
//  SwiftQApp.swift
//  SwiftQ
//
//  Uğur Kılıç
//  www.linkedin.com/in/ugurkilic
//  www.youtube.com/@urklc
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import RevenueCat

class AppDelegate: NSObject, UIApplicationDelegate {
	func application(
		_ application: UIApplication,
		didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
			FirebaseApp.configure()

			#if DEBUG
			Purchases.logLevel = .debug
			#endif
			Purchases.configure(withAPIKey: "")
			return true
		}

	func application(
		_ app: UIApplication,
		open url: URL,
		options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
			return GIDSignIn.sharedInstance.handle(url)
	}
}

@main
struct SwiftQApp: App {
	@UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
			LoginView()
				.preferredColorScheme(.dark)
        }
    }
}
