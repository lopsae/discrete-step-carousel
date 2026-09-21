//
//  DiscreteStepCarouselDemo
//  Created by Maic Lopez Saenz.
//

import SwiftUI

import DiscreteStepCarousel
import PreviewUtilities


struct DocumentationExamples: View {

    var body: some View {
        List {
            Section {
                SelectionAnimationExample(initialSelection: "S")
                .listRowInsets(.horizontal, .zero)
            }

        }
    }

}


#Preview {
    NavigationStack {
        AdvancedExamples()
        .navigationTitle("Preview")
    }
}
