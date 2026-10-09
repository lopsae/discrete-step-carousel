//
//  DiscreteStepCarousel
//  Created by Maic Lopez Saenz.
//


public import SwiftUI


/// Default mark for a `StepCarousel`.
///
/// View used as the default mark and anchor in a ``StepCarousel`` when no custom views
/// are provided.
///
/// Expands to the available space and draws a vertical line in the middle of the view, styled with
/// the configured `ShapeStyle`.
public struct DefaultMark<Style: ShapeStyle>: View {

    // TODO: Move to StepCarouselDefaults.
    static var lineWidth: CGFloat { 2.5 }

    let style: Style

    /// Create a default mark with the given style.
    /// - Parameter style: The style to apply to the mark shape.
    public init(style: Style) {
        self.style = style
    }

    public var body: some View {
        let strokeStyle = StrokeStyle(lineWidth: Self.lineWidth, lineCap: .round)
        MarkShape(lineWidth: Self.lineWidth)
        .stroke(style, style: strokeStyle)
    }
}


// TODO: Could use AxialLine from PreviewUtilities instead.
nonisolated
struct MarkShape: Shape {

    let lineWidth: CGFloat

    func path(in rect: CGRect) -> Path {
        let center = rect.centerPoint
        var path = Path()
        path.move(to: [center.x, rect.minY + lineWidth/2])
        path.addLine(to: [center.x, rect.maxY - lineWidth/2])
        return path
    }
}


// MARK: - PreviewContent


@MainActor
private struct PreviewContent {

    static let layout: PreviewTrait<Preview.ViewTraits> = .iPhoneProSizeLayout

}


// MARK: - Previews


#Preview("Default", traits: .headerFooter, PreviewContent.layout) {
    Spacer()

    HStack(spacing: 40) {
        DefaultMark(style: .primary)
            .frame(squareOf: 44)
            .border(.red.tertiary, width: 2)
        DefaultMark(style: .secondary)
            .frame(squareOf: 44)
        DefaultMark(style: .primary)
            .frame(squareOf: 44)
            .scaleEffect(5)
            .debugOverlay(.hairline)
        DefaultMark(style: .red)
            .frame(squareOf: 44)
        DefaultMark(style: .orange)
            .frame(squareOf: 44)
    }

    Spacer()
}
