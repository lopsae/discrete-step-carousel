//
//  DiscreteStepCarouselDemo
//  Created by Maic Lopez Saenz.
//

import SwiftUI

import DiscreteStepCarousel
import PreviewUtilities


struct BaseExamples: View {

    var body: some View {
        List {
            Section("Carousel with Default Marks") {
                DefaultMarksExample()
                .listRowInsets(.horizontal, .zero)
            }

            Section("Carousel with Styled Marks") {
                StyledMarksExample()
                .listRowInsets(.horizontal, .zero)
            }

            Section("Carousel with `Image` Marks") {
                ImageMarksExample()
                .listRowInsets(.horizontal, .zero)
            }

        }
    }

}


struct DefaultMarksExample: View {

    @State var  carouselPosition: StepCarouselPosition = .init(
        values: Strings.alphabet.map(\.localizedUppercase)
    )

    var body: some View {
        VStack(spacing: 2) {
            Text(carouselPosition.selectedValue)

            StepCarousel(position: $carouselPosition)
                .frame(height: StepCarouselDefaults.markHeight)

            Text(carouselPosition.selectedIndex.description)
                .font(.caption)
        }
    }
}


struct StyledMarksExample: View {

    @State var  carouselPosition: StepCarouselPosition = .init(
        values: Strings.alphabet.map(\.localizedUppercase),
        selectedValue: "Z"
    )

    var body: some View {
        VStack(spacing: 2) {
            Text(carouselPosition.selectedValue)

            StepCarousel(
                position: $carouselPosition,
                anchorStyle: .red.secondary,
                markStyle: .orange.tertiary
            )
            .frame(height: StepCarouselDefaults.markHeight)

            Text(carouselPosition.selectedIndex.description)
                .font(.caption)
        }
    }
}


struct ImageMarksExample: View {

    @State var  carouselPosition: StepCarouselPosition = .init(
        values: [
            "moon", "flame", "bolt", "drop", "cloud",
            "lizard", "ladybug", "leaf", "carrot"],
        markLength: 44
    )

    var body: some View {
        VStack(spacing: 2) {
            Text(carouselPosition.selectedValue)

            StepCarousel(position: $carouselPosition) { index, element in
                Image(systemName: element)
                .font(.title)
                .onTapGesture {
                    withAnimation {
                        carouselPosition.selectIndex(index, immediate: false)
                    }
                }
            }
            .frame(height: 44)

            Text(carouselPosition.selectedIndex.description)
                .font(.caption)
        }
    }
}


#Preview {
    NavigationStack {
        BaseExamples()
            .navigationTitle("Preview")
    }
}
