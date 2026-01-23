//
//  DiscreteStepCarousel
//  Created by Maic Lopez Saenz.
//


import PreviewUtilities
import SwiftUI


@MainActor
private struct PreviewContent {

    static let layout: PreviewTrait<Preview.ViewTraits> = .iPhoneProSizeForcedLayout

}

// TODO: rename sliderPositon to carousel
#Preview("Default", traits: .headerFooter, PreviewContent.layout) {
    @Previewable @State var sliderPosition: DiscreteStepCarouselPosition = .init(
        values: Strings.alphabet.map(\.localizedUppercase),
        selectedValue: "D")

    // Indicator arrow.
    Image(systemName: "arrowtriangle.down.fill")
        .font(.caption)

    DiscreteStepCarousel(position: $sliderPosition)
    .frame(height: 44)

    // TODO: two sliders connected with a single position do not sync between each other. If this works, remove style preview.
    DiscreteStepCarousel(position: $sliderPosition, anchorStyle: .red, markStyle: .orange.tertiary)
    .frame(height: 44)

    Text(sliderPosition.selectedValue)
}


#Preview("Style", traits: .headerFooter, PreviewContent.layout) {
    @Previewable @State var sliderPosition: DiscreteStepCarouselPosition = .init(
        values: Strings.alphabet.map(\.localizedUppercase),
        selectedValue: "S")

    // Indicator arrow.
    Image(systemName: "arrowtriangle.down.fill")
        .font(.caption)

    DiscreteStepCarousel(position: $sliderPosition, anchorStyle: .red, markStyle: .orange.tertiary)
    .frame(height: 44)

    Text(sliderPosition.selectedValue)
}


#Preview("Images", traits: .fixedHeader, PreviewContent.layout) {
    @Previewable @State var carouselPosition: DiscreteStepCarouselPosition = .init(
        values: Strings.natoPhoneticAlphabet.map(\.localizedUppercase),
        selectedIndex: 4,
        markLength: 120)
    @Previewable @State var imageGenerator = ImageGeneratorStore(
        generator: ConcurrentImageGenerator(size: .square(of: 100), sleepRange: ImageGeneratorDefaults.zero))

    // Indicator arrow.
    Image(systemName: "arrowtriangle.down.fill")
        .font(.caption)

    DiscreteStepCarousel(position: $carouselPosition) { item in
        Group {
            if let image = imageGenerator.images[item] {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Rectangle()
                    .fill(.secondary)
            }
        }
        .frame(size: .square(of: 100))
        .roundedRectangleClip(cornerRadius: 8)
        .task {
            // `generateImage` automatically cancels image generation if the task is cancelled.
            await imageGenerator.generateImage(with: item)
        }
    }
    .frame(height: 100)
}


#Preview("With Controls", traits: .zeroSpacing, PreviewContent.layout) {
    @Previewable @State var sliderPosition: DiscreteStepCarouselPosition = .init(
        values: Strings.alphabet.map(\.localizedUppercase),
        selectedValue: "M")
    @Previewable @State var sliderContentWidth: CGFloat = 0.0

    // Selected value display.
    HistoricValue(
        label: "value:",
        value: sliderPosition.selectedValue)

    // Indicator arrow.
    Image(systemName: "arrowtriangle.down.fill")
        .font(.caption)

    DiscreteStepCarousel(position: $sliderPosition)
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
        describingValue: sliderPosition.selectedIndex
    )
    .history(spacing: 20)
    .padding(.bottom)

    Divider()

    List {
        VStack {
            Text("ContentWidth: \(shortFraction: sliderContentWidth)")
                .monospaced()
                .maxWidthFrame()
            Text("expected: \(shortFraction: sliderPosition.markLength * sliderPosition.values.count.asDouble)")
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


#Preview("With Images", traits: .zeroSpacing, PreviewContent.layout) {
    @Previewable @State var printOnce: PrintOnce = .previewStarted
    @Previewable @State var sliderPosition: DiscreteStepCarouselPosition = .init(
        values: Strings.alphabet.map(\.localizedUppercase),
        selectedValue: "Y",
        markLength: 100)
    @Previewable @State var imageGenerator = ImageGeneratorStore(size: .square(of: 50))
    @Previewable @State var sliderContentWidth: CGFloat = 0.0

    printOnce.print()

    // Selected value display.
    HistoricValue(
        label: "value:",
        value: sliderPosition.selectedValue)

    // Indicator arrow.
    Image(systemName: "arrowtriangle.down.fill")
        .font(.caption)

    DiscreteStepCarousel(position: $sliderPosition) { item in
        Group {
            if let image = imageGenerator.images[item] {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Rectangle()
                    .fill(.secondary)
            }
        }
        .frame(width: 80, height: 50)
        .roundedRectangleClip(cornerRadius: 8)
        .task {
            // `generateImage` automatically cancels image generation if the task is cancelled.
            await imageGenerator.generateImage(with: item)
        }
    }
    .frame(height: 60)
    .onScrollGeometryChange(of: \.contentSize.width, binding: $sliderContentWidth)

    // Selected index display.
    HistoricValue(
        label: "index:",
        describingValue: sliderPosition.selectedIndex
    )
    .history(spacing: 20)
    .padding(.bottom)

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

        let columns: Int = 3
        LazyVGrid(
            columns: Array(
                repeating: .init(.flexible()),
                count: columns
            ),
            alignment: .leading,
            spacing: 4.0
        ) {

            ForEach(sliderPosition.values.columnMajorReordered(columns: columns), id: \.self) { item in
                let generationStatus = imageGenerator.status[item]
                HStack {
                    Text(item)
                        .frame(width: 15, alignment: .leading)
                    Circle()
                        .fill(generationStatus?.statusColor ?? .gray)
                        .frame(squareOf: 15)
                    Text(generationStatus?.minimalStatusText ?? "Idle")
                        .font(.caption.monospaced())
                        .lineLimit(1)
                        .maxWidthFrame(alignment: .leading)
                }
            } // ForEach
        } // LazyVGrid

        VStack {
            Text("ContentWidth: \(shortFraction: sliderContentWidth)")
                .monospaced()
                .maxWidthFrame()
            Text("expected: \(shortFraction: sliderPosition.markLength * sliderPosition.values.count.asDouble)")
                .font(.caption)
                .monospaced()
        }
    } // List
}
