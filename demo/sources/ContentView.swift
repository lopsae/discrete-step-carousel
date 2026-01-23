//
//  DiscreteStepCarouselDemo
//  Created by Maic Lopez Saenz.
//

import SwiftUI

import DiscreteStepCarousel
import PreviewUtilities


struct ContentView: View {
    @State var carouselPosition: DiscreteStepCarouselPosition = .init(
        values: Strings.alphabet.map(\.localizedUppercase),
        selectedValue: "D")

    var body: some View {
        List {
            VStack(spacing: 0) {
                Text(carouselPosition.selectedValue)
                Image(systemName: "arrowtriangle.down.fill")
                    .font(.caption)

                DiscreteStepCarousel(position: $carouselPosition)
                .frame(height: 44)

                Text(carouselPosition.selectedIndex.description)
                    .font(.caption)
            }
            .listRowInsets(.horizontal, 0.0)
        }
    }
}


#Preview {
    NavigationStack {
        ContentView()
            .navigationTitle("Preview")
    }
}
