//
//  DiscreteStepCarousel
//  Created by Maic Lopez Saenz.
//


public import SwiftUI


/// A control for selecting a value from a collection, with each value represented by a view in a
/// scrollable surface.
///
/// The carousel displays a scrollable sequence of views where each view represents a value in a
/// collection. The user can scroll through these views to select one value at a time, when the user
/// stops scrolling the scrollable surface snaps back to the currently selected view.
///
/// @Video(
///     source: "animated-demo.mov",
///     alt: "Demonstration video of a Step Carousel scrolling through different values.",
/// )
///
///
/// ### Carousel Position
///
/// ``StepCarouselPosition`` stores the state of the selected index, the collection of selectable
/// values, and the layout information for a step carousel. The view associated with each value, a
/// _mark_, can be provided to some of the `StepCarousel` initializers:
///
/// ```swift
/// @State var position: StepCarouselPosition = .init(
///     values: [Color.red, .orange, .yellow, .green, .teal, .blue, .indigo, .purple, .brown],
///     selectedIndex: 4, markLength: 40, spacing: 8
/// )
///
/// // ...
///
/// Text(position.selectedValue.description)
/// StepCarousel(position: $position) { index, value in
///     RoundedRectangle(cornerRadius: 8)
///     .fill(value.gradient)
/// }
/// .frame(height: 60)
/// ```
///
/// @Image(
///     source: step-carousel-with-colors,
///     alt: "Step Carousel control using colors as elements, with each mark displaying the selectable colors.”
/// )
///
///
/// The selected index or value can be read and set through the position instance with ``StepCarouselPosition/selectValue(_:immediate:)``
/// or ``StepCarouselPosition/selectIndex(_:immediate:)``. Calling this functions in an animation
/// block will animate the carousel to the selected position.
///
/// See ``StepCarouselPosition`` for more details.
///
///
/// ### Marks and Sizing
///
/// Each of the views that represent a carousel value is referred as a _mark_. A secondary _anchor_
/// view that is overlaid centered on the selected position can also be provided.
///
/// The carousel control will expand to occupy all available space. Use a `frame` or other layout
/// modifiers to constrain its size to the appropriate dimensions. The space available for each mark
/// is determined by the ``StepCarouselPosition/markLength`` property and the height of the carousel
/// control itself. The content for each mark is constrained and centered to its available space:
///
/// ```swift
/// @State var position: StepCarouselPosition = .init(
///     values: ["moon", "flame", "drop", "cloud", "ladybug", "leaf", "carrot"],
///     selectedValue: "cloud",
///     markLength: 44, // Determines the width of each mark.
///     spacing: 8
/// )
///
/// // ...
///
/// Text(position.selectedValue)
/// StepCarousel(position: $position) {
///     // Anchor Content
///     Image(systemName: "arrowtriangle.down.fill")
///     .foregroundStyle(.orange)
///     .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
/// } markContent: { index, value in
///     Image(systemName: value)
///     .font(.title)
///     .frame(maxWidth: .infinity, maxHeight: .infinity)
///     .background(.gray.tertiary, in: RoundedRectangle(cornerRadius: 4))
/// }
/// .frame(height: 44) // Determines the height of the step carousel control.
/// ```
///
/// @Image(
///     source: step-carousel-with-images,
///     alt: "Step Carousel control using image name strings as elements, with each mark displaying the corresponding image in a gray rounded rectangle background.”
/// )
///
///
/// Use the ``init(position:)`` or ``init(position:anchorStyle:markStyle:)`` initializers to use
/// ``DefaultMark`` as the marks and anchor. Using the default `markLength` and `spacing`, along
/// with ``StepCarouselDefaults/markHeight`` creates a carousel control with the default appearance:
///
/// ```swift
/// @State var position = StepCarouselPosition(
///     values: ["N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X"],
///     selectedValue: "S"
/// )
///
/// // ...
///
/// Text(position.selectedValue)
/// StepCarousel(position: $position)
///     .frame(height: StepCarouselDefaults.markHeight)
/// Text(position.selectedIndex.description)
///     .font(.caption)
/// ```
///
/// @Image(
///     source: step-carousel-with-default-mark,
///     alt: "Step Carousel control using the default marks, currently selecting the mark associated with S.”
/// )
///
///
/// ### Value identity
///
/// The collection of selectable values provided to the carousel are not required to contain unique
/// values since each mark is identified by its index, not the value itself. Internally the marks
/// are created using a `LazyHStack` to create the mark views only as needed.
@MainActor
public struct StepCarousel<Values, AnchorContent, MarkContent> : View
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


    /// Creates a carousel with custom marks and anchor.
    /// - Parameters:
    ///   - position: The binding to the position structure that contains the carousel state.
    ///   - anchorContent: The view overlaid over the selected position.
    ///   - markContent: The view builder that creates the mark for each selectable value.
    public init(
        position: Binding<StepCarouselPosition<Values>>,
        @ViewBuilder anchorContent: @escaping () -> AnchorContent,
        @ViewBuilder markContent: @escaping (Values.Index, Values.Element) -> MarkContent
    ) {
        self._position = position
        self.anchorContent = anchorContent
        self.markContent = markContent

        let positionValue = position.wrappedValue

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
            // FIXME: could this be done instead reading onScrollGeometry change?
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
                // FIXME: Revert to to using spacer views to center the selectable marks. Using
                // content margin affects how scrollTransition modifier works shortening the space
                // considered visible.
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


/// Container of defaults for `StepCarousel`
public enum StepCarouselDefaults {

    /// Default anchor style used along `DefaultMark`.
    public static let anchorStyle: HierarchicalShapeStyle = .secondary

    /// Default mark style used along `DefaultMark`.
    public static let markStyle: HierarchicalShapeStyle = .quaternary

    /// Recommended height for marks using `DefaultMark`.
    ///
    /// Carousel seen in standard library UI is measured to about 32 points.
    public static let markHeight: Double = 32


    /// Default mark length.
    ///
    /// Half the recommended length of tappable UI elements (`44`).
    public static let markLength: Double = 22

}


// MARK: - Convenience initializers


extension StepCarousel {

    /// Creates a carousel with custom marks and no anchor.
    /// - Parameters:
    ///   - position: The binding to the position structure that contains the carousel state.
    ///   - markContent: The view builder that creates the mark for each selectable value.
    public init(
        position: Binding<StepCarouselPosition<Values>>,
        @ViewBuilder markContent: @escaping (Values.Index, Values.Element) -> MarkContent
    )
    where
        AnchorContent == EmptyView
    {
        self.init(
            position: position,
            anchorContent: { EmptyView() },
            markContent: markContent
        )
    }


    /// Creates a carousel with the default marks and anchor.
    /// - Parameters:
    ///   - position: The binding to the position structure that contains the carousel state.
    public init(
        position: Binding<StepCarouselPosition<Values>>
    )
    where
        AnchorContent == DefaultMark<HierarchicalShapeStyle>,
        MarkContent == DefaultMark<HierarchicalShapeStyle>
    {
        self.init(
            position: position,
            anchorContent: { DefaultMark(style: StepCarouselDefaults.anchorStyle) },
            markContent: { _, _ in DefaultMark(style: StepCarouselDefaults.markStyle) }
        )
    }


    /// Creates a carousel with the default marks and anchor using the given shape styles.
    /// - Parameters:
    ///   - position: The binding to the position structure that contains the carousel state.
    ///   - anchorStyle: The style to apply to the default anchor.
    ///   - markStyle: The style to apply to the default marks.
    public init<AnchorStyle: ShapeStyle, MarkStyle: ShapeStyle>(
        position: Binding<StepCarouselPosition<Values>>,
        anchorStyle: AnchorStyle,
        markStyle: MarkStyle
    )
    where
        AnchorContent == DefaultMark<AnchorStyle>,
        MarkContent == DefaultMark<MarkStyle>
    {
        self.init(
            position: position,
            anchorContent: { DefaultMark(style: anchorStyle) },
            markContent: { _, _ in DefaultMark(style: markStyle) }
        )
    }

}
