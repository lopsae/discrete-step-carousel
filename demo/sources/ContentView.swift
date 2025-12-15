//
//  DiscreteStepSliderDemo
//  Created by Maic Lopez Saenz.
//

import SwiftUI

import DiscreteStepSlider

// TODO: PreviewUtilities should not be accesible unless imported directly.
//import PreviewUtilities


struct ContentView: View {
    @State var sliderPosition: DiscreteStepSliderPosition = .init(
        values: ["A", "B", "C", "D", "F", "G", "H", "J"],
        selectedValue: "D")

    var body: some View {
        Text(sliderPosition.selectedValue)
        Image(systemName: "arrowtriangle.down.fill")
            .font(.caption)

        DiscreteStepSlider(position: $sliderPosition)
        .frame(height: 44)

        Text(sliderPosition.selectedIndex.description)
            .font(.caption)

    }
}


#Preview {
    ContentView()
}
