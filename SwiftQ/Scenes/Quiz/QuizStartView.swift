//
//  QuizStartView.swift
//  SwiftQ
//
//  Uğur Kılıç
//  www.linkedin.com/in/ugurkilic
//  www.youtube.com/@urklc
//

import SwiftUI

struct QuizStartView: View {
	@StateObject var model = QuizViewModel()

	@State var path: [Question] = []
	@State var level: QuestionLevel = .beginner
	@State var isSettingsDisplayed = false
	@Binding var shouldLogout: Bool

	var body: some View {
		NavigationStack(path: $path) {
			ZStack {
				VStack(alignment: .center) {
					Spacer()

					VStack {
						Text("Pick a level")

						Picker(selection: $level, label: Text("")) {
							ForEach(QuestionLevel.allCases, id: \.self) {
								Text($0.text)
							}
						}
						.pickerStyle(MenuPickerStyle())
						.foregroundColor(.white)
					}
					.padding()
					.background(Color("Background2"))
					.cornerRadius(16)

					ToolButton(text: "GO!", image: nil) {
						Task {
							try? await model.retrieveQuestions(level: level)
						}
					}

					Spacer()

					Button("Settings", systemImage: "gear") {
						isSettingsDisplayed = true
					}
				}
				.frame(maxWidth: .infinity, maxHeight: .infinity)
				.defaultBackground()
				.navigationDestination(for: Question.self) { _ in
					QuizView(model: model, path: $path)
				}
				.navigationTitle("Start Quiz")
				.toolbarBackground(Color("Background2"), for: .navigationBar)
				.toolbarBackground(.visible, for: .navigationBar)
				.toolbarColorScheme(.dark, for: .navigationBar)

				if model.isLoading {
					ProgressView()
				}
			}
			.disabled(model.isLoading)
		}
		.sheet(isPresented: $isSettingsDisplayed, content: {
			settingsView()
		})
		.onChange(of: model.question) { _, newValue in
			if let newValue {
				path.append(newValue)
			}
		}
		.onChange(of: path) { _, newValue in
			if newValue.isEmpty {
				model.quit()
			}
		}
	}

	@ViewBuilder
	func settingsView() -> some View {
		NavigationStack {
			VStack {
				StatsView()

				Divider()

				Button("Logout") {
					shouldLogout = true
				}
				.foregroundStyle(.white)

				Divider()

				Button("Delete Account") {
					Task {
						isSettingsDisplayed = false
						try await model.deleteAccount()
						shouldLogout = true
					}
				}
				.foregroundStyle(.red)

				Divider()
			}
			.fontDesign(.rounded)
			.background(Color("Background"))
			.preferredColorScheme(.dark)
		}
	}
}

struct QuizStartView_Previews: PreviewProvider {
	static var previews: some View {
		return QuizStartView(shouldLogout: .constant(true))
			.preferredColorScheme(.dark)
	}
}
