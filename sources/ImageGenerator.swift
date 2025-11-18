//
//  DiscreteStepSlider
//  Created by Maic Lopez Saenz.
//


import SwiftUI


class ImageGenerator {

    @MainActor
    func generateImage(with text: String) async -> Image {
        // Simulate async work
        let millis = (500..<2000).randomElement()!
        try? await Task.sleep(for: .milliseconds(millis))

        // Generate a consistent color from the text
        let color = colorFromString(text)
        
        // Create the image
        let size = CGSize(width: 200, height: 200)
        let renderer = ImageRenderer(content:
            ZStack {
                Rectangle()
                    .fill(color)
                
                Text(text)
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
            }
            .frame(width: size.width, height: size.height)
        )
        
        renderer.scale = 2.0 // For better quality
        
        #if canImport(UIKit)
        if let uiImage = renderer.uiImage {
            return Image(uiImage: uiImage)
        }
        #elseif canImport(AppKit)
        if let nsImage = renderer.nsImage {
            return Image(nsImage: nsImage)
        }
        #endif
        
        // Fallback: return a system image
        return Image(systemName: "photo")
    }
    
    /// Generate a deterministic color from a string
    private func colorFromString(_ string: String) -> Color {
        // Use the string's hash to generate consistent values
        var hash = string.hashValue
        
        // Ensure positive value
        if hash < 0 {
            hash = -hash
        }
        
        // Generate hue, saturation, and brightness values
        let hue = Double(hash % 360) / 360.0
        let saturation = 0.6 + Double((hash / 360) % 40) / 100.0  // 0.6 - 1.0
        let brightness = 0.5 + Double((hash / 14400) % 30) / 100.0  // 0.5 - 0.8
        
        return Color(hue: hue, saturation: saturation, brightness: brightness)
    }

}


#Preview {
    @Previewable @State var imageOne: Image?
    @Previewable @State var imageTwo: Image?
    @Previewable @State var imageThree: Image?
    let imageGenerator = ImageGenerator()

    VStack {
        Group {
            if let imageOne {
                imageOne.resizable()
            } else {
                Rectangle().fill(.secondary)
            }
        }.frame(width: 100, height: 100)

        Group {
            if let imageTwo {
                imageTwo.resizable()
            } else {
                Rectangle().fill(.secondary)
            }
        }.frame(width: 100, height: 100)

        Group {
            if let imageThree {
                imageThree.resizable()
            } else {
                Rectangle().fill(.secondary)
            }
        }.frame(width: 100, height: 100)
    }
    .task {
        imageOne = await imageGenerator.generateImage(with: "1")
    }
    .task {
        imageTwo = await imageGenerator.generateImage(with: "2")
    }
    .task {
        imageThree = await imageGenerator.generateImage(with: "3")
    }

}
