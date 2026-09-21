//
//  DiscreteStepCarousel
//  Created by Maic Lopez Saenz.
//


import SwiftUI


/// A structure for reading and updating the selected index of a `StepCarousel`, and for specifying
/// the values and layout properties.
///
/// A ``StepCarousel`` uses a binding to an instance of this type store the state of the selected
/// index. The instance also contains the collection of selectable values and layout properties.
///
/// Use ``StepCarouselPosition/selectValue(_:immediate:)`` and ``StepCarouselPosition/selectIndex(_:immediate:)``
/// to update the carousel selection by either value or index.
///
///
/// ### Animation
///
/// The selection functions ``StepCarouselPosition/selectValue(_:immediate:)`` and ``StepCarouselPosition/selectIndex(_:immediate:)``
/// can be used within animation blocks to animate the carousel to a new selected value. For
/// animations it is recommended to call these functions with the parameter `immediate: false` to
/// prevent flickering of the selected value.
///
/// See the documentation of ``StepCarouselPosition/selectValue(_:immediate:)`` and ``StepCarouselPosition/selectIndex(_:immediate:)``
/// for more details.
public struct StepCarouselPosition<Values>
where
    Values: RandomAccessCollection,
    Values.Element: Equatable
{

    /// Collection of values the carousel can select.
    ///
    /// Each value is represented by a mark view in the carousel.
    ///
    /// The values in this collection are not required be unique. Each mark is identified by its
    /// index, not the value it represents.
    ///
    /// - Note:
    /// The collection **must** contain at least one value. An empty collection will trigger
    /// a precondition failure when initialized.
    public let values: Values

    /// Length available for each mark in the carousel.
    ///
    /// The space available for each mark is determined by this property and the height of the
    /// carousel control.
    public let markLength: Double

    /// Additional space between marks.
    public let spacing: Double

    /// Selected value, which is `values[selectedIndex]`.
    public internal(set) var selectedValue: Values.Element

    /// Index of the selected value.
    public internal(set) var selectedIndex: Values.Index

    internal var scrollPosition: ScrollPosition


    /// Creates a position for a carousel control, selecting an initial value.
    ///
    /// - Parameters:
    ///   - values: The possible values the carousel can select, in the order these will be
    ///     displayed. This collection must contain at least one element.
    ///   - selectedValue: The initial value to be selected. If this value cannot be found in
    ///     `values`, or when the parameter is omitted, the first element in `values` is used as the
    ///     initial selection.
    ///   - markLength: The space available for each mark.
    ///   - spacing: Additional spacing between marks.
    ///
    /// - Note:
    /// The `values` collection **must** contain at least one value. An empty collection will
    /// trigger a precondition failure.
    ///
    /// - Note: Using this initializer will search sequentially through `values` until a matching
    /// `selectedValue` is found. For a constant time approach use the ``init(values:selectedIndex:markLength:spacing:)``
    /// initializer.
    public init(
        values: Values,
        selectedValue: Values.Element,
        markLength: Double = StepCarouselDefaults.markLength,
        spacing: Double = .zero
    ) {
        precondition(!values.isEmpty, "values must contain at least one element")

        self.values = values
        self.markLength = markLength
        self.spacing = spacing

        if let selectedIndex = values.firstIndex(of: selectedValue) {
            self.selectedIndex = selectedIndex
            self.selectedValue = selectedValue
        } else {
            self.selectedIndex = values.startIndex
            self.selectedValue = values[values.startIndex]
        }

        self.scrollPosition = ScrollPosition()
    }


    /// Creates a position for a carousel control, selecting an initial index.
    ///
    /// - Parameters:
    ///   - values: The possible values the carousel can select, in the order these will be
    ///     displayed. This collection must contain at least one element.
    ///   - selectedIndex: Index of the initial value to be selected, when omitted, the first index
    ///     in `values` is used as the initial selection.
    ///   - markLength: The space available for each mark.
    ///   - spacing: Additional spacing between marks.
    ///
    /// - Note:
    /// The `values` collection **must** contain at least one value. An empty collection will
    /// trigger a precondition failure.
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


    /// The total length used by each mark.
    ///
    /// The length available for each mark is the mark length plus spacing.
    public var totalMarkLength: Double { markLength + spacing }


    /// Updates the carousel selection to the given value.
    ///
    /// By default, both ``selectedValue`` and ``selectedIndex`` are updated during the call to this
    /// function.
    ///
    /// If `value` cannot be found in `values`, the current selection remains unchanged.
    ///
    /// - Note:
    /// Using this function will search sequentially through `values` until a matching `value` is
    /// found. For a constant time approach use ``selectIndex(_:immediate:)``.
    ///
    /// ## Animation
    ///
    /// This function can be called within `withAnimation` for an animated selection. Use `immediate`
    /// to determine if ``selectedValue`` and ``selectedIndex`` should be updated during this call,
    /// or until the animation advances.
    ///
    /// When `immediate` is `false`, both `selectedValue` and `selectedIndex` are updated only as
    /// the internal scroll view animates to the new position. This is the recommended setting for
    /// animated updates.
    ///
    /// When `immediate` is `true`, both `selectedValue` and `selectedIndex` will be updated
    /// immediately once to the new values, and updated again as the animation advances. This
    /// initial update can create a brief flickering of the new selected state.
    ///
    /// - Parameters:
    ///   - value: The new value to select.
    ///   - immediate: When `true`, both `selectedValue` and `selectedIndex` are updated immediately
    ///     during this call; otherwise those properties update until the internal scroll
    ///     position updates, or as animation progresses. Defaults to `true`.
    public mutating func selectValue(_ value: Values.Element, immediate: Bool = true) {
        guard let index = values.firstIndex(of: value)
        else { return }

        if immediate {
            selectedValue = value
        }
        selectIndex(index, immediate: immediate)
    }


    /// Updates the carousel selection to the given index.
    ///
    /// By default this function only updates ``selectedIndex`` immediately. ``selectedValue`` is
    /// updated at a later time when the internal scroll view position updates, either through an
    /// immediate change or through animation.
    ///
    /// If `index` is not a valid index for `values`, the current selection remains unchanged.
    ///
    /// ## Animation
    ///
    /// This function can be called within `withAnimation` for an animated selection. Use `immediate`
    /// to determine if ``selectedIndex`` should be updated during this call, or until the animation
    /// advances.
    ///
    /// When `immediate` is `false`, `selectedIndex` is updated only as the internal scroll
    /// view animates to the new position. This is the recommended setting for animated updates.
    ///
    /// When `immediate` is `true`, `selectedIndex` is be updated immediately once to the new
    /// values, and updated again as the animation advances. This initial update can create a brief
    /// flickering of the new selected state.
    ///
    /// - Parameters:
    ///   - index: The index in ``values`` to select.
    ///   - immediate: When `true`, `selectedIndex` is updated immediately during this call;
    ///     otherwise the property updates until the internal scroll position updates, or as
    ///     animation progresses. Defaults to `true`.
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


extension StepCarouselPosition: Equatable where Values: Equatable {}
