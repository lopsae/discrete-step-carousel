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


#Preview {
    @Previewable @State var sliderPosition: DiscreteStepSlider.Position = .init(
        values: Array(stride(from: 0.0, to: 3.01, by: 0.2)),
        selectedValue: 1.6,
        spacing: 20)

    // Selected value display.
    HistoricValue("value:", value: sliderPosition.selectedValue)

    // Indicator arrow.
    Image(systemName: "arrowtriangle.down.fill")
        .font(.caption)

    DiscreteStepSlider(position: $sliderPosition)
        .onAppear {
            print("✴️ Preview Appeared")
        }
        .onChange(of: sliderPosition.selectedValue) { oldValue, newValue in
            print("selectedValue changed: \(sliderPosition.selectedValue)")
        }
        .onChange(of: sliderPosition.selectedIndex) { oldValue, newValue in
            print("selectedIndex changed: \(sliderPosition.selectedIndex)")
        }

    // Selected index display.
    // TODO: 
//    HistoricValue("index:", value: sliderPosition.selectedIndex)
    Text(sliderPosition.selectedIndex.description)
        .font(.caption)
        .monospacedDigit()

    List {
        Section("Immediate") {
            HStack {
                let indices: [Int] = [0, 3, 5]
                ForEach(indices, id: \.self) { index in
                    let value = sliderPosition.values[index]
                    let formattedValue = value.formatted(.number.precision(.fractionLength(1)))
                    Button(formattedValue) {
                        print("➡️ Selecting by Value: \(formattedValue)")
                        sliderPosition.selectValue(value)
                    }
                    .buttonStyle(.borderedProminent)
                    .monospaced()
                }
            } // HStack
            .maxWidthFrame()

            HStack {
                let indices: [Int] = [1, 4, 6]
                ForEach(indices, id: \.self) { index in
                    Button("[\(index)]") {
                        print("➡️ Selecting by Index: [\(index)]")
                        sliderPosition.selectIndex(index)
                    }
                    .buttonStyle(.borderedProminent)
                    .monospaced()
                }
            } // HStack
            .maxWidthFrame()
        } // Section

        Section("Animated") {
            HStack {
                let indices: [Int] = [11, 13, 15]
                ForEach(indices, id: \.self) { index in
                    let value = sliderPosition.values[index]
                    let formattedValue = value.formatted(.number.precision(.fractionLength(1)))
                    Button(formattedValue) {
                        print("➡️ Animated selecting by Value: \(formattedValue)")
                        withAnimation {
                            sliderPosition.selectValue(value)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .monospaced()
                }
            } // HStack
            .maxWidthFrame()

            HStack {
                let indices: [Int] = [10, 12, 14]
                ForEach(indices, id: \.self) { index in
                    Button("[\(index)]") {
                        print("➡️ Animated selecting by Index: [\(index)]")
                        withAnimation {
                            sliderPosition.selectIndex(index)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .monospaced()
                }
            } // HStack
            .maxWidthFrame()
        } // Section
    }
}
