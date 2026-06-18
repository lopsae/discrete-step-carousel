//
//  DiscreteStepCarousel
//  Created by Maic Lopez Saenz on 2026-05-29.
//


import SwiftUI


/// Default mark for a `StepCarousel`.
///
/// View used as the default mark and anchor in a ``StepCarousel`` when no custom views
/// are provided.
public struct DefaultMark<Style: ShapeStyle>: View {

    let style: Style

    public var body: some View {
        let lineWidth: CGFloat = 3
        let strokeStyle = StrokeStyle(lineWidth: lineWidth, lineCap: .round)
        MarkShape(lineWidth: lineWidth)
        .stroke(style, style: strokeStyle)
    }
}


struct MarkShape: Shape {

    let lineWidth: CGFloat

    func path(in rect: CGRect) -> Path {
        let center = rect.center
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
            .border(.red.tertiary, width: 3)
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
