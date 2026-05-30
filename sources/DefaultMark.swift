//
//  DiscreteStepCarousel
//  Created by Maic Lopez Saenz on 2026-05-29.
//


import SwiftUI


/// Default mark for a `DiscreteStepCarousel`.
///
/// View used as the default mark and anchor in a ``DiscreteStepCarousel`` when no custom views
/// are provided.
public struct DefaultMark<Style: ShapeStyle>: View {

    let fill: Style

    public var body: some View {
        Capsule()
            .fill(fill)
            .frame(width: 3)
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
        DefaultMark(fill: .primary)
            .frame(height: 44)
        DefaultMark(fill: .secondary)
            .frame(height: 44)
        DefaultMark(fill: .red)
            .frame(height: 44)
        DefaultMark(fill: .orange)
            .frame(height: 44)
    }

    Spacer()
}
