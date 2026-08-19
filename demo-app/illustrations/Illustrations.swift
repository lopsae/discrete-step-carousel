//
//  Illustrations
//  Created by Maic Lopez Saenz.
//


import DiscreteStepCarousel

import PreviewUtilities
import SwiftUI
import Testing


/// Documentation illustrations for `DiscreteStepCarousel`.
///
/// Each test produces an image saved to the package documentation catalog.
@MainActor struct Illustrations {

    let storage: IllustrationStorage

    init() throws {
        self.storage = try .init(
            filePath: #filePath,
            droppingComponents: 3, // filename, illustrations, demo-app.
            appendingComponents: ["sources", "documentation.docc", "resources"]
        ) {
            // onImageStored
            cgImage, filename in
            Attachment.record(cgImage, named: filename, as: .png)
        }
    }


    struct StepCarouselWithDefaultMark: View {
        @State var position = StepCarouselPosition(
            values: ["P", "Q", "R", "S", "T", "U", "V"],
            selectedValue: "S"
        )
        var body: some View {
            Text(position.selectedValue)
            StepCarousel(position: $position)
                .frame(height: StepCarouselDefaults.markHeight)
            Text(position.selectedIndex.description)
                .font(.caption)
        }
    }


    @Test func testIllustration() throws {
        try storage.renderAndStore("step-carousel", "with-default-mark", strategy: .windowHierarchy) {
            DocumentationIllustration(sizing: .regular) {
                StepCarouselWithDefaultMark()
            }
        }
    }

}
