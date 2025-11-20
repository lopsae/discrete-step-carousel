//
//  DiscreteStepSlider
//  Created by Maic Lopez Saenz.
//


import SwiftUI


struct DiscreteStepScrollTargetBehavior: ScrollTargetBehavior {
    let step: Double

    func updateTarget(_ target: inout ScrollTarget, context: TargetContext) {
        let targetX = target.rect.origin.x
        target.rect.origin.x = round(targetX / step) * step
    }
}


#Preview {
    let gradient = LinearGradient(
        colors: [.orange, .yellow],
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
            DiscreteStepScrollTargetBehavior(step: spacing)
        )
        .frame(height: 100)
    } // GeometryReader
}
