//
//  DiscreteStepCarouselDemo
//  Created by Maic Lopez Saenz.
//

import SwiftUI

import DiscreteStepCarousel
import PreviewUtilities


// TODO: rename sliderPosition
struct ContentView: View {
    @State var sliderPosition: DiscreteStepCarouselPosition = .init(
        values: Strings.alphabet.map(\.localizedUppercase),
        selectedValue: "D")

    var body: some View {
        List {
            VStack(spacing: 0) {
                Text(sliderPosition.selectedValue)
                Image(systemName: "arrowtriangle.down.fill")
                    .font(.caption)

                DiscreteStepCarousel(position: $sliderPosition)
                .frame(height: 44)

                Text(sliderPosition.selectedIndex.description)
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
