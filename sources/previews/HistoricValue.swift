//
//  DiscreteStepSlider
//  Created by Maic Lopez Saenz.
//


import SwiftUI


struct HistoricValue<Value: Equatable, Formatter: FormatStyle>: View
where Formatter.FormatInput == Value, Formatter.FormatOutput == String
{

    @State private var history: [Value] = []

    let label: String
    let value: Value
    let formatter: Formatter?

    let historyToKeep: Int = 10

    private(set) var historyPadding: Double = 5.0
    private(set) var historySpacing: Double = 25.0


    init(label: String, value: Value, format formatter: Formatter?) {
        self.label = label
        self.value = value
        self.formatter = formatter
    }


    var body: some View {
        let valueString = formatter?.format(value) ?? String(describing: value)
        Text(valueString)
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


    func history(padding: Double? = nil, spacing: Double? = nil) -> Self {
        var copy = self
        if let padding { copy.historyPadding = padding }
        if let spacing { copy.historySpacing = spacing }
        return copy
    }


    @ViewBuilder
    private var historicValues: some View {
        ForEach(history.enumerated(), id: \.offset) { index, historicValue in
            let valueString = formatter?.format(historicValue) ?? String(describing: historicValue)
            Text(valueString)
                .font(.caption)
                .monospacedDigit()
                .fixedSize()
                .opacity(1.0 - (index.asDouble / historyToKeep.asDouble))
                .offset(x: ((index.asDouble + 1.0) * historySpacing) + historyPadding)
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


extension HistoricValue where Formatter == NeverFormatStyle<Value> {

    init(label: String, value: Value) {
        self.init(label: label, value: value, format: nil)
    }

}


// Dummy implementation of FormatStyle to provide HistoricValue initializers without format.
struct NeverFormatStyle<Input>: FormatStyle {
    func format(_ value: Input) -> String { "" }
}


// TODO: add preview, using a formatter
// HistoricValue(
//label: "value:",
//value: sliderPosition.selectedValue,
//format: FloatingPointFormatStyle.number.precision(.fractionLength(1)))
