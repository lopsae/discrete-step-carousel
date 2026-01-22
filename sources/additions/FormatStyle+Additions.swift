//
//  DiscreteStepCarousel
//  Created by Maic Lopez Saenz.
//


import Foundation


extension FormatStyle where Self == FloatingPointFormatStyle<Double> {

    /// Convenience format for displaying doubles with a short fraction component.
    static var shortFraction: FloatingPointFormatStyle<Double> {
        .fractionLength(2)
    }

}
