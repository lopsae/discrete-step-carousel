//
//  DiscreteStepCarousel
//  Created by Maic Lopez Saenz.
//


import SwiftUI


extension LocalizedStringKey.StringInterpolation {

    mutating func appendInterpolation(shortFraction double: Double) {
        appendInterpolation(double, format: .shortFraction)
    }

}
