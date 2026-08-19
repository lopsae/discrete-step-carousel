//
//  DiscreteStepCarousel
//  Created by Maic Lopez Saenz.
//


@testable import DiscreteStepCarousel

import PreviewUtilities
import SwiftUI
import Testing


struct BaseIllustrations {

    let storage: IllustrationStorage

    init() throws {
        self.storage = try .init(
            filePath: #filePath,
            droppingComponents: 2, // filename, illustrations
            appendingComponents: ["sources", "documentation.docc", "resources"]
        ) {
            // onImageStored
            cgImage, filename in
            Attachment.record(cgImage, named: filename, as: .png)
        }
    }


    struct StepCarouselWithDefaultMark: View {
        @State var position = StepCarouselPosition(
            values: ["Q", "R", "S", "T", "U", "V"],
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
        try storage.renderAndStore("step-carousel", "with-default-mark") {
            DocumentationIllustration(sizing: .regular) {
//                StepCarouselWithDefaultMark()
                ScrollView(.horizontal) {
                    HStack {
                        Text("A")
                        Text("B")
                        Text("C")
                        Text("D")
                    }
                }
            }
        }
    }

}
