//
//  DiscreteStepSlider
//  Created by Maic Lopez Saenz.
//


import SwiftUI
import PreviewUtilities


// TODO: values should be generic
// TODO: support vertical slider
struct PrototypeSlider: View {


    struct Position {
        // TODO: values could be updated through position too
        let values: [Double]
        let spacing: Double

        // These properties only should be updated through the available functions, not directly.
        var selectedValue: Double
        var selectedIndex: Int
        var scrollPosition: ScrollPosition

        init(values: [Double], selectedValue: Double, spacing: Double) {
            self.values = values
            self.selectedValue = selectedValue
            self.spacing = spacing

            let selectedIndex = values.firstIndex(of: selectedValue) ?? 0
            self.selectedIndex = selectedIndex
            self.scrollPosition = ScrollPosition()
        }


        mutating func selectValue(_ value: Double) {
            guard let index = values.firstIndex(of: value)
            else { return }

            selectedValue = value
            // TODO: could also call selectIndex
            selectedIndex = index
            scrollPosition.scrollTo(x: index.toDouble * spacing)
        }


        mutating func selectIndex(_ index: Int) {
            guard values.indices.contains(index)
            else { return }

            // TODO: is this necessary? or will it update as the view scrolls?
            selectedValue = values[index]
            selectedIndex = index
            scrollPosition.scrollTo(x: index.toDouble * spacing)
        }

    }


    @Binding var position: Position

    // TODO: still necessary?
    @State private var isInIdlePhase: Bool = false

    private var initialAnchor: UnitPoint

    // Spacing between the mark for each value.
    private let scrollViewHeight: Double = 60
    private let markWidth: Double = 2
    private let markHeight: Double = 40


    init(position positionBinding: Binding<Position>) {
        self._position = positionBinding

        let positionValue = positionBinding.wrappedValue
        let selectedIndex = positionValue.selectedIndex.toDouble
        let spacing  = positionValue.spacing
        let valuesCount = positionValue.values.count.toDouble
        self.initialAnchor = .init(
            x: (selectedIndex * spacing / ((valuesCount - 1) * spacing)),
            y: 0.5)
    }


    var body: some View {
        VStack(spacing: 4) {
            // Selected value display
            Text(position.selectedValue.formatted(.number.precision(.fractionLength(1))))
                .monospacedDigit()
            Text(position.selectedIndex.description)
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
                                .frame(width: (geometry.size.width - position.spacing) / 2)
                                .opacity(0.0)

                            // Marks for each value
                            ForEach(Array(position.values.enumerated()), id: \.offset) { index, value in
                                VStack(spacing: 0) {
                                    // Tick mark
                                    Rectangle()
                                        .fill( .tertiary)
                                        .frame(width: markWidth, height: markHeight)
                                }
                                .frame(width: position.spacing)
                            }

                            // Trailing spacer to center last item
                            Color.teal
                                .frame(width: (geometry.size.width - position.spacing) / 2)
                                .opacity(0.0)
                        }
                    } // ScrollView
                    .scrollTargetBehavior(
                        DiscreteStepScrollTargetBehavior(step: position.spacing)
                    )
                    .defaultScrollAnchor(initialAnchor, for: .initialOffset)
                    .scrollPosition($position.scrollPosition)
                    .onScrollPhaseChange { oldPhase, newPhase in
                        // TODO: check and anotate how phasechange works for user interaction, immediate changes, and animations
                        isInIdlePhase = newPhase == .idle
                    }
                    .onScrollGeometryChange(for: Int.self) { scrollGeometry in
                        let index = (scrollGeometry.contentOffset.x / position.spacing).rounded().toInt
                        let clampedIndex = index.clamped(to: 0..<position.values.count)
                        return clampedIndex
                    } action: { oldValue, newValue in
                        position.selectedIndex = newValue
                        position.selectedValue = position.values[newValue]
                    }
//                    .onChange(of: position.selectedValue) { oldValue, newValue in
//                        // Only respond to external changes, not user-interaction changes.
//                        guard isInIdlePhase,
//                              let newIndex = position.values.firstIndex(of: newValue)
//                        else { return }
//
//                        position.selectedIndex = newIndex
////                        if animated {
////                            withAnimation {
////                                scrollPosition.scrollTo(x: newIndex.toDouble * spacing)
////                            }
////                        } else {
//                        position.sliderPosition.scrollPosition.scrollTo(x: newIndex.toDouble * spacing)
////                        }
//                    }
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
    @Previewable @State var sliderPosition: PrototypeSlider.Position = .init(
        values: Array(stride(from: 0.0, to: 3.01, by: 0.2)),
        selectedValue: 1.6,
        spacing: 20)

    VStack {
        Text("Immediate:")
        HStack {
            let indices: [Int] = [0, 3, 5]
            ForEach(indices, id: \.self) { index in
                let value = sliderPosition.values[index]
                let label = value.formatted(.number.precision(.fractionLength(1)))
                Button(label) {
                    sliderPosition.selectValue(value)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        Text("Animated:")
        HStack {
            let indices: [Int] = [11, 13, 15]
            ForEach(indices, id: \.self) { index in
                let value = sliderPosition.values[index]
                let label = value.formatted(.number.precision(.fractionLength(1)))
                Button(label) {
                    withAnimation {
                        sliderPosition.selectValue(value)
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
    PrototypeSlider(position: $sliderPosition)
        .onChange(of: sliderPosition.selectedValue) { oldValue, newValue in
            // TODO: add print of when the value/index is changed, to show how value sometimes has additional updates
            print("Selected value changed: \(sliderPosition.selectedValue)")
        }
    Text("Selection: \(sliderPosition.selectedValue, format: .number.precision(.fractionLength(1)))")
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

