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


    @Test func testIllustration() throws {
        try storage.renderAndStore("step-carousel", "test") {
            DocumentationIllustration(sizing: .regular) {
                Text("Test Illustration")
            }
        }
    }

}
