//
//  DiscreteStepCarousel
//  Created by Maic Lopez Saenz.
//


import SwiftUI


/// A type for definining values and spacing for a `DiscreteStepCarousel`, and for accessing or
/// updating the selected value or index.
public struct DiscreteStepCarouselPosition<Values: RandomAccessCollection>
where Values.Element: Equatable {

    /// Collection of values the carousel can select. Each value is represented by a mark.
    public let values: Values

    /// Space available for each mark in the carousel.
    public let markLength: Double

    /// Additional space between marks.
    public let spacing: Double

    /// Selected value, which is `values[selectedIndex]`.
    public internal(set) var selectedValue: Values.Element

    /// Index of the selected value.
    public internal(set) var selectedIndex: Values.Index


    internal var scrollPosition: ScrollPosition

    /// Creates a new Position for a DiscreteStepCarousel.
    /// 
    /// - Parameters:
    ///   - values: All possible values the carousel can select, in the order these will be
    ///     displayed. This collection must contain at least one element.
    ///   - selectedValue: Initial value to be selected. If this value cannot be found in
    ///     `values`, or when the parameter is omitted, the first element in `values` is used as the
    ///     initial selection.
    ///   - markLength: Space available for each mark.
    ///   - spacing: Additional space between marks.
    ///
    ///  - Note: Using this initializer will search sequentially through `values` until a matching
    ///  `selectedValue` is found. For a constant time approach use the
    ///    ``init(values:selectedIndex:markLength:spacing:)`` initializer.
    public init(
        values: Values,
        selectedValue: Values.Element,
        markLength: Double = 22.0,
        spacing: Double = .zero
    ) {
        precondition(!values.isEmpty, "values must contain at least one element")

        self.values = values
        self.selectedValue = selectedValue
        self.markLength = markLength
        self.spacing = spacing

        let selectedIndex = values.firstIndex(of: selectedValue) ?? values.startIndex
        self.selectedIndex = selectedIndex
        self.scrollPosition = ScrollPosition()
    }


    /// Creates a new Position for a DiscreteStepCarousel.
    /// 
    /// - Parameters:
    ///   - values: All possible values the carousel can select, in the order these will be
    ///     displayed. This collection must contain at least one element.
    ///   - selectedIndex: Index of the initial value to be selected, when omitted, the first index
    ///     in `values` is used as the initial selection.
    ///   - markLength: Space available for each mark.
    ///   - spacing: Additional space between marks.
    public init(
        values: Values,
        selectedIndex: Values.Index? = nil,
        markLength: Double = 22.0,
        spacing: Double = .zero
    ) {
        precondition(!values.isEmpty, "values must contain at least one element")
        let selectedIndex = selectedIndex ?? values.startIndex

        self.values = values
        self.selectedIndex = selectedIndex
        self.selectedValue = values[selectedIndex]
        self.markLength = markLength
        self.spacing = spacing

        self.scrollPosition = ScrollPosition()
    }


    /// The total length used by each mark: mark length + spacing.
    public var totalMarkLength: Double { markLength + spacing }


    /// Updates the carousel selection to the given `value`.
    ///  
    /// This function can be called within `withAnimation` for an animated selection. When
    /// animated, both `selectedValue` and `selectedIndex` will be updated immediately once to the
    /// new values if `immediate` is `true`, and then both properties will update again several
    /// times as the animation advances.
    ///
    /// Use `immediate` to ensure both `selectedValue` and `selectedIndex` are updated during this
    /// call. Otherwise, both properties are not updated until the view updates, and the internal
    /// scroll position updates to a new position. When not animated this difference is minimal. When
    /// animating, setting `immediate` to false can help prevent a small flicker of both
    /// `selectedValue` and `selectedIndex` to its final values that then gets overwriten by the
    /// animation advancing through the interim values.
    ///
    /// If `value` cannot be found in `values`, the current selection remains unchanged.
    ///
    /// - Parameters:
    ///   - value: The new value to select.
    ///   - immediate: When `true`, both `selectedValue` and `selectedIndex` are updated immediately
    ///       during this call; otherwise those properties update until the internall scroll
    ///       position updates, or as animation progresses. Defults to `true`.
    ///
    /// - Note: Using this function will search sequentially through `values` until a matching
    ///  `value` is found. For a constant time approach use ``selectIndex(_:immediate:)``.
    public mutating func selectValue(_ value: Values.Element, immediate: Bool = true) {
        guard let index = values.firstIndex(of: value)
        else { return }

        if immediate {
            selectedValue = value
        }
        selectIndex(index, immediate: immediate)
    }


    /// Updates the carousel selection to the value at the given `index` in `values`.
    ///
    /// This function can be called within `withAnimation` for an animated selection. When
    /// animated, `selectedIndex` will be updated immediately once to the new `index` if `immediate`
    /// is `true`, and then `selectedIndex` will update again several times as the animation
    /// progresses. `selectedValue` will update only as the animation advances.
    ///
    /// Use `immediate` to ensure `selectedIndex` is updated during this call. Otherwise,
    /// `selectedIndex` is not updated until the view updates, and the internal scroll position
    /// updates to a newposition. When not animated this difference is minimal. When animating,
    /// setting `immediate` to false can help prevent a small flicker of `selectedIndex` to its
    /// final value that then gets overwriten by the animation advancing through the interim
    /// indices.
    ///
    /// If `index` is not a valid index for `values`, the current selection remains unchanged.
    ///
    /// - Parameters:
    ///   - index: The index for the value in `values` to select.
    ///   - immediate: When `true`, `selectedIndex` is updated immediately during this call;
    ///       otherwise the property updates until the internall scroll position updates, or as
    ///       animation progresses. Defults to `true`.
    public mutating func selectIndex(_ index: Values.Index, immediate: Bool = true) {
        guard values.indices.contains(index)
        else { return }

        if immediate {
            selectedIndex = index
        }
        let indexDistance = values.distance(from: values.startIndex, to: index)
        scrollPosition.scrollTo(x: indexDistance.asDouble * totalMarkLength)
    }

}
