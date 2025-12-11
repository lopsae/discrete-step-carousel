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


/// A type for definining values and spacing for a `DiscreteStepSlider`, and for accessing or
/// updating the selected value or index.
struct DiscreteStepSliderPosition<Values: Collection>
where Values.Element: Equatable {

    /// Collection of possible values the slider can select. Each value is represented by a
    /// mark or a custom view in order.
    // TODO: values could be updated through position too
    let values: Values

    /// Space available in the slider to select each value.
    let markLength: Double

    // These properties only should be updated through the available functions, not directly.
    // TODO: can these be set as internal(set)? or fileprivate(set)?
    var selectedValue: Values.Element
    var selectedIndex: Values.Index
    var scrollPosition: ScrollPosition


    /// Creates a new Position for a DiscreteSlider.
    /// - Parameters:
    ///   - values: All possible values the slider can select, in the order these will be
    ///     displayed.
    ///   - selectedValue: Initial value to be selected. If this value cannot be found in
    ///     `values`, an index of `0` will be selected instead.
    ///   - markLength: Space available in the slider to select each value.
    init(values: Values, selectedValue: Values.Element, markLength: Double = 22.0) {
        self.values = values
        self.selectedValue = selectedValue
        self.markLength = markLength

        let selectedIndex = values.firstIndex(of: selectedValue) ?? values.startIndex
        self.selectedIndex = selectedIndex
        self.scrollPosition = ScrollPosition()
    }


    /// Updates the slider selection to the given `value`.
    ///
    /// This function can be called within `withAnimation` for an animated selection. When
    /// animated, `selectedValue` will be updated immediately once to the new `value`, and then
    /// updated again several times as the animation progresses until `value` is reached again.
    /// `selectedIndex` will likewise be updated to the selected index, and then update
    /// several times during the animation.
    ///
    /// Use ``selectIndex(_:)`` to prevent the initial change in `selectedValue` from happening.
    ///
    /// If `value` cannot be found in `values`, the current selection remains unchanged.
    ///
    /// - Parameter value: The new value to select.
    mutating func selectValue(_ value: Values.Element) {
        guard let index = values.firstIndex(of: value)
        else { return }

        selectedValue = value
        selectIndex(index)
    }


    /// Updates the slider selection to the value at the given `index` in `values`.
    ///
    /// This function can be called within `withAnimation` for an animated selection. When
    /// animated, `selectedIndex` will be updated immediately once to the new `index`, and then
    /// updated again several times as the animation progresses until `index` is reached again.
    /// `selectedValue` will update only as the animation happens, until the value at `index`
    /// is reached at the end of the animation.
    ///
    /// If `index` is not a valid index for `values`, the current selection remains unchanged.
    /// - Parameter index: The index for the value in `values` to select.
    mutating func selectIndex(_ index: Values.Index) {
        guard values.indices.contains(index)
        else { return }

        selectedIndex = index
        let indexDistance = values.distance(from: values.startIndex, to: index)
        scrollPosition.scrollTo(x: indexDistance.asDouble * markLength)
    }

}


struct DiscreteStepSliderDefaults {
    // TODO: revert to black or gray after migration
    static let anchorStyle: Color = .teal
    static let markStyle: Color = .purple
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

}
