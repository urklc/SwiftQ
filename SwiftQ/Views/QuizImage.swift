//
//  QuizImage.swift
//  SwiftQ
//
//  Uğur Kılıç
//  www.linkedin.com/in/ugurkilic
//  www.youtube.com/@urklc
//

import SwiftUI

struct QuizImage: View {
	let url: URL?
	var body: some View {
		if let imageURL = url {
			AsyncImage(url: imageURL) { phase in
				if let image = phase.image {
					image
						.resizable()
						.aspectRatio(contentMode: .fit)
						.cornerRadius(16)
				} else if phase.error != nil {
					Color.red
				} else {
					Color.gray
				}
			}
		}
	}
}
