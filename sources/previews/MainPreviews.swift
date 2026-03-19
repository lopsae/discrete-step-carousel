//
//  DiscreteStepCarousel
//  Created by Maic Lopez Saenz.
//


import PreviewUtilities
import SwiftUI


@MainActor
private struct PreviewContent {

    static let layout: PreviewTrait<Preview.ViewTraits> = .iPhoneProSizeForcedLayout

    static var indicatorArrow: some View {
        Image(systemName: "arrowtriangle.down.fill")
            .font(.caption)
    }

}


// MARK: - Defaut


#Preview("Default", traits: .fixedHeader, PreviewContent.layout) {
    // TODO: Know issue: a position object works only for a single carousel, connecting it to more
    // that one does not sincronize them. Check if scrollPosition has also the same limitation.
    @Previewable @State var carouselPosition: DiscreteStepCarouselPosition = .init(
        values: Strings.alphabet.map(\.localizedUppercase),
        selectedValue: "D")
    @Previewable @State var styledPosition: DiscreteStepCarouselPosition = .init(
        values: Strings.alphabet.map(\.localizedUppercase),
        selectedValue: "S")
    @Previewable @State var offsetPosition: DiscreteStepCarouselPosition = .init(
        values: Strings.alphabet.map(\.localizedUppercase)[10...20],
        selectedValue: "M")

    PreviewCaption("Carousels with default and stylized default markers.")
        .padding(.bottom)
    PreviewContent.indicatorArrow
    DiscreteStepCarousel(position: $carouselPosition)
        .frame(height: 44)
    Text(carouselPosition.selectedValue)
        .floatingCaption("\(carouselPosition.selectedIndex)", .alignment(.outerTrailingTop))

    DashedDivider()
        .padding(.bottom)

    PreviewContent.indicatorArrow
    DiscreteStepCarousel(position: $styledPosition, anchorStyle: .red, markStyle: .orange.tertiary)
        .frame(height: 44)
    Text(styledPosition.selectedValue)
        .floatingCaption("\(styledPosition.selectedIndex)", .alignment(.outerTrailingTop))

    PreviewCaption("Carousel with a collection with offset indices.")
        .padding(.bottom)

    PreviewContent.indicatorArrow
    DiscreteStepCarousel(position: $offsetPosition, anchorStyle: .red, markStyle: .orange.tertiary)
        .frame(height: 44)
    Text(offsetPosition.selectedValue)
        .floatingCaption("\(offsetPosition.selectedIndex)", .alignment(.outerTrailingTop))
}


// MARK: - Images


#Preview("Images", traits: .fixedHeader, PreviewContent.layout) {
    @Previewable @State var carouselPosition: DiscreteStepCarouselPosition = .init(
        values: Strings.natoPhoneticAlphabet.map(\.capitalized),
        selectedIndex: 10,
        markLength: 100,
        spacing: 20)
    @Previewable @State var imageGenerator = ImageGeneratorStore(
        generator: ConcurrentImageGenerator(size: .square(of: 100), sleepRange: ImageGeneratorDefaults.zero))

    PreviewContent.indicatorArrow

    DiscreteStepCarousel(position: $carouselPosition) { _, item in
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
    .debugOverlay()
    .safeAreaPadding(.horizontal, 50)
    Text(carouselPosition.selectedValue)
    Text.caption("\(carouselPosition.selectedIndex)")
}


// MARK: - Controls


