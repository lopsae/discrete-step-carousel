//
//  DiscreteStepSlider
//  Created by Maic Lopez Saenz.
//


import SwiftUI
import PreviewUtilities


struct PrototypeSlider: View {

    @Binding var selectedValue: Double

    // Possible values for `selectedValue`
    private(set) var values: [Double]
    // Spacing between the mark for each value.
    private(set) var spacing: Double = 20

    @State private var selectedIndex: Int = 0


    private let scrollViewHeight: CGFloat = 60
    private let markWidth: CGFloat = 2
    private let markHeight: CGFloat = 40


    init(_ values: [Double], selectedValue: Binding<Double>) {
        self.values = values
        self._selectedValue = selectedValue

        // TODO: scroll view to starting position, use defaultScrollAnchor
    }


    var body: some View {
        GeometryReader { geometry in
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
                    .onScrollGeometryChange(for: Int.self) { scrollGeometry in
                        let index = (scrollGeometry.contentOffset.x / spacing).rounded().toInt
                        return index.clamped(to: 0..<values.count)
                    } action: { oldValue, newValue in
                        selectedIndex = newValue
                        selectedValue = values[selectedIndex]
                    }

                } // ZStack
                .frame(height: scrollViewHeight)
            } // VStack
            .frame(width: geometry.size.width)
        } // GeometryReader
        // TODO: move geometry reader to an internal position, to be constrained by height
        .frame(height: 130)
        .debugOutline()
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
    @Previewable @State var selectedValue: Double = 1.5
    let values: [Double] = Array(stride(from: 0.0, to: 3.01, by: 0.2))
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

