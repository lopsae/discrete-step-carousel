//
//  DiscreteStepSlider
//  Created by Maic Lopez Saenz.
//


import SwiftUI


// NEXT: move to own file, see todos
/// A type for definining values and spacing for a `DiscreteStepSlider`, and for accessing or
/// updating the selected value or index.
public struct DiscreteStepSliderPosition<Values: Collection>
where Values.Element: Equatable {

    /// Collection of values the slider can select. Each value is represented by a slider mark.
    public let values: Values

    /// Space available in the slider to select each value.
    public let markLength: Double

    // TODO: setup an executable project and test this is not accessible.
    /// Selected value, which is `values[selectedIndex]`.
    internal var selectedValue: Values.Element

    /// Index of the selected value.
    public internal(set) var selectedIndex: Values.Index


    internal var scrollPosition: ScrollPosition


    /// Creates a new Position for a DiscreteStepSlider.
    ///
    /// - Parameters:
    ///   - values: All possible values the slider can select, in the order these will be
    ///     displayed.
    ///   - selectedValue: Initial value to be selected. If this value cannot be found in
    ///     `values`, an index of `0` will be selected instead.
    ///   - markLength: Space available in the slider to select each value.
    public init(values: Values, selectedValue: Values.Element, markLength: Double = 22.0) {
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
    public mutating func selectValue(_ value: Values.Element) {
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
    ///
    /// - Parameter index: The index for the value in `values` to select.
    public mutating func selectIndex(_ index: Values.Index) {
        guard values.indices.contains(index)
        else { return }

        selectedIndex = index
        let indexDistance = values.distance(from: values.startIndex, to: index)
        scrollPosition.scrollTo(x: indexDistance.asDouble * markLength)
    }

}
