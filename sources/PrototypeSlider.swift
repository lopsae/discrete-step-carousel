//
//  DiscreteStepSlider
//  Created by Maic Lopez Saenz.
//


import SwiftUI
import PreviewUtilities


struct PrototypeSlider: View {

    struct SliderPosition {
//        var selectedValue: Double
//        var scrollOffset: CGPoint

        var scrollPosition: ScrollPosition

//        var scrollPosition: ScrollPosition {
//            get {
//                print("gettting point.x: \(scrollOffset.x)")
//                return .init(point: scrollOffset)
//            }
//            mutating set {
//                print("setting: \(newValue)")
//                if let newPoint = newValue.point {
//                    print("setting point.x: \(newPoint.x)")
//                    scrollOffset = newPoint
//                }
//            }
//        }
    }

    // TODO: make slider position the single point of truth, containing both selectedValue and ScrollPosition
    // with functions to scroll to a given value that internally always modify the scroll position
    @Binding var selectedValue: Double
    @Binding var sliderPosition: SliderPosition

    // Possible values for `selectedValue`.
    let values: [Double]
//    let animated: Bool

    @State private var selectedIndex: Int = 0
//    @State private var scrollPosition: ScrollPosition = .init()
    @State private var isInIdlePhase: Bool = false

    private var initialAnchor: UnitPoint

    // Spacing between the mark for each value.
    private(set) var spacing: Double = 20
    private let scrollViewHeight: Double = 60
    private let markWidth: Double = 2
    private let markHeight: Double = 40


    init(
        _ values: [Double],
        selectedValue: Binding<Double>,
        sliderPosition: Binding<SliderPosition>
        /*animated: Bool = false*/
    ) {
        let selectedIndex = values.firstIndex(of: selectedValue.wrappedValue) ?? 0

        self.values = values
        self.selectedIndex = selectedIndex
        self._selectedValue = selectedValue
        self._sliderPosition = sliderPosition
//        self.animated = animated

        self.initialAnchor = .init(
            x: (selectedIndex.toDouble * spacing / ((values.count - 1).toDouble * spacing)),
            y: 0.5)

//        self.sliderPosition.selectedValue = selectedValue.wrappedValue
//        self.sliderPosition.scrollOffset = CGPoint(
//            x: selectedIndex.toDouble * spacing,
//            y: 0)
//
//        print("init:\(self.sliderPosition.scrollOffset.x)")

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
                    .scrollPosition($sliderPosition.scrollPosition)
                    .onScrollPhaseChange { oldPhase, newPhase in
                        isInIdlePhase = newPhase == .idle
                    }
                    .onScrollGeometryChange(for: Int.self) { scrollGeometry in
                        let index = (scrollGeometry.contentOffset.x / spacing).rounded().toInt
                        return index.clamped(to: 0..<values.count)
                    } action: { oldValue, newValue in
                        selectedIndex = newValue
                        selectedValue = values[selectedIndex]
                    }
                    .onChange(of: selectedValue) { oldValue, newValue in
                        // Only respond to external changes, not user-interaction changes.
                        guard isInIdlePhase,
                              let newIndex = values.firstIndex(of: newValue)
                        else { return }

                        selectedIndex = newIndex
//                        if animated {
//                            withAnimation {
//                                scrollPosition.scrollTo(x: newIndex.toDouble * spacing)
//                            }
//                        } else {
                        sliderPosition.scrollPosition.scrollTo(x: newIndex.toDouble * spacing)
//                        }
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
    @Previewable @State var sliderPosition: PrototypeSlider.SliderPosition = .init(scrollPosition: .init())
//    @Previewable @State var animated: Bool = false
    let values: [Double] = Array(stride(from: 0.0, to: 3.01, by: 0.2))

    VStack {
        HStack {
            let indices: [Int] = [0, 3, 5]
            ForEach(indices, id: \.self) { index in
                let value = values[index]
                let label = value.formatted(.number.precision(.fractionLength(1)))
                Button(label) {
//                    animated = false
                    selectedValue = value
                }
                .buttonStyle(.borderedProminent)
            }
        }
        Text("Animated:")
        HStack {
            let indices: [Int] = [11, 13, 15]
            ForEach(indices, id: \.self) { index in
                let value = values[index]
                let label = value.formatted(.number.precision(.fractionLength(1)))
                // TODO: animation does not seem to trigger
                // maybe because the update to scrollPosition happens until onChange, which may not happen within the animation block
                Button(label) {
//                    animated = true
//                    selectedValue = value
                    withAnimation {
                        sliderPosition.scrollPosition.scrollTo(x: index.toDouble * 20)// scrollOffset = CGPoint(
//                            x: index.toDouble * 20,
//                            y: 0.0)
                        print("sliderTo \(sliderPosition.scrollPosition.x)")
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
    PrototypeSlider(values, selectedValue: $selectedValue, sliderPosition: $sliderPosition /*animated: animated*/)
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

