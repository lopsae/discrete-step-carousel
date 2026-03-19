//
//  DiscreteStepCarousel
//  Created by Maic Lopez Saenz.
//


import SwiftUI
import PreviewUtilities


/// Defines a scroll behaviour where the horizontal target x position always snaps to the closest
/// multiple of the step value.
struct DiscreteStepScrollTargetBehavior: ScrollTargetBehavior {
    let step: Double

    func updateTarget(_ target: inout ScrollTarget, context: TargetContext) {
        let targetX = target.rect.origin.x
        target.rect.origin.x = (targetX / step).rounded(.toNearestOrEven) * step
    }
}


// MARK: - PreviewContent


@MainActor
private struct PreviewContent {

    static let layout: PreviewTrait<Preview.ViewTraits> = .iPhoneProSizeLayout

}


// MARK: - Previews.


#Preview("Default", traits: .fixedHeader, PreviewContent.layout) {
    let step: Double = 100

    PreviewCaption("""
        By default items will align to the leading edge. Last item might not display fully.
        """).padding(.bottom)

    Image(systemName: "arrowtriangle.down.fill")
        .foregroundStyle(.secondary)
        .maxWidthFrame(alignment: .leading)

    GeometryReader { geometry in
        ScrollView(.horizontal) {
            HStack(spacing: 0) {
                ForEach(0..<7) { index in
                    CaptionRectangle("Item \(index)", color: .orange)
                    .frame(width: step)
                }
            }
        } // ScrollView
        .scrollTargetBehavior(
            DiscreteStepScrollTargetBehavior(step: step)
        )
    } // GeometryReader
    .frame(height: 100)
}


#Preview("Centering", traits: .paddingSpacing, .fixedHeader, PreviewContent.layout) {
    let step: Double = 50

    PreviewCaption("""
        Spacers can be used to visually center the items.
        """)

    GeometryReader { geometry in
        ScrollView(.horizontal) {
            HStack(spacing: 0) {
                // Leading spacer to center first item.
                CaptionRectangle("Spacer", color: .teal)
                .frame(width: (geometry.size.width - step) / 2.0)

                ForEach(0..<6) { index in
                    CaptionRectangle("Item \(index)", color: .orange)
                    .frame(width: step)
                }

                // Trailing spacer to center last item.
                CaptionRectangle("Spacer", color: .teal)
                .frame(width: (geometry.size.width - step) / 2.0)
            }
        } // ScrollView
        .scrollTargetBehavior(
            DiscreteStepScrollTargetBehavior(step: step)
        )

    } // GeometryReader
    .frame(height: 100)
    .stackAbove {
        Image(systemName: "arrowtriangle.down.fill")
            .foregroundStyle(.secondary)
    }

    DashedDivider()

    PreviewCaption("""
        Content margins can be used to visually center the items too.
        """)

    GeometryReader { geometry in
        ScrollView(.horizontal) {
            HStack(spacing: 0) {
                ForEach(0..<6) { index in
                    CaptionRectangle("Item \(index)", color: .orange)
                    .frame(width: step)
                }
            }
        } // ScrollView
        .contentMargins(
            .horizontal((geometry.size.width - step) / 2.0),
            for: .scrollContent)
        .scrollTargetBehavior(
            DiscreteStepScrollTargetBehavior(step: step)
        )

    } // GeometryReader
    .frame(height: 100)
    .stackAbove {
        Image(systemName: "arrowtriangle.down.fill")
            .foregroundStyle(.secondary)
    }
}


// TODO: experimental modifiers, consider moving to PreviewUtilities.


/// Experimental modifier, consider moving to PreviewUtilities if useful.
/// Wraps the preview content in a `VStack` with spacing equal to the default padding.
struct PaddingSpacingPreviewModifier: PreviewModifier {

    func body(content: Content, context _: ()) -> some View {
        VStack(spacing: Defaults.padding) {
            content
        }
    }

}


extension PreviewTrait where T == Preview.ViewTraits {

    fileprivate static var paddingSpacing: PreviewTrait {
        .modifier(PaddingSpacingPreviewModifier())
    }

}


struct StackAbove<AboveContent: View>: ViewModifier {
    let spacing: CGFloat?
    let aboveContent: () -> AboveContent
//    init(spacing: Double) {
//        self.spacing = spacing
//    }
    func body(content: Content) -> some View {
        VStack(spacing: spacing) {
            aboveContent()
            content
        }
    }
}


extension View {

    func stackAbove<Content: View>(
        spacing: CGFloat? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        let stackModifier = StackAbove(spacing: spacing, aboveContent: content)
        return modifier(stackModifier)
    }

}
