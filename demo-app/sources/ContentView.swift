//
//  DiscreteStepCarouselDemo
//  Created by Maic Lopez Saenz.
//

import SwiftUI

import DiscreteStepCarousel
import PreviewUtilities


struct ContentView: View {


    var body: some View {
        List {
            Section("Carousel with Default Marks") {
                DefaultMarksExample()
                .listRowInsets(.horizontal, 0.0)
            }

            Section("Carousel with Styled Marks") {
                StyledMarksExample()
                .listRowInsets(.horizontal, 0.0)
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


#Preview {
    NavigationStack {
        ContentView()
            .navigationTitle("Preview")
    }
}
