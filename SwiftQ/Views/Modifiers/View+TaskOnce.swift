//
//  View+TaskOnce.swift
//  SwiftQ
//
//  Uğur Kılıç
//  www.linkedin.com/in/ugurkilic
//  www.youtube.com/@urklc
//

import SwiftUI

struct TaskOnce: ViewModifier {
	let action: () -> Void
	@State private var onceFlag = false
	func body(content: Content) -> some View {
		content
			.task(id: onceFlag) {
				action()
			}
	}
}

extension View {
	func taskOnce(action: @escaping () -> Void) -> some View {
		self.modifier(TaskOnce(action: action))
	}
}
