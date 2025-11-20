//
//  DiscreteStepSlider
//  Created by Maic Lopez Saenz.
//


import SwiftUI


struct HistoricValue: View {

    @State private var history: [Double] = []

    let label: String
    let value: Double

    let historyToKeep: Int = 10


    init(_ label: String, value: Double) {
        self.value = value
        self.label = label
    }

    var body: some View {
        Text(value.formatted(.number.precision(.fractionLength(1))))
            .monospacedDigit()
            // Historic values placed in an overlay so that these never modify the size of the
            // main text.
            .overlay {
                historicValues
            }
            .overlay(alignment: .leading) {
                labelView
            }
            .onChange(of: value) { oldValue, newValue in
                if history.count >= historyToKeep {
                    history.removeLast(1 + history.count - historyToKeep)
                }
                history.insert(oldValue, at: 0)
            }
    }


    @ViewBuilder
    private var historicValues: some View {
        ForEach(history.enumerated(), id: \.offset) { index, historicValue in
            Text(historicValue.formatted(.number.precision(.fractionLength(1))))
                .font(.caption)
                .monospacedDigit()
                .opacity(1.0 - (index.asDouble / historyToKeep.asDouble))
                .offset(x: ((index.asDouble + 1.0) * 25.0) + 5.0)
        }
    }


    private var labelView: some View {
        Text(label)
            .font(.caption)
            .padding(.horizontal, 5)
            .fixedSize()
            .alignmentGuide(.leading) { dimensions in
                dimensions[.trailing]
            }
    }

}
