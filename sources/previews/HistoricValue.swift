//
//  DiscreteStepSlider
//  Created by Maic Lopez Saenz.
//


import SwiftUI
import PreviewUtilities


/// Displays a labeled value, along a history of previous values next to it.
///
/// Every time the displayed value changes the previous value is stored up to a given number of
/// changes. All historic values are displayed next to the current value.
struct HistoricValue<Value: Equatable, Formatter: FormatStyle>: View
where
    Formatter.FormatInput == Value,
    Formatter.FormatOutput == String
{

    @State private var history: [Value] = []

    let label: String
    let value: Value
    let formatter: Formatter

    let historyLength: Int = 10

    private(set) var historyPadding: Double = 5.0
    private(set) var historySpacing: Double = 25.0
    private(set) var historyEdge: Edge = .trailing


    /// Creates a view which displays a formatted value along its history of previous values.
    init(label: String, value: Value, format formatter: Formatter) {
        self.label = label
        self.value = value
        self.formatter = formatter
    }


    var body: some View {
        let valueString = formatter.format(value) // ?? String(describing: value)
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
                if history.count >= historyLength {
                    history.removeLast(1 + history.count - historyLength)
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
            let valueString = formatter.format(historicValue) // ?? String(describing: historicValue)
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
                .opacity(1.0 - (index.asDouble / historyLength.asDouble))
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


extension HistoricValue {

    /// Creates a view which displays a string value along its history of previous values.
    init(label: String, value: Value)
    where
        Formatter == IdentityFormatStyle<Value>,
        Value == String
    {
        self.init(label: label, value: value, format: .init())
    }


    /// Creates a view which displays the string description of a value along its history of
    /// previous values.
    init(label: String, describingValue value: Value)
    where Formatter == StringDescriptionFormatStyle<Value>
    {
        self.init(label: label, value: value, format: .init())
    }

}


// MARK: - Previews.


#Preview("String Value") {

    @Previewable @State var selectedIndex: Int = 0
    @Previewable @State var historyEdge: Edge = .top
    let values = String.natoPhoneticAlphabet
    let selection = values[selectedIndex]
    HistoricValue(label: "selected:", value: selection)
        .history(padding: 10, spacing: 40, edge: historyEdge)

    Text("Change value:")
        .font(.caption)
        .padding(.top)

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
        Text("History direction:")
            .font(.caption)
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
    @Previewable @State var useFormatter: Bool = true
    let step: Double = 0.12345

    if useFormatter {
        HistoricValue(label: "value:", value: value, format: .shortFraction)
            .history(spacing: 35)
    } else {
        HistoricValue(label: "value:", describingValue: value)
            .history(spacing: 15, edge: .top)
    }


    Text("raw: \(value)")
        .font(.caption)
        .monospacedDigit()
    Text("Using \(useFormatter ? "Short Fraction" : "Default (String Description)")")
        .font(.caption)

    HStack {
        Button {
            value += step
        } label: {
            Label {
                Text("Add")
            } icon: {
                ZStack {
                    // Invisible text to prevent button size to collapse to image size.
                    Text("M").hidden()
                    Image(systemName: "plus")
                }
            }
        } // Button
        .labelStyle(.iconOnly)
        .buttonStyle(.borderedProminent)

        Button {
            value -= step
        } label: {
            Label {
                Text("Substract")
            } icon: {
                ZStack {
                    // Invisible text to prevent button size to collapse to image size.
                    Text("M").hidden()
                    Image(systemName: "minus")
                }
            }
        } // Button
        .labelStyle(.iconOnly)
        .buttonStyle(.borderedProminent)
    } // HStack

    Toggle("Use Formatter", isOn: $useFormatter)
        .padding(.horizontal)

}
