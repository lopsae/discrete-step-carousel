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
                    .navigationTitle("Base Examples")
                }

                NavigationLink("Advanced Examples") {
                    AdvancedExamples()
                    .navigationTitle("Advanced Examples")
                }

                NavigationLink("Documentation Examples") {
                    DocumentationExamples()
                    .navigationTitle("StepCarousel")
                    .navigationBarTitleDisplayMode(.inline)
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
