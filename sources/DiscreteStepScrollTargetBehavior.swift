//
//  DiscreteStepCarousel
//  Created by Maic Lopez Saenz.
//


import SwiftUI


/// Defines a scroll behaviour where the horizontal target allways snaps to the closest multiple of
/// a value.
struct DiscreteStepScrollTargetBehavior: ScrollTargetBehavior {
    let step: Double

    func updateTarget(_ target: inout ScrollTarget, context: TargetContext) {
        let targetX = target.rect.origin.x
        target.rect.origin.x = (targetX / step).rounded(.toNearestOrEven) * step
    }
}


// MARK: - Previews.


private struct PreviewContent {

    static let gradient = LinearGradient(
        colors: [.orange, .orange.opacity(0.5)],
        startPoint: .leading,
        endPoint: .trailing)

}


#Preview("Default", traits: .fixedHeader) {
    let step: Double = 42

    VStack {
        Text("Items with step width will align to leading.")
        Text("Last item might not display fully.")
    }
    .padding(.bottom)

    Image(systemName: "arrowtriangle.down.fill")
        .maxWidthFrame(alignment: .leading)

    GeometryReader { geometry in
        ScrollView(.horizontal) {
            HStack(spacing: 0) {
                ForEach(0..<15) { index in
                    Rectangle()
                        .fill(PreviewContent.gradient)
                        .frame(width: step)
                }
            }
        } // ScrollView
        .scrollTargetBehavior(
            DiscreteStepScrollTargetBehavior(step: step)
        )
    } // GeometryReader
    .frame(height: 100)
}


#Preview("Spacers", traits: .fixedHeader) {
    let step: Double = 50

    Text("Using spacers to center the items.")
        .padding(.bottom)

    Image(systemName: "arrowtriangle.down.fill")

    GeometryReader { geometry in
        ScrollView(.horizontal) {
            HStack(spacing: 0) {
                // Leading spacer to center first item.
                Color.teal
                    .frame(width: (geometry.size.width - step) / 2.0)
                    .opacity(0.2)

                ForEach(0..<10) { index in
                    Rectangle()
                        .fill(PreviewContent.gradient)
                        .frame(width: step)
                }

                // Trailing spacer to center last item.
                Color.teal
                    .frame(width: (geometry.size.width - step) / 2.0)
                    .opacity(0.2)
            }
        } // ScrollView
        .scrollTargetBehavior(
            DiscreteStepScrollTargetBehavior(step: step)
        )

    } // GeometryReader
    .frame(height: 100)
}


#Preview("Content Margins", traits: .fixedHeader) {
    let step: Double = 50

    Text("Using content margins to center the items.")
        .padding(.bottom)

    Image(systemName: "arrowtriangle.down.fill")

    GeometryReader { geometry in
        ScrollView(.horizontal) {
            HStack(spacing: 0) {
                ForEach(0..<10) { index in
                    Rectangle()
                        .fill(PreviewContent.gradient)
                        .frame(width: step)
                }
            }
        } // ScrollView
        .contentMargins(
            .horizontal((geometry.size.width - step) / 2.0),
            for: .scrollContent)
        .scrollTargetBehavior(
            DiscreteStepScrollTargetBehavior(step: step)
        )

    } // GeometryReader
    .frame(height: 100)
}

