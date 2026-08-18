//
//  DiscreteStepCarouselDemo
//  Created by Maic Lopez Saenz.
//

import SwiftUI

import DiscreteStepCarousel
import PreviewUtilities


struct AdvancedExamples: View {

    var body: some View {
        List {
            Section("Marks Animated by Selection") {
                SelectionAnimationExample()
                .listRowInsets(.horizontal, .zero)
            }

        }
    }

}


struct SelectionAnimationExample: View {

    @State var carouselPosition: StepCarouselPosition<[String]>

    init(initialSelection: String? = nil) {
        let values = Strings.alphabet.map(\.localizedUppercase)
        let selectedValue = initialSelection ?? values.first!
        carouselPosition = .init(
            values: Strings.alphabet.map(\.localizedUppercase),
            selectedValue: selectedValue
        )
    }

    var body: some View {
        VStack(spacing: 2) {
            Text(carouselPosition.selectedValue)

            StepCarousel(position: $carouselPosition) { index, element in
                let isSelected = carouselPosition.selectedIndex == index
                let height: CGFloat = isSelected
                    ? StepCarouselDefaults.markHeight
                    : StepCarouselDefaults.markHeight / 2
                let style: HierarchicalShapeStyle = isSelected
                    ? .primary
                    : .tertiary
                DefaultMark(style: style)
                .frame(height: height)
                .animation(isSelected ? nil : .smooth, value: height)
                .frame(height: StepCarouselDefaults.markHeight, alignment: .bottom)
            }
            .frame(height: StepCarouselDefaults.markHeight)

            Text(carouselPosition.selectedIndex.description)
            .font(.caption)
        }
    }
}





#Preview {
    NavigationStack {
        AdvancedExamples()
        .navigationTitle("Preview")
    }
}
