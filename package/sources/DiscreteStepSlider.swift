//
//  DiscreteStepSlider
//  Created by Maic Lopez Saenz.
//


import SwiftUI
import PreviewUtilities


// TODO: support vertical slider
struct DiscreteStepSlider<Values: Collection, AnchorContent: View, MarkContent: View> : View
where Values.Element: Equatable {

    @Binding var position: DiscreteStepSliderPosition<Values>

    private let anchorContent: () -> AnchorContent
    private let markContent: (Values.Element) -> MarkContent

    private var initialAnchor: UnitPoint


    init(
        position positionBinding: Binding<DiscreteStepSliderPosition<Values>>,
        @ViewBuilder anchorContent: @escaping () -> AnchorContent,
        @ViewBuilder markContent: @escaping (Values.Element) -> MarkContent
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


    var body: some View {
        ZStack {
            // TODO: is geometry reader needed outside of scrollView?
            // Scrollable content.
            GeometryReader { geometry in
                ScrollView(.horizontal, showsIndicators: false) {
                    // TODO: test if AnyLayout/HStackLayout/VStackLayout can provide vertican and horisontal slider funcionality
                    LazyHStack(spacing: 0.0) {
                        // Marks for each value.
                        // Identified by offset to ensure each item has an unique identifier,
                        // irregardless of the contents of `values`.
                        ForEach(Array(position.values.enumerated()), id: \.offset) { index, value in
                            markContent(value)
                            .frame(width: position.markLength, alignment: .center)
                        }
                    }
                } // ScrollView
                .scrollTargetBehavior(
                    DiscreteStepScrollTargetBehavior(step: position.markLength)
                )
                .defaultScrollAnchor(initialAnchor, for: .initialOffset)
                .scrollPosition($position.scrollPosition)
                .contentMargins(.horizontal, .all((geometry.size.width - position.markLength) / 2), for: .scrollContent)
                .onScrollGeometryChange(for: Int.self) { scrollGeometry in
                    let contentPosition = scrollGeometry.contentOffset.x + scrollGeometry.contentInsets.leading
                    let indexDistance = (contentPosition / position.markLength).rounded().asInt
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





struct DiscreteStepSliderDefaults {
    static let anchorStyle: Color = .black
    static let markStyle: Color = .gray
}


struct DefaultMark<Style: ShapeStyle>: View {

    let fill: Style

    var body: some View {
        Rectangle()
            .fill(fill)
            .frame(width: 2)
    }
}


extension DiscreteStepSlider {


    init(
        position positionBinding: Binding<DiscreteStepSliderPosition<Values>>,
        @ViewBuilder markContent: @escaping (Values.Element) -> MarkContent
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


    init(
        position positionBinding: Binding<DiscreteStepSliderPosition<Values>>
    )
    where
        AnchorContent == DefaultMark<Color>,
        MarkContent == DefaultMark<Color>
    {
        self.init(
            position: positionBinding,
            anchorContent: { DefaultMark(fill: DiscreteStepSliderDefaults.anchorStyle) },
            markContent: { _ in DefaultMark(fill: DiscreteStepSliderDefaults.markStyle) }
        )
    }


    init<AnchorStyle: ShapeStyle, MarkStyle: ShapeStyle>(
        position positionBinding: Binding<DiscreteStepSliderPosition<Values>>,
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
            markContent: { _ in DefaultMark(fill: markStyle) }
        )
    }

}
