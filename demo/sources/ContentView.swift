//
//  DiscreteStepSliderDemo
//  Created by Maic Lopez Saenz.
//

import SwiftUI

import DiscreteStepSlider
import PreviewUtilities


struct ContentView: View {
    @State var sliderPosition: DiscreteStepSliderPosition = .init(
        values: String.alphabet.map(\.localizedUppercase),
        selectedValue: "D")

    var body: some View {
        List {
            VStack(spacing: 0) {
                Text(sliderPosition.selectedValue)
                Image(systemName: "arrowtriangle.down.fill")
                    .font(.caption)

                DiscreteStepSlider(position: $sliderPosition)
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