#Preview("Controls", traits: .zeroSpacing, PreviewContent.layout) {
    @Previewable @State var printOnce: PrintOnce = .previewStarted
    @Previewable @State var carouselPosition: DiscreteStepCarouselPosition = .init(
        values: Strings.alphabet.map(\.localizedUppercase),
        selectedValue: "M")
    @Previewable @State var updatesImmediately: Bool = false

    @Previewable @State var carouselContentWidth: CGFloat = 0.0
    @Previewable @State var valueIsMarked: Bool = false
    @Previewable @State var indexIsMarked: Bool = false


    printOnce.print()

    // Selected value display.
    HistoricValue(
        label: "value:",
        value: carouselPosition.selectedValue,
        isMarked: $valueIsMarked
    )
    .configure(spacing: 20)

    PreviewContent.indicatorArrow

    DiscreteStepCarousel(position: $carouselPosition)
    .frame(height: 44)
    .onScrollGeometryChange(of: \.contentSize.width, binding: $carouselContentWidth)
    .onChange(of: carouselPosition.selectedValue) { oldValue, newValue in
        print("selectedValue changed: \(carouselPosition.selectedValue)")
    }
    .onChange(of: carouselPosition.selectedIndex) { oldValue, newValue in
        print("selectedIndex changed: \(carouselPosition.selectedIndex)")
    }

    // Selected index display.
    HistoricValue(
        label: "index:",
        describingValue: carouselPosition.selectedIndex,
        isMarked: $indexIsMarked
    )
    .configure(spacing: 20)
    .padding(.bottom)

    Divider()

    List {
        VStack {
            Text("ContentWidth: \(shortFraction: carouselContentWidth)")
                .monospaced()
                .maxWidthFrame()
            Text("expected: \(shortFraction: carouselPosition.markLength * carouselPosition.values.count.asDouble)")
                .font(.caption)
                .monospaced()
        }

        Section("Immediate") {
            HStack {
                let indices: [Int] = [0, 2, 9, carouselPosition.values.beforeEndIndex]
                ForEach(indices, id: \.self) { index in
                    let value = carouselPosition.values[index]
                    Button(value) {
                        print("➡️ Selecting by Value: \(value)")
                        valueIsMarked = true
                        indexIsMarked = true
                        carouselPosition.selectValue(value)
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
                        valueIsMarked = true
                        indexIsMarked = true
                        carouselPosition.selectIndex(index)
                    }
                    .buttonStyle(.borderedProminent)
                    .monospaced()
                }
            } // HStack
            .maxWidthFrame()
        } // Section

        Section("Animated") {
            HStack {
                let indices: [Int] = [0, 2, 11, 13, carouselPosition.values.beforeEndIndex]
                ForEach(indices, id: \.self) { index in
                    let value = carouselPosition.values[index]
                    Button(value) {
                        print("➡️ Animated selecting by Value: \(value)")
                        valueIsMarked = true
                        indexIsMarked = true
                        withAnimation {
                            carouselPosition.selectValue(value, immediate: updatesImmediately)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .monospaced()
                }
            } // HStack
            .maxWidthFrame()

            HStack {
                let indices: [Int] = [0, 2, 11]
                ForEach(indices, id: \.self) { index in
                    Button("[\(index)]") {
                        print("➡️ Animated selecting by Index: [\(index)]")
                        valueIsMarked = true
                        indexIsMarked = true
                        withAnimation {
                            carouselPosition.selectIndex(index, immediate: updatesImmediately)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .monospaced()
                }
            } // HStack
            .maxWidthFrame()

            Toggle("Updates Immediately", isOn: $updatesImmediately)
        } // Section
    }
}


// MARK: - Controls & Images


#Preview("Controls&Images", traits: .zeroSpacing, PreviewContent.layout) {
    @Previewable @State var printOnce: PrintOnce = .previewStarted
    @Previewable @State var carouselPosition: DiscreteStepCarouselPosition = .init(
        values: Strings.alphabet.map(\.localizedUppercase),
        selectedValue: "Y",
        markLength: 100)
    @Previewable @State var imageGenerator = ImageGeneratorStore(size: .square(of: 50))
    @Previewable @State var carouselContentWidth: CGFloat = 0.0

    printOnce.print()

    // Selected value display.
    HistoricValue(
        label: "value:",
        value: carouselPosition.selectedValue)

    PreviewContent.indicatorArrow

    DiscreteStepCarousel(position: $carouselPosition) { _, item in
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
    .onScrollGeometryChange(of: \.contentSize.width, binding: $carouselContentWidth)

    // Selected index display.
    HistoricValue(
        label: "index:",
        describingValue: carouselPosition.selectedIndex
    )
    .configure(spacing: 20)
    .padding(.bottom)

    Divider()

    List {
        Section("Immediate") {
            HStack {
                let indices: [Int] = [0, 2, 5, carouselPosition.values.beforeEndIndex]
                ForEach(indices, id: \.self) { index in
                    let value = carouselPosition.values[index]
                    Button(value) {
                        carouselPosition.selectValue(value)
                    }
                    .buttonStyle(.borderedProminent)
                    .monospaced()
                }
            } // HStack
            .maxWidthFrame()

            HStack {
                let indices: [Int] = [0, 2, 4, 6]
                ForEach(indices, id: \.self) { index in
                    Button("[\(index)]") {
                        carouselPosition.selectIndex(index)
                    }
                    .buttonStyle(.borderedProminent)
                    .monospaced()
                }
            } // HStack
            .maxWidthFrame()
        } // Section

        Section("Animated") {
            HStack {
                let indices: [Int] = [0, 2, 11, 15, carouselPosition.values.beforeEndIndex]
                ForEach(indices, id: \.self) { index in
                    let value = carouselPosition.values[index]
                    Button(value) {
                        withAnimation {
                            carouselPosition.selectValue(value)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .monospaced()
                }
            } // HStack
            .maxWidthFrame()

            HStack {
                let indices: [Int] = [0, 2, 12, 14]
                ForEach(indices, id: \.self) { index in
                    Button("[\(index)]") {
                        withAnimation {
                            carouselPosition.selectIndex(index)
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

            ForEach(carouselPosition.values.columnMajorReordered(columns: columns), id: \.self) { item in
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
            Text("ContentWidth: \(shortFraction: carouselContentWidth)")
                .monospaced()
                .maxWidthFrame()
            Text("expected: \(shortFraction: carouselPosition.markLength * carouselPosition.values.count.asDouble)")
                .font(.caption)
                .monospaced()
        }
    } // List
}
