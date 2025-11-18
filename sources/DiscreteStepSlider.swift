//
//  DiscreteStepSlider
//  Created by Maic Lopez Saenz.
//


import SwiftUI
import PreviewUtilities


struct PrototypeSlider: View {

    @Binding var selectedValue: Double

    @State private var selectedIndex: Int = 0
    @State private var scrollPosition: ScrollPosition = .init()

    // Possible values for `selectedValue`
    private(set) var values: [Double]

    private var initialAnchor: UnitPoint

    // Spacing between the mark for each value.
    private(set) var spacing: Double = 20
    private let scrollViewHeight: Double = 60
    private let markWidth: Double = 2
    private let markHeight: Double = 40


    init(_ values: [Double], selectedValue: Binding<Double>) {
        let selectedIndex = values.firstIndex(of: selectedValue.wrappedValue) ?? 0

        self.values = values
        self.selectedIndex = selectedIndex
        self._selectedValue = selectedValue

        self.initialAnchor = .init(
            x: (selectedIndex.toDouble * spacing / ((values.count - 1).toDouble * spacing)),
            y: 0.5)

        scrollPosition.scrollTo(x: selectedIndex.toDouble * spacing)
    }


    var body: some View {
        VStack(spacing: 4) {
            // Selected value display
            Text(selectedValue.formatted(.number.precision(.fractionLength(1))))
                .monospacedDigit()
            Text(selectedIndex.description)
                .font(.caption)
                .monospacedDigit()

            // Indicator arrow
            Image(systemName: "arrowtriangle.down.fill")
                .font(.caption)

            // Scrollable slider marks
            ZStack {
                // Center reference line (highlighted)
                Rectangle()
                    .fill(.primary)
                    .frame(width: markWidth)

                // Scrollable content
                GeometryReader { geometry in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 0) {
                            // Leading spacer to center first item
                            Color.teal
                                .frame(width: (geometry.size.width - spacing) / 2)
                                .opacity(0.0)

                            // Marks for each value
                            ForEach(Array(values.enumerated()), id: \.offset) { index, value in
                                VStack(spacing: 0) {
                                    // Tick mark
                                    Rectangle()
                                        .fill( .tertiary)
                                        .frame(width: markWidth, height: markHeight)
                                }
                                .frame(width: spacing)
                            }

                            // Trailing spacer to center last item
                            Color.teal
                                .frame(width: (geometry.size.width - spacing) / 2)
                                .opacity(0.0)
                        }
                    } // ScrollView
                    .scrollTargetBehavior(
                        DiscreteStepScrollTargetBehavior(step: spacing)
                    )
                    .defaultScrollAnchor(initialAnchor, for: .initialOffset)
                    .scrollPosition($scrollPosition)
                    .onScrollGeometryChange(for: Int.self) { scrollGeometry in
                        let index = (scrollGeometry.contentOffset.x / spacing).rounded().toInt
                        return index.clamped(to: 0..<values.count)
                    } action: { oldValue, newValue in
                        selectedIndex = newValue
                        selectedValue = values[selectedIndex]
                    }
                } // GeometryReader
            } // ZStack
            .frame(height: scrollViewHeight)
        } // VStack
    }

}


extension PrototypeSlider {

    struct DiscreteStepScrollTargetBehavior: ScrollTargetBehavior {
        let step: Double

        func updateTarget(_ target: inout ScrollTarget, context: TargetContext) {
            let targetX = target.rect.origin.x
            target.rect.origin.x = round(targetX / step) * step
        }
    }

}


#Preview {
    @Previewable @State var selectedValue: Double = 1.6
    let values: [Double] = Array(stride(from: 0.0, to: 3.01, by: 0.2))

    // TODO: upon modification of binding, scroll should modify its position
    HStack {
        let indices: [Int] = [1, 3, 5, 10]
        ForEach(indices, id: \.self) { index in
            let value = values[index]
            let label = value.formatted(.number.precision(.fractionLength(1)))
            Button(label) {
                selectedValue = value
            }
            .buttonStyle(.borderedProminent)
        }
    }
    PrototypeSlider(values, selectedValue: $selectedValue)
    Text("Selection: \(selectedValue, format: .number.precision(.fractionLength(1)))")
        .monospaced()
}


#Preview("Example: scrollTargetBehavior") {
    let gradient = LinearGradient(
        colors: [.orange, .orange.opacity(0.8)],
        startPoint: .leading,
        endPoint: .trailing)
    let spacing: CGFloat = 30
    Image(systemName: "arrowtriangle.down.fill")
    GeometryReader { geometry in
        ScrollView(.horizontal) {
            HStack(spacing: 0) {
                // Leading spacer to center first item
                Color.teal
                    .frame(width: (geometry.size.width - spacing) / 2)
                    .opacity(0.2)

                ForEach(0..<10) { index in
                    Rectangle()
                        .fill(gradient)
                        .frame(width: spacing)
                }

                // Trailing spacer to center last item
                Color.teal
                    .frame(width: (geometry.size.width - spacing) / 2)
                    .opacity(0.2)
            }
        } // ScrollView
        .scrollTargetBehavior(
            PrototypeSlider.DiscreteStepScrollTargetBehavior(step: 20)
        )
        .frame(height: 100)
    } // GeometryReader
}

