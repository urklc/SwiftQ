//
//  QuizView.swift
//  SwiftQ
//
//  Uğur Kılıç
//  www.linkedin.com/in/ugurkilic
//  www.youtube.com/@urklc
//

import SwiftUI

struct QuizView: View {
	@Environment(\.scenePhase) var scenePhase
	@ObservedObject var model: QuizViewModel
	@Binding var path: [Question]

	@State var selectedIndex: Int?
	@State var isCorrect: Bool?
	@State var answerPresented = false

	var body: some View {
		ZStack {
			if model.isLoading {
				ProgressView()
					.foregroundColor(.white)
			}
			VStack {
				if let question = model.question {
					questionView(question)

					Divider()
						.background(.white)

					answersView(question)
				}

				Spacer()

				HStack {
					ToolButton(text: "Quit", image: nil) {
						path = []
					}
					if isCorrect == false {
						ToolButton(text: "Explain", image: "crown.fill") {
							answerPresented = true
						}
					}
					if selectedIndex == nil {
						ToolButton(text: "Skip", image: nil) {
							Task {
								try? await model.getNextQuestion()
							}
						}
					}
					if selectedIndex != nil {
						ToolButton(text: "Next", image: nil) {
							Task {
								isCorrect = nil
			 					selectedIndex = nil
								answerPresented = false
								try? await model.getNextQuestion()
							}
						}
					}
				}
			}
			.frame(maxWidth: .infinity)
			.padding([.leading, .top, .trailing])
		}
		.sheet(isPresented: $answerPresented, content: {
			ExplanationView(explanation: model.explanation)
		})
		.disabled(model.isLoading)
		.navigationBarBackButtonHidden(true)
		.defaultBackground()
		.onChange(of: scenePhase) { _, newValue in
			if newValue == .background {
				model.syncAnswers()
			}
		}
	}

	func answersView(_ question: Question) -> some View {
		return ScrollViewReader { proxy in
			ScrollView(.vertical, showsIndicators: false) {
				ForEach(0..<question.answers.count, id: \.self) { index in
					VStack {
						if question.answersAreImages {
							QuizImage(url: URL(string: question.answers[index]))
						} else {
							HStack {
								Text(question.answers[index])
									.lineLimit(100)
									.multilineTextAlignment(.leading)
									.frame(maxWidth: .infinity)
								Spacer()
							}
						}
					}
					.padding()
					.frame(maxWidth: .infinity)
					.background(
						Rectangle()
							.fill(itemColor(index: index))
							.cornerRadius(8)
					)
					.clipShape(RoundedRectangle(cornerRadius: 16.0))
					.onTapGesture {
						if selectedIndex == nil {
							isCorrect = model.set(answerIndex: index)
							selectedIndex = index
						}
					}
				}
			}
			.onAppear {
				DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(100)) {
					proxy.scrollTo(question.answers[0])
				}
			}
		}
	}

	func questionView(_ question: Question) -> some View {
		VStack {
			QuizImage(url: question.imageURL)
			if let description = question.text {
				Text(description)
					.multilineTextAlignment(.leading)
			}
		}
		.padding(.horizontal, 8)
	}

	private func itemColor(index: Int) -> Color {
		if selectedIndex == nil {
			return Color("Background2")
		}
		if index == model.question?.correctAnswerIndex {
			return Color("CorrectBackground")
		} else {
			if index == selectedIndex {
				return Color("WrongBackground")
			}
			return Color("Background2")
		}
	}
}

struct QuizView_Previews: PreviewProvider {
	static var previews: some View {
		let model = QuizViewModel()
		return QuizView(model: model, path: .constant([]))
			.task {
				try? await model.retrieveQuestions(level: .advanced)
			}
	}
}
