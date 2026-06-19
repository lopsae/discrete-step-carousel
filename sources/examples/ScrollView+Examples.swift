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


#Preview("ContentMargins+ScrollTransition", traits: .headerFooter) {
    @Previewable @State var scrollPosition: ScrollPosition = .init()

    PreviewCaption("""
        Using `contentMargins` causes the phase in `scrollTransition` con consider the space under
        the content margins as _out-of-view_, making the transition occur in a smaller space.
        """)

    ScrollView(.horizontal) {
        HStack(0...9, id: \.self) { index in
            CaptionRectangle("Item \(index)", color: .indigo, size: .square(of: 100))
                .scrollTransition { content, phase in
                    content.opacity(1 - abs(phase.value))
                }
        }
    }
    .contentMargins(.horizontal, .all(100), for: .scrollContent)
}

