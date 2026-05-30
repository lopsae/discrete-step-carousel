//
//  DiscreteStepCarousel
//  Created by Maic Lopez Saenz on 2026-05-29.
//


import SwiftUI


public struct DefaultMark<Style: ShapeStyle>: View {

    let fill: Style

    public var body: some View {
        Rectangle()
            .fill(fill)
            .frame(width: 2)
    }
}
