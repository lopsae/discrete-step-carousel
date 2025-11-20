//
//  DiscreteStepSlider
//  Created by Maic Lopez Saenz.
//


import SwiftUI


#Preview {
    @Previewable @State var sliderPosition: DiscreteStepSlider.Position = .init(
        values: Array(stride(from: 0.0, to: 3.01, by: 0.2)),
        selectedValue: 1.6,
        spacing: 20)

    // Selected value display.
    Text(sliderPosition.selectedValue.formatted(.number.precision(.fractionLength(1))))
        .monospacedDigit()

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
