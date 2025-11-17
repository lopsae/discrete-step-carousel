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
                Text(String(format: "%.1f", selectedValue))
                    .monospacedDigit()
                    .font(.system(size: 17, weight: .medium))
                Text("\(selectedIndex)")
                    .font(.caption)
                    .monospacedDigit()

                // Indicator arrow
                Image(systemName: "arrowtriangle.down.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(.primary)
                
                // Scrollable slider marks
                ZStack {
                    // Center reference line (highlighted)
                    Rectangle()
                        .fill(.primary)
                        .frame(width: markWidth)
                        .opacity(0.8)
                    
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
                        // TODO: clamp
                        return max(0, min(index, values.count - 1))
                    } action: { oldValue, newValue in
                        selectedIndex = newValue
                        selectedValue = values[selectedIndex]
                    }

                } // ZStack
                .frame(height: scrollViewHeight)
            } // VStack
            .frame(width: geometry.size.width)
        } // GeometryReader
        .frame(height: 130)
        .debugOutline()
    }

}


extension PrototypeSlider {

    struct DiscreteStepScrollTargetBehavior: ScrollTargetBehavior {
        let step: Double

        func updateTarget(_ target: inout ScrollTarget, context: TargetContext) {
            // print("target: \(target.rect.origin.x), vel: \(context.velocity.dx), orig: \(context.originalTarget.rect.origin.x)")
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
    Image(systemName: "arrowtriangle.down.fill")
    GeometryReader { geometry in
        ScrollView(.horizontal) {
            HStack(spacing: 0) {
                // Leading spacer to center first item
                Color.clear
                    .frame(width: (geometry.size.width - 20) / 2)
                    .border(.blue, width: 2)

                ForEach(0..<10) { index in
                    Color.clear
                        .frame(width: 20)
                        .border(.red, width: 2)
                }

                // Trailing spacer to center last item
                Color.clear
                    .frame(width: (geometry.size.width - 20) / 2)
                    .border(.blue, width: 2)
            }
        } // ScrollView
        .scrollTargetBehavior(
            PrototypeSlider.DiscreteStepScrollTargetBehavior(step: 20)
        )
        .frame(height: 100)
    } // GeometryReader
}

