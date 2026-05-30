//
//  DiscreteStepCarousel
//  Created by Maic Lopez Saenz.
//


import SwiftUI


/// A control for selecting a value from a collection, with each value represented by a view in a
/// scrollable surface.
///
/// The discrete step carousel maps a collection of identified values to a scrollable sequence of
/// views. The user can scroll between these views to select one value at a time.
///
/// ### Carousel Position
///
/// ``StepCarouselPosition`` is the structure that provides the data and layout information
/// for a step carousel. It is also used to read and update the currently selected index or element.
///
/// Calling ``StepCarouselPosition/selectValue(_:immediate:)`` or ``StepCarouselPosition/selectIndex(_:immediate:)``
/// in a animation block will animate the carousel to the selected position.
///
/// ### Marks and Sizing
///
/// Each of the views that represent a carousel value is referred as a mark. The anchor is a view
/// that floats over all marks and signals the selected mark.
///
/// Use the ``init(position:)`` or ``init(position:anchorStyle:markStyle:)`` initializers to use the
/// default marks.
///
/// Use the ``init(position:anchorContent:markContent:)`` or ``init(position:markContent:)`` to
/// provide a closure to build the view for each mark.
///
/// The carousel control will expand to occupy all available space. Use a frame or other layout
/// modifiers to constrain its size to the appropriate dimensions. The size available for each mark
/// is determined by the ``StepCarouselPosition/markLength`` property, which each mark view
/// centered in the available space.
public struct DiscreteStepCarousel<Values, AnchorContent, MarkContent> : View
where
    Values: RandomAccessCollection,
    Values.Index: Hashable,
    Values.Element: Equatable,
    AnchorContent: View,
    MarkContent: View
{

    @Binding var position: StepCarouselPosition<Values>

    private let anchorContent: () -> AnchorContent

    private let markContent: (Values.Index, Values.Element) -> MarkContent

    private var initialAnchor: UnitPoint


    public init(
        position positionBinding: Binding<StepCarouselPosition<Values>>,
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


    @_documentation(visibility: internal)
    public var body: some View {
        ZStack {
            // Geometry reader needs to envelop ScrollView, contentMargins uses the scroll view
            // size to setup margins that allow marks to remain centered.
            GeometryReader { geometry in
                ScrollView(.horizontal, showsIndicators: false) {
                    // FUTURE: test if AnyLayout/HStackLayout/VStackLayout can provide vertical and horizontal carousel functionality.
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

// TODO: update to primary and secondary/tertiary
struct DiscreteStepCarouselDefaults {
    static let anchorStyle: Color = .black
    static let markStyle: Color = .gray
}


// MARK: - Convenience initializers


extension DiscreteStepCarousel {

    public init(
        position positionBinding: Binding<StepCarouselPosition<Values>>,
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
        position positionBinding: Binding<StepCarouselPosition<Values>>
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
        position positionBinding: Binding<StepCarouselPosition<Values>>,
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
