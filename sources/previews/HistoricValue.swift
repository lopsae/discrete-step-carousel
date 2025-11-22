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
    private(set) var historyEdge: Edge = .trailing


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


    func history(
        padding: Double? = nil,
        spacing: Double? = nil,
        edge: Edge? = nil
    ) -> Self {
        var copy = self
        if let padding { copy.historyPadding = padding }
        if let spacing { copy.historySpacing = spacing }
        if let edge    { copy.historyEdge    = edge }
        return copy
    }


    @ViewBuilder
    private var historicValues: some View {
        ForEach(history.enumerated(), id: \.offset) { index, historicValue in
            let valueString = formatter?.format(historicValue) ?? String(describing: historicValue)
            let offsetValue = ((index.asDouble + 1.0) * historySpacing) + historyPadding
            let offsetSize = switch historyEdge {
            case .top:      CGSize(width: .zero, height: -offsetValue)
            case .leading:  CGSize(width: -offsetValue, height: .zero)
            case .bottom:   CGSize(width: .zero, height: offsetValue)
            case .trailing: CGSize(width: offsetValue, height: .zero)
            }
            Text(valueString)
                .font(.caption)
                .monospacedDigit()
                .fixedSize()
                .opacity(1.0 - (index.asDouble / historyToKeep.asDouble))
                .offset(offsetSize)
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


// Implementation of FormatStyle to provide HistoricValue initializers without format.
struct NeverFormatStyle<Input>: FormatStyle {
    func format(_ value: Input) -> String { .init() }
}


// MARK: - Previews


#Preview {

    @Previewable @State var selectedIndex: Int = 0
    @Previewable @State var historyEdge: Edge = .top
    let values = String.natoPhoneticAlphabet
    let selection = values[selectedIndex]
    HistoricValue(label: "selected:", value: selection)
        .history(padding: 10, spacing: 40, edge: historyEdge)

    HStack {
        Button("Previous", systemImage: "arrowshape.left") {
            selectedIndex = (selectedIndex + values.count - 1) % values.count
        }
        .labelStyle(.iconOnly)
        .buttonStyle(.borderedProminent)

        Button("Next", systemImage: "arrowshape.right") {
            selectedIndex = (selectedIndex + 1) % values.count
        }
        .labelStyle(.iconOnly)
        .buttonStyle(.borderedProminent)
    }

    VStack {
        Button("Top", systemImage: "arrowshape.up.fill") {
            historyEdge = .top
        }
        .labelStyle(.iconOnly)
        .buttonStyle(.borderedProminent)

        HStack {
            Button("Leading", systemImage: "arrowshape.left.fill") {
                historyEdge = .leading
            }
            .labelStyle(.iconOnly)
            .buttonStyle(.borderedProminent)

            Button("Bottom", systemImage: "arrowshape.down.fill") {
                historyEdge = .bottom
            }
            .labelStyle(.iconOnly)
            .buttonStyle(.borderedProminent)

            Button("Trailing", systemImage: "arrowshape.right.fill") {
                historyEdge = .trailing
            }
            .labelStyle(.iconOnly)
            .buttonStyle(.borderedProminent)
        }
    }

}


#Preview("Formatted") {

    @Previewable @State var value: Double = 0.12345
    let step: Double = 0.12345

    HistoricValue(
        label: "value:",
        value: value,
        format: FloatingPointFormatStyle.number.precision(.fractionLength(2))
    )
    .history(spacing: 35)

    Text("raw: \(value)")
        .font(.caption)
        .monospacedDigit()

    HStack {
        Button("Add", systemImage: "plus") {
            value += step
        }
        .labelStyle(.iconOnly)
        .buttonStyle(.borderedProminent)

        Button("Substract", systemImage: "minus") {
            value -= step
        }
        .labelStyle(.iconOnly)
        .buttonStyle(.borderedProminent)
    }

}
