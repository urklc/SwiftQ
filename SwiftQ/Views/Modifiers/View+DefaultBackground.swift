//
//  View+DefaultBackground.swift
//  SwiftQ
//
//  Uğur Kılıç
//  www.linkedin.com/in/ugurkilic
//  www.youtube.com/@urklc
//

import SwiftUI

struct DefaultBackground: ViewModifier {
	func body(content: Content) -> some View {
		content
			.font(.footnote)
			.foregroundColor(Color("Text"))
			.background(Color("Background"))
	}
}

extension View {
	func defaultBackground() -> some View {
		self
			.modifier(DefaultBackground())
	}
}
