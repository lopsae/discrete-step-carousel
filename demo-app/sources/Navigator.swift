//
//  DiscreteStepCarouselDemo
//  Created by Maic Lopez Saenz.
//


import SwiftUI


struct Navigator: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Base Examples") {
                    BaseExamples()
                }

                NavigationLink("Advanced Examples") {
                    AdvancedExamples()
                }
            }
            .navigationTitle("DiscreteStepCarousel")
            .navigationSubtitle("DemoApp")
        }
    }
}


#Preview {
    Navigator()
}
