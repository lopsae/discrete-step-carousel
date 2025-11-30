//
//  DiscreteStepSlider
//  Created by Maic Lopez Saenz.
//


import SwiftUI


#Preview(traits: .fixedLayout(width: 400, height: 400)) {
    @Previewable @State var sliderPosition: DiscreteStepSliderPosition = .init(
        values: String.alphabet.prefix(upTo: 16).map(\.localizedUppercase),
        selectedValue: "H",
        spacing: 20)

    // Selected value display.
    HistoricValue(
        label: "value:",
        value: sliderPosition.selectedValue)

    // Indicator arrow.
    Image(systemName: "arrowtriangle.down.fill")
        .font(.caption)

    DiscreteStepSlider(position: $sliderPosition) { _ in
        Rectangle()
            .fill(.orange.tertiary)
            .frame(width: 2)
    }
    .frame(height: 44)
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
    HistoricValue(
        label: "index:",
        value: sliderPosition.selectedIndex
    ).history(spacing: 20)

    List {
        Section("Immediate") {
            HStack {
                let indices: [Int] = [0, 3, 5]
                ForEach(indices, id: \.self) { index in
                    let value = sliderPosition.values[index]
                    Button(value) {
                        print("➡️ Selecting by Value: \(value)")
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
                let indices: [Int] = [0, 11, 13, 15]
                ForEach(indices, id: \.self) { index in
                    let value = sliderPosition.values[index]
                    Button(value) {
                        print("➡️ Animated selecting by Value: \(value)")
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
