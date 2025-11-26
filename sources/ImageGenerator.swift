//
//  DiscreteStepSlider
//  Created by Maic Lopez Saenz.
//


import SwiftUI
import CryptoKit


class ImageGenerator {

    // TODO: double check the implications of nonisolated
    nonisolated func generateImage(with text: String) async -> Image {
        // Simulate async work
        let millis = (2000..<4000).randomElement()!
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
    
    /// Generates deterministic color components for the given `string`.
    private func colorComponentsFromString(_ string: String) -> (hue: Double, saturation: Double, brightness: Double) {
        let hash = persistentHash(for: string)

        let hue: Double = (hash % 360).asDouble / 360.0
        // In the range: 0.6 - 1.0.
        let saturation: Double = 0.6 + (hash % 40).asDouble / 100.0
        // In the range: 0.5 - 0.8.
        let brightness: Double = 0.5 + (hash % 30).asDouble / 100.0

        return (hue, saturation, brightness)
    }


    private func persistentHash(for input: String) -> Int {
        guard let inputData = input.data(using: .utf8)
        else { return 0 }

        let hashed: SHA256Digest = SHA256.hash(data: inputData)
        let intValue: Int = hashed.reduce(0) { partialResult, int8 in
            partialResult + Int(int8)
        }

        return intValue
    }

}


#Preview("Simple Example") {
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
        imageOne = await imageGenerator.generateImage(with: "One")
    }
    .task {
        imageTwo = await imageGenerator.generateImage(with: "Two")
    }
    .task {
        imageThree = await imageGenerator.generateImage(with: "Three")
    }

    Spacer()

}


enum ImageStatus: String {
    case idle
    case loading
    case ready

    var statusColor: Color {
        switch self {
        case .idle:    .gray
        case .loading: .orange
        case .ready:   .green
        }
    }

    var statusText: String {
        switch self {
        case .idle:    "Idle"
        case .loading: "Loading"
        case .ready:   "Ready"
        }
    }

}

// TODO: enum for visibility needs to be a separate one

#Preview("LazyHStack Example") {

    @Previewable @State var imageStatuses: [String: ImageStatus] = {
        // TODO: convenience fuction to map to dictionary
        Dictionary(uniqueKeysWithValues: String.natoPhoneticAlphabet.map { ($0, .idle )})
    }()

    @Previewable @State var loadedImages: [String: Image] = [:]

    let imageGenerator = ImageGenerator()
    let items = String.natoPhoneticAlphabet

    VStack(spacing: 20) {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 16) {
                ForEach(items, id: \.self) { item in
                    VStack {
                        Group {
                            if let image = loadedImages[item] {
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            } else {
                                Rectangle()
                                    .fill(.secondary)
                                    .overlay {
                                        ProgressView()
                                    }
                            }
                        }
                        .frame(width: 120, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        
                        Text(item)
                            .font(.caption)
                            .lineLimit(1)
                    }
                    .onAppear {
                        guard loadedImages[item] == nil else {
                            // TODO: Mark as visible?
                            return
                        }

                        imageStatuses[item] = .loading
                        // TODO: experiment with a task group and cancelations
                        Task {
                            let image = await imageGenerator.generateImage(with: item)
                            loadedImages[item] = image
                            imageStatuses[item] = .ready
                        }
                    }
                    // TODO: try to track visibility using ScrollTarget identifiers
                }
            }
            .padding(.horizontal)
        }
        .frame(height: 160)
        
        Divider()
        
        // Grid showing status
        ScrollView {
            Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 8) {
                // Header
                GridRow {
                    Text("Item")
                        .font(.headline)
                        .gridColumnAlignment(.leading)
                    
                    Text("Status")
                        .font(.headline)
                        .gridColumnAlignment(.center)
                }
                
                Divider()
                    .gridCellUnsizedAxes(.horizontal)
                
                // Status rows
                ForEach(items, id: \.self) { item in
                    if let status = imageStatuses[item] {
                        GridRow {
                            Text(item)
                                .font(.body)
                            
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(status.statusColor)
                                    .frame(width: 12, height: 12)
                                
                                Text(status.statusText)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }
}
