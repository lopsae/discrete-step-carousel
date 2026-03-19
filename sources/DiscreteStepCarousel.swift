//
//  DiscreteStepCarousel
//  Created by Maic Lopez Saenz.
//


import SwiftUI


// NEXT: updaate previews with spacing.
// NEXT: make preview to show that the size read by geometry readed inside a mark matches the given length.


// TODO: support vertical carousel
public struct DiscreteStepCarousel<Values, AnchorContent, MarkContent> : View
where
    Values: RandomAccessCollection,
    Values.Index: Hashable,
    Values.Element: Equatable,
    AnchorContent: View,
    MarkContent: View
{

    @Binding var position: DiscreteStepCarouselPosition<Values>

    private let anchorContent: () -> AnchorContent

    private let markContent: (Values.Index, Values.Element) -> MarkContent

    private var initialAnchor: UnitPoint


    public init(
        position positionBinding: Binding<DiscreteStepCarouselPosition<Values>>,
        @ViewBuilder anchorContent: @escaping () -> AnchorContent,
        @ViewBuilder markContent: @escaping (Values.Index, Values.Element) -> MarkContent
    ) {
        self._position = positionBinding
        self.anchorContent = anchorContent
        self.markContent = markContent

        let positionValue = positionBinding.wrappedValue

        let selectedIndexDistance = positionValue.values.distance(fromStartTo: positionValue.selectedIndex).asDouble
        let totalMarkLength  = positionValue.totalMarkLength
        let valuesCount = positionValue.values.count.asDouble
        self.initialAnchor = .init(
            x: (selectedIndexDistance * totalMarkLength / ((valuesCount - 1) * totalMarkLength)),
            y: 0.5)
    }


    public var body: some View {
        ZStack {
            // Geometry reader needs to envelop ScrollView, contentMargins uses the scroll view
            // size to setup margins that allow marks to remain centered.
            GeometryReader { geometry in
                ScrollView(.horizontal, showsIndicators: false) {
                    // TODO: test if AnyLayout/HStackLayout/VStackLayout can provide vertical and horizontal carousel funcionality.
                    LazyHStack(spacing: .zero) {
                        // Marks for each value, identified by their index.
                        // This identification is NOT used for any scroll position identification.
                        // Selection is done entirely by geometry changes.
                        ForEach(position.values.indices, id: \.self) { index in
                            let value = position.values[index]
                            markContent(index, value)
                            .frame(width: position.markLength, alignment: .center)
                            .padding(.horizontal, position.spacing/2)
                        }
                    }
                } // ScrollView
                .scrollTargetBehavior(
                    DiscreteStepScrollTargetBehavior(step: position.totalMarkLength)
                )
                .defaultScrollAnchor(initialAnchor, for: .initialOffset)
                .scrollPosition($position.scrollPosition)
                // Content margins set externally do not seem to impact this.
                // Assuming that the last one takes precedence, but this is untested.
                .contentMargins(
                    .horizontal,
                    (geometry.size.width - position.totalMarkLength) / 2,
                    for: .scrollContent)
                .onScrollGeometryChange(for: Int.self) { scrollGeometry in
                    let contentPosition = scrollGeometry.contentOffset.x + scrollGeometry.contentInsets.leading
                    let indexDistance = (contentPosition / position.totalMarkLength).arithmeticRoundedInt
                    let clampedIndexDistance = position.values.clampDistance(indexDistance)
                    return clampedIndexDistance ?? 0
                } action: { oldValue, newIndexDistance in
                    // Main calculation and set for both `selectedIndex` and `selectedValue`.
                    // Updates the position values as the user drags the scroll view.
                    // When `position.selectIndex` or `position.selectValue` are used, this code
                    // ultimately sets the final value either after animations, or when the view
                    // state updates.
                    let newIndex = position.values.index(startOffsetBy: newIndexDistance)
                    position.selectedIndex = newIndex
                    position.selectedValue = position.values[newIndex]
                }
            } // GeometryReader

            anchorContent()
        } // ZStack
    }

}


// MARK: - Defaults


struct DiscreteStepCarouselDefaults {
    static let anchorStyle: Color = .black
    static let markStyle: Color = .gray
}


// MARK: - DefaultMark


public struct DefaultMark<Style: ShapeStyle>: View {

    let fill: Style

    public var body: some View {
        Rectangle()
            .fill(fill)
            .frame(width: 2)
    }
}


// MARK: - Convenience initializers


extension DiscreteStepCarousel {

    public init(
        position positionBinding: Binding<DiscreteStepCarouselPosition<Values>>,
        @ViewBuilder markContent: @escaping (Values.Index, Values.Element) -> MarkContent
    )
    where
        AnchorContent == EmptyView
    {
        self.init(
            position: positionBinding,
            anchorContent: { EmptyView() },
            markContent: markContent
        )
    }


    public init(
        position positionBinding: Binding<DiscreteStepCarouselPosition<Values>>
    )
    where
        AnchorContent == DefaultMark<Color>,
        MarkContent == DefaultMark<Color>
    {
        self.init(
            position: positionBinding,
            anchorContent: { DefaultMark(fill: DiscreteStepCarouselDefaults.anchorStyle) },
            markContent: { _, _ in DefaultMark(fill: DiscreteStepCarouselDefaults.markStyle) }
        )
    }


    public init<AnchorStyle: ShapeStyle, MarkStyle: ShapeStyle>(
        position positionBinding: Binding<DiscreteStepCarouselPosition<Values>>,
        anchorStyle: AnchorStyle,
        markStyle: MarkStyle
    )
    where
        AnchorContent == DefaultMark<AnchorStyle>,
        MarkContent == DefaultMark<MarkStyle>
    {
        self.init(
            position: positionBinding,
            anchorContent: { DefaultMark(fill: anchorStyle) },
            markContent: { _, _ in DefaultMark(fill: markStyle) }
        )
    }

}
