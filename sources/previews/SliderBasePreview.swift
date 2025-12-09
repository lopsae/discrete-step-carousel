//
//  DiscreteStepSlider
//  Created by Maic Lopez Saenz.
//


import SwiftUI


#Preview(traits: .fixedLayout(width: 400, height: 400)) {
    @Previewable @State var sliderPosition: DiscreteStepSliderPosition = .init(
        values: String.alphabet.map(\.localizedUppercase),
        selectedValue: "H",
        spacing: 20)
    @Previewable @State var sliderContentWidth: CGFloat = 0.0

    // Selected value display.
    HistoricValue(
        label: "value:",
        value: sliderPosition.selectedValue)

    // Indicator arrow.
    Image(systemName: "arrowtriangle.down.fill")
        .font(.caption)

    DiscreteStepSlider(position: $sliderPosition) { _ in
        // TODO: default marker, move into DiscreteStepSlider
        Rectangle()
            .fill(.orange.tertiary)
            .frame(width: 2)
    }
    .frame(height: 44)
    .onScrollGeometryChange(of: \.contentSize.width, binding: $sliderContentWidth)
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
        VStack {
            Text("ContentWidth: \(shortFraction: sliderContentWidth)")
                .monospaced()
                .maxWidthFrame()
            Text("expected: \(shortFraction: sliderPosition.spacing * sliderPosition.values.count.asDouble)")
                .font(.caption)
                .monospaced()
        }

        Section("Immediate") {
            HStack {
                let indices: [Int] = [0, 3, 9, sliderPosition.values.beforeEndIndex]
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
                let indices: [Int] = [1, 6, 12]
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
                let indices: [Int] = [0, 11, 13, sliderPosition.values.beforeEndIndex]
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


// FIXME: update to use ImageGeneratorStorage

#Preview("With Images", traits: .zeroSpacing, .fixedLayout(width: 400, height: 400)) {
    @Previewable @State var sliderPosition: DiscreteStepSliderPosition = .init(
        values: String.alphabet.map(\.localizedUppercase),
        selectedValue: "Z",
        spacing: 100)
    @Previewable @State var generationStatuses: [String: GenerationStatus] =
        String.alphabet.map(\.localizedUppercase).dictionaryMap(value: .idle)
    @Previewable @State var images: [String: Image] = [:]
    @Previewable @State var sliderContentWidth: CGFloat = 0.0

    let imageGenerator = ImageGenerator(size: .init(square: 50))

    // Selected value display.
    HistoricValue(
        label: "value:",
        value: sliderPosition.selectedValue)

    // Indicator arrow.
    Image(systemName: "arrowtriangle.down.fill")
        .font(.caption)

    DiscreteStepSlider(position: $sliderPosition) { item in
        Group {
            if let image = images[item] {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Rectangle()
                    .fill(.secondary)
            }
        }
        .frame(width: 80, height: 50)
        // TODO: convenience function
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .onAppear {
            guard images[item] == nil else {
                return
            }

            generationStatuses[item] = .generating
            Task {
                let generationTuple = await imageGenerator.generateImage(with: item)
                images[item] = generationTuple.image
                generationStatuses[item] = .ready
            }
        }
    }
    .frame(height: 60)
    .onScrollGeometryChange(of: \.contentSize.width, binding: $sliderContentWidth)

    // Selected index display.
    HistoricValue(
        label: "index:",
        value: sliderPosition.selectedIndex
    ).history(spacing: 20)

    Divider()

    List {
        Section("Immediate") {
            HStack {
                let indices: [Int] = [0, 3, 5, sliderPosition.values.beforeEndIndex]
                ForEach(indices, id: \.self) { index in
                    let value = sliderPosition.values[index]
                    Button(value) {
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
                let indices: [Int] = [0, 11, 15, sliderPosition.values.beforeEndIndex]
                ForEach(indices, id: \.self) { index in
                    let value = sliderPosition.values[index]
                    Button(value) {
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

        LazyVGrid(
            columns: [
                .init(.flexible()),
                .init(.flexible()),
                .init(.flexible())
            ],
            alignment: .leading,
        ) {
            ForEach(sliderPosition.values, id: \.self) { item in
                let generationStatus = generationStatuses[item]
                HStack {
                    Text(item)
                        .frame(width: 20, alignment: .leading)
                    Circle()
                        .fill(generationStatus?.statusColor ?? .red)
                        .frame(square: 15)

                    Text(generationStatus?.statusText ?? "Missing")
                        .font(.caption)
                        .lineLimit(1)
                        .maxWidthFrame(alignment: .leading)
                }
            }
        } // LazyVGrid

        VStack {
            Text("ContentWidth: \(shortFraction: sliderContentWidth)")
                .monospaced()
                .maxWidthFrame()
            Text("expected: \(shortFraction: sliderPosition.spacing * sliderPosition.values.count.asDouble)")
                .font(.caption)
                .monospaced()
        }
    } // List
}


// TODO: structure is repeated in ImageGenerator, figure out way to share it, or allow generationStatus to provide that state.
private enum GenerationStatus {

    case idle
    case generating
    case ready

    var statusColor: Color {
        switch self {
        case .idle:    .gray
        case .generating: .orange
        case .ready:   .green
        }
    }

    var statusText: String {
        switch self {
        case .idle:    "Idle"
        case .generating: "Generating"
        case .ready:   "Ready"
        }
    }

}
