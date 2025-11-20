//
//  DiscreteStepSlider
//  Created by Maic Lopez Saenz.
//


import SwiftUI


class ImageGenerator {

    func generateImage(with text: String) async -> Image {
        // Simulate async work
        let millis = (500..<2000).randomElement()!
        try? await Task.sleep(for: .milliseconds(millis))

        // Generate a consistent color from the text
        let (hue, saturation, brightness) = colorComponentsFromString(text)
        
        // Create the image using Core Graphics (off main thread)
        let size = CGSize(width: 200, height: 200)
        let scale: CGFloat = 2.0
        
        #if canImport(UIKit)
        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        let uiImage = renderer.image { context in
            // Fill background with color
            let backgroundColor = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
            context.cgContext.setFillColor(backgroundColor.cgColor)
            context.cgContext.fill(CGRect(origin: .zero, size: size))
            
            // Draw text
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 40),
                .foregroundColor: UIColor.white,
                .paragraphStyle: {
                    let style = NSMutableParagraphStyle()
                    style.alignment = .center
                    return style
                }()
            ]
            
            let attributedString = NSAttributedString(string: text, attributes: attributes)
            let textSize = attributedString.size()
            let textRect = CGRect(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            
            // Draw shadow
            context.cgContext.setShadow(
                offset: CGSize(width: 0, height: 1),
                blur: 2,
                color: UIColor.black.withAlphaComponent(0.3).cgColor
            )
            
            attributedString.draw(in: textRect)
        }
        
        return Image(uiImage: uiImage)
        
        #elseif canImport(AppKit)
        let image = NSImage(size: size)
        image.lockFocus()
        
        // Fill background with color
        let backgroundColor = NSColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
        backgroundColor.setFill()
        NSRect(origin: .zero, size: size).fill()
        
        // Draw text
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.boldSystemFont(ofSize: 40),
            .foregroundColor: NSColor.white,
            .paragraphStyle: {
                let style = NSMutableParagraphStyle()
                style.alignment = .center
                return style
            }()
        ]
        
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        let textSize = attributedString.size()
        let textRect = CGRect(
            x: (size.width - textSize.width) / 2,
            y: (size.height - textSize.height) / 2,
            width: textSize.width,
            height: textSize.height
        )
        
        // Draw with shadow
        let shadow = NSShadow()
        shadow.shadowOffset = CGSize(width: 0, height: -1)
        shadow.shadowBlurRadius = 2
        shadow.shadowColor = NSColor.black.withAlphaComponent(0.3)
        shadow.set()
        
        attributedString.draw(in: textRect)
        
        image.unlockFocus()
        
        return Image(nsImage: image)
        
        #else
        // Fallback: return a system image
        return Image(systemName: "photo")
        #endif
    }
    
    /// Generate deterministic color components from a string
    private func colorComponentsFromString(_ string: String) -> (hue: CGFloat, saturation: CGFloat, brightness: CGFloat) {
        // Use the string's hash to generate consistent values
        var hash = string.hashValue
        
        // Ensure positive value
        if hash < 0 {
            hash = -hash
        }
        
        // Generate hue, saturation, and brightness values
        let hue = CGFloat(hash % 360) / 360.0
        let saturation = 0.6 + CGFloat((hash / 360) % 40) / 100.0  // 0.6 - 1.0
        let brightness = 0.5 + CGFloat((hash / 14400) % 30) / 100.0  // 0.5 - 0.8
        
        return (hue, saturation, brightness)
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
