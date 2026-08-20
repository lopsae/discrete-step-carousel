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
            values: ["N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X"],
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


    @Test func withDefaultMark() throws {
        try storage.renderAndStore("step-carousel", "with-default-mark", strategy: .windowHierarchy) {
            DocumentationIllustration(sizing: .regular) {
                StepCarouselWithDefaultMark()
            }
        }
    }


    struct StepCarouselWithColors: View {
        @State var position: StepCarouselPosition = .init(
            values: [Color.red, .orange, .yellow, .green, .teal, .blue, .indigo, .purple, .brown],
            selectedIndex: 4, markLength: 40, spacing: 8
        )
        var body: some View {
            Text(position.selectedValue.description)
            StepCarousel(position: $position) { index, value in
                RoundedRectangle(cornerRadius: 8)
                .fill(value.gradient)
            }
            .frame(height: 60)
        }
    }


    @Test func withColors() throws {
        try storage.renderAndStore("step-carousel", "with-colors", strategy: .windowHierarchy) {
            DocumentationIllustration(sizing: .regular) {
                StepCarouselWithColors()
            }
        }
    }


    struct StepCarouselWithImages: View {
        @State var position: StepCarouselPosition = .init(
            values: ["moon", "flame", "drop", "cloud", "ladybug", "leaf", "carrot"],
            selectedValue: "cloud",
            markLength: 44, // Determines the width of each mark.
            spacing: 8
        )
        var body: some View {
            Text(position.selectedValue)
            StepCarousel(position: $position) {
                // Anchor Content
                Image(systemName: "arrowtriangle.down.fill")
                .foregroundStyle(.orange)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            } markContent: { index, value in
                Image(systemName: value)
                .font(.title)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.gray.tertiary, in: RoundedRectangle(cornerRadius: 4))
            }
            .frame(height: 44) // Determines the height of the step carousel control.
        }
    }


    @Test func withImages() throws {
        try storage.renderAndStore("step-carousel", "with-images", strategy: .windowHierarchy) {
            DocumentationIllustration(sizing: .regular) {
                StepCarouselWithImages()
            }
        }
    }


}
