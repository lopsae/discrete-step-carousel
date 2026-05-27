//
//  DiscreteStepCarousel
//  Created by Maic Lopez Saenz.
//


import PreviewUtilities
import SwiftUI


#Preview("Slider+ScrollView", traits: .headerFooter) {
    @Previewable @State var sliderValue: Double = 0.5
    @Previewable @State var scrollPosition: ScrollPosition = .init()
    @Previewable @State var contentOffsetWidth: CGFloat = .zero

    PreviewCaption("""
        Two `ScrollView`s can be updated simultaneously with a single `ScrollPosition`, however
        the position of each scroll view can only be read individually though 
        `onScrollGeometryChange`.
        """)

    Slider.captioned("Slider Value", value: $sliderValue, valueFormat: .fractionLength(2))
    ScrollView(.horizontal) {
        HStack(0...9, id: \.self) { index in
            CaptionRectangle("Item \(index)", color: .purple, size: .square(of: 100))
        }
    }
    .onChange(of: sliderValue) {
        let xPosition = sliderValue * contentOffsetWidth
        scrollPosition.scrollTo(x: xPosition)
    }
    .defaultScrollAnchor(.center)
    .scrollPosition($scrollPosition)
    .onScrollGeometryChange(of: \.contentOffsetSize.width, binding: $contentOffsetWidth)

    ScrollView(.horizontal) {
        HStack(0...9, id: \.self) { index in
            CaptionRectangle("Item \(index)", color: .purple, size: .square(of: 100))
        }
    }
    .onChange(of: sliderValue) {
        let xPosition = sliderValue * contentOffsetWidth
        scrollPosition.scrollTo(x: xPosition)
    }
    .defaultScrollAnchor(.center)
    .scrollPosition($scrollPosition)
    .onScrollGeometryChange(of: \.contentOffsetSize.width, binding: $contentOffsetWidth)

    DashedDivider()

    Text("Scroll Position X: \(scrollPosition.x?.description ?? "nil")")
    Text("Position set by user: \(scrollPosition.isPositionedByUser.description)")
}
