//
//  ExplanationView.swift
//  SwiftQ
//
//  Uğur Kılıç
//  www.linkedin.com/in/ugurkilic
//  www.youtube.com/@urklc
//

import SwiftUI
import RevenueCat
import RevenueCatUI

struct ExplanationView: View {
	@State var displayPaywall = false
	@State var isPremium = false

	let explanation: AnswerExplanation?
	var body: some View {
		Text("")
			.sheet(isPresented: self.$displayPaywall) {
				PaywallView()
					.toolbar {
						ToolbarItem(placement: .destructiveAction) {
							Button {
								self.displayPaywall = false
							} label: {
								Image(systemName: "xmark")
							}
						}
					}
			}
			.taskOnce {
				Task {
					do {
						let customerInfo = try await Purchases.shared.customerInfo()
						if customerInfo.entitlements.all["com.swiftq.premium"]?.isActive == true {
							isPremium = true
							displayPaywall = false
						} else {
							displayPaywall = true
						}
					} catch {
						print(error.localizedDescription)
					}
				}
			}
	}
}

struct ExplanationView_Previews: PreviewProvider {
	static var previews: some View {
		return ExplanationView(
			explanation: AnswerExplanation.generate()
		)
	}
}
