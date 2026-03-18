//
//  DiscreteStepCarousel
//  Created by Maic Lopez Saenz.
//


import SwiftUI


// NEXT: update HistoricValue to show a marked value.
// NEXT: figure out out of setting selecton by index can skip the first immediate value being set.
// NEXT: finish renaming to offset, instead of index.


// TODO: support vertical carousel
public struct DiscreteStepCarousel<Values: Collection, AnchorContent: View, MarkContent: View> : View
where Values.Element: Equatable {

    @Binding var position: DiscreteStepCarouselPosition<Values>

    private let anchorContent: () -> AnchorContent
    private let markContent: (Int, Values.Element) -> MarkContent

    private var initialAnchor: UnitPoint


    public init(
        position positionBinding: Binding<DiscreteStepCarouselPosition<Values>>,
        @ViewBuilder anchorContent: @escaping () -> AnchorContent,
        @ViewBuilder markContent: @escaping (Int, Values.Element) -> MarkContent
    ) {
        self._position = positionBinding
        self.anchorContent = anchorContent
        self.markContent = markContent

        let positionValue = positionBinding.wrappedValue

        let selectedIndexDistance = positionValue.values.distance(fromStartTo: positionValue.selectedIndex)
        let markLength  = positionValue.markLength
        let valuesCount = positionValue.values.count.asDouble
        self.initialAnchor = .init(
            x: (selectedIndexDistance.asDouble * markLength / ((valuesCount - 1) * markLength)),
            y: 0.5)
    }


    public var body: some View {
        ZStack {
            // Geometry reader needs to envelop ScrollView. contentMargings uses the scroll view
            // size to setup margins that allow marks to remain centered.
            GeometryReader { geometry in
                ScrollView(.horizontal, showsIndicators: false) {
                    // TODO: test if AnyLayout/HStackLayout/VStackLayout can provide vertical and horizontal carousel funcionality.
                    LazyHStack(spacing: 0.0) {
                        // Marks for each value.
                        // Identified by offset to ensure each item has an unique identifier,
                        // irregardless of the contents of `values`.
                        ForEach(Array(position.values.enumerated()), id: \.offset) { offset, value in
                            markContent(offset, value)
                            .frame(width: position.markLength, alignment: .center)
                        }
                    }
                } // ScrollView
                .scrollTargetBehavior(
                    // TODO: this could be removed to disable snapping, but selection is still discrete.
                    DiscreteStepScrollTargetBehavior(step: position.markLength)
                )
                .defaultScrollAnchor(initialAnchor, for: .initialOffset)
                .scrollPosition($position.scrollPosition)
                // Content margins set externally do not seem to impact this.
                // Assuming that the last one takes precedence, but this is untested.
                .contentMargins(
                    .horizontal,
                    (geometry.size.width - position.markLength) / 2,
                    for: .scrollContent)
                .onScrollGeometryChange(for: Int.self) { scrollGeometry in
                    let contentPosition = scrollGeometry.contentOffset.x + scrollGeometry.contentInsets.leading
                    let indexDistance = (contentPosition / position.markLength).arithmeticRoundedInt
                    let clampedIndexDistance = position.values.clampDistance(indexDistance)
                    return clampedIndexDistance ?? 0
                } action: { oldValue, newIndexDistance in
                    let newIndex = position.values.index(offsetBy: newIndexDistance)
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
        @ViewBuilder markContent: @escaping (Int, Values.Element) -> MarkContent
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
