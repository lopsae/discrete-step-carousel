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


    init(_ values: [Double], selectedValue: Binding<Double>) {
        self.values = values
        self._selectedValue = selectedValue
    }
    
    private var currentIndex: Int {
        guard let index = values.firstIndex(of: selectedValue) else {
            return 0
        }
        return index
    }
    
    private func indexForOffset(_ offset: CGFloat, containerWidth: CGFloat) -> Int {
        let centerOffset = containerWidth / 2
        let adjustedOffset = offset + centerOffset
        let index = Int(round(adjustedOffset / spacing))
        return max(0, min(values.count - 1, index))
    }
    
    private func offsetForIndex(_ index: Int, containerWidth: CGFloat) -> CGFloat {
        let centerOffset = containerWidth / 2
        return CGFloat(index) * spacing - centerOffset
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
                        .frame(width: 2)
                        .opacity(0.8)
                    
                    // Scrollable content
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 0) {
                            // Leading spacer to center first item
                            Color.clear
                                .frame(width: (geometry.size.width - spacing) / 2)
                                .debugOutline()

                            // Marks for each value
                            ForEach(Array(values.enumerated()), id: \.offset) { index, value in
                                VStack(spacing: 0) {
                                    // Tick mark
                                    Rectangle()
                                        .fill(index == currentIndex ? .primary : .secondary)
                                        .frame(width: 2, height: markHeight(for: index))
                                        .opacity(index == currentIndex ? 1.0 : 0.6)
                                    
                                    // Value label for every 5th mark or current selection
                                    if index % 5 == 0 || index == currentIndex {
                                        Text(String(format: "%.1f", value))
                                            .font(.system(size: 10))
                                            .foregroundStyle(.secondary)
                                            .monospacedDigit()
                                            .padding(.top, 4)
                                    }
                                }
                                .frame(width: spacing)
                            }
                            
                            // Trailing spacer to center last item
                            Color.clear
                                .frame(width: (geometry.size.width - spacing) / 2)
                                .debugOutline()
                        }
                    }
                    .onScrollGeometryChange(for: Int.self, of: { scrollGeometry in
                        let index = (scrollGeometry.contentOffset.x / spacing).rounded().toInt
                        return max(0, min(index, values.count - 1))
                    }, action: { oldValue, newValue in
                        selectedIndex = newValue
//                        print(newValue)
                    })
//                    .scrollPosition(.init(get: {
//                        ScrollPosition.init(edge: .leading)
//                    }, set: { position in
//                        print(position.x?.description)
//                    }))
//                    .scrollPosition(id: .init(
//                        get: { currentIndex },
//                        set: { newValue in
//                            if let newIndex = newValue, newIndex < values.count {
//                                selectedValue = values[newIndex]
//                            }
//                        }
//                    ))
                    .scrollTargetBehavior(
                        DiscreteStepScrollTargetBehavior(step: spacing)
                    )
                }
                .frame(height: 60)
            }
            .frame(width: geometry.size.width)
        }
        .frame(height: 100)
    }
    
    private func markHeight(for index: Int) -> CGFloat {
        // Make every 10th mark taller, every 5th mark medium, others short
        if index % 10 == 0 {
            return 40
        } else if index % 5 == 0 {
            return 30
        } else {
            return 20
        }
    }

}


extension PrototypeSlider {

    struct DiscreteStepScrollTargetBehavior: ScrollTargetBehavior {
        let step: Double

        func updateTarget(_ target: inout ScrollTarget, context: TargetContext) {
            print("target: \(target.rect.origin.x), vel: \(context.velocity.dx), orig: \(context.originalTarget.rect.origin.x)")
            let targetX = target.rect.origin.x
            target.rect.origin.x = round(targetX / step) * step
        }
    }

}


#Preview {
    @Previewable @State var selectedValue: Double = 1.5
    let values: [Double] = Array(stride(from: 0.0, to: 3.0, by: 0.1))
    PrototypeSlider(values, selectedValue: $selectedValue)
}


#Preview("Scroll targets") {
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

