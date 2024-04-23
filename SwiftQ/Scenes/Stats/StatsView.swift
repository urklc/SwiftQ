//
//  StatsView.swift
//  SwiftQ
//
//  Uğur Kılıç
//  www.linkedin.com/in/ugurkilic
//  www.youtube.com/@urklc
//

import Charts
import SwiftUI

struct StatItem: Identifiable {
	let id = UUID()
	let color: String
	let type: String
	let count: Int
}

struct StatsView: View {
	@StateObject var model = StatsViewModel()

	@State var items: [StatItem] = []

    var body: some View {
		ZStack {
			Color("Background")
				.ignoresSafeArea()

			VStack {
				Chart {
					ForEach(items) { shape in
						BarMark(
							x: .value("Shape Type", shape.type),
							y: .value("Total Count", shape.count)
						)
						.annotation(position: .overlay, alignment: .bottom) {
							if shape.count > 0 {
								Text("\(shape.count)")
									.font(.system(size: 12))
									.bold()
									.foregroundColor(Color("Text"))
							}
						}
						.foregroundStyle(Color(shape.color))
					}
				}
				.chartXAxis {
					AxisMarks {
						AxisValueLabel()
							.foregroundStyle(Color("Text"))
					}
				}
				.chartYAxis {
					AxisMarks {
						AxisValueLabel("")
					}
				}
				.aspectRatio(1.2, contentMode: .fit)
				.background(Rectangle().fill(Color("Background2")))
				.cornerRadius(16)
				.padding()

				Spacer()
			}
		}
		.taskOnce {
			Task {
				try? await model.retrieveStats()
			}
		}
		.onChange(of: model.stats) { _, newValue in
			guard let newValue else { return }
			items = [
				StatItem(color: "CorrectBackground",
						 type: QuestionLevel.beginner.text,
						 count: newValue.correctMap[QuestionLevel.beginner.rawValue] ?? 0),
				StatItem(color: "CorrectBackground",
						 type: QuestionLevel.intermediate.text,
						 count: newValue.correctMap[QuestionLevel.intermediate.rawValue] ?? 0),
				StatItem(color: "CorrectBackground",
						 type: QuestionLevel.advanced.text,
						 count: newValue.correctMap[QuestionLevel.advanced.rawValue] ?? 0),
				StatItem(color: "WrongBackground",
						 type: QuestionLevel.beginner.text,
						 count: newValue.wrongMap[QuestionLevel.beginner.rawValue] ?? 0),
				StatItem(color: "WrongBackground",
						 type: QuestionLevel.intermediate.text,
						 count: newValue.wrongMap[QuestionLevel.intermediate.rawValue] ?? 0),
				StatItem(color: "WrongBackground",
						 type: QuestionLevel.advanced.text,
						 count: newValue.wrongMap[QuestionLevel.advanced.rawValue] ?? 0)
			]
		}
	}
}

struct StatsView_Previews: PreviewProvider {
	static var previews: some View {
		let items = [
			StatItem(color: "CorrectBackground", type: "Beginner", count: 1),
			StatItem(color: "CorrectBackground", type: "Intermediate", count: 5),
			StatItem(color: "CorrectBackground", type: "Advanced", count: 8),
			StatItem(color: "WrongBackground", type: "Beginner", count: 0),
			StatItem(color: "WrongBackground", type: "Intermediate", count: 12),
			StatItem(color: "WrongBackground", type: "Advanced", count: 1)
		]
		StatsView(items: items)
    }
}
