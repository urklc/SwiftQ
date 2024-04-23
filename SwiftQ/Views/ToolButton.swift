//
//  ToolButton.swift
//  SwiftQ
//
//  Uğur Kılıç
//  www.linkedin.com/in/ugurkilic
//  www.youtube.com/@urklc
//

import SwiftUI

struct ToolButton: View {
	let text: String
	let image: String?
	let action: () -> Void
	var body: some View {
		HStack {
			Text(text)
				.onTapGesture {
					action()
				}
			if let image {
				Image(systemName: image)
			}
		}
		.padding()
		.background(
			Rectangle()
				.fill(Color("Background2"))
				.cornerRadius(8)
		)
		.padding(.top, 8)
	}
}

struct ToolButton_Previews: PreviewProvider {
    static var previews: some View {
		ToolButton(text: "hello", image: "trash") { }
			.preferredColorScheme(.dark)
    }
}
