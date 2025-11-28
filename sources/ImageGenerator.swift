//
//  DiscreteStepSlider
//  Created by Maic Lopez Saenz.
//


import CryptoKit
import RegexBuilder
import SwiftUI


class ImageGenerator {

    private struct Components {
        let hue: CGFloat
        let saturation: CGFloat
        let brightness: CGFloat
    }


    let size: CGSize


    init(size: CGSize) {
        self.size = size
    }


    @concurrent
    func generateImage(with text: String) async -> Image {
        // Simulate async work.
        let millis = (2000..<4000).randomElement()!
        try? await Task.sleep(for: .milliseconds(millis))

        let threadString = threadInfo()
        let components = colorComponentsFromString(text)

        return buildImage(text: text, caption: threadString, components: components)
    }


    func threadInfo() -> String {
        let name = Thread.isMainThread ? "Main" : "Background"
        let threadDescription = Thread.current.description
        let threadNumber = threadDescription.firstMatch {
            Regex {
                One("number = ")
                Capture {
                    OneOrMore(.digit)
                }
            }
        }?.1

        return "\(name)-\(threadNumber, default: "nil")"
    }


    #if canImport(AppKit)
    private func buildImage(text: String, caption: String, components: Components) -> Image {
        let nsImage = NSImage(size: size, flipped: true) { nsRect in
            // Background.
            let backgroundColor = NSColor(
                hue: components.hue,
                saturation: components.saturation,
                brightness: components.brightness,
                alpha: 1.0)
            backgroundColor.setFill()
            nsRect.fill()

            // Shadow.
            let shadow = NSShadow()
            shadow.shadowOffset = CGSize(width: 1, height: -3)
            shadow.shadowBlurRadius = 3
            shadow.shadowColor = NSColor.black.withAlphaComponent(0.5)
            shadow.set()

            self.drawStrings(text: text, caption: caption)
            return true
        }

        return Image(nsImage: nsImage)
    }
    #endif


    #if canImport(UIKit)
    private func buildImage(text: String, caption: String, components: Components) -> Image {
        let format = UIGraphicsImageRendererFormat()
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        let uiImage = renderer.image { context in
            // Background.
            let backgroundColor = UIColor(
                hue: components.hue,
                saturation: components.saturation,
                brightness: components.brightness,
                alpha: 1.0)
            backgroundColor.setFill()
            context.fill(size.rect())

            let cgContext = context.cgContext

            // Shadow.
            cgContext.setShadow(
                offset: CGSize(width: 1, height: 3),
                blur: 3,
                color: UIColor.black.withAlphaComponent(0.5).cgColor
            )

            drawStrings(text: text, caption: caption)
        }

        return Image(uiImage: uiImage)
    }
    #endif


    private func drawStrings(text: String, caption: String) {
        #if canImport(AppKit)
        typealias PlatformFont = NSFont
        typealias PlatformColor = NSColor
        #elseif canImport(UIKit)
        typealias PlatformFont = UIFont
        typealias PlatformColor = UIColor
        #endif

        let textAttrString = NSAttributedString(string: text, attributes: [
            .font: PlatformFont.preferredFont(forTextStyle: .headline),
            .foregroundColor: PlatformColor.white,
            .paragraphStyle: NSParagraphStyle.make {
                $0.alignment = .center
            }
        ])
        let textSize = textAttrString.size()
        let textRect = textSize.centered(in: size)

        let captionAttrString = NSAttributedString(string: caption, attributes: [
            .font:  PlatformFont.preferredFont(forTextStyle: .caption1),
            .foregroundColor: PlatformColor.white,
            .paragraphStyle: NSParagraphStyle.make {
                $0.alignment = .center
            }
        ])
        let captionSize = captionAttrString.size()
        var captionRect = captionSize.centered(in: size)
        captionRect.origin.y = textRect.maxY + 0

        textAttrString.draw(in: textRect)
        captionAttrString.draw(in: captionRect)
    }


    /// Generates deterministic color components for the given `string`.
    private func colorComponentsFromString(_ string: String) -> Components {
        let hash = persistentHash(for: string)

        let hue: Double = (hash % 360).asDouble / 360.0
        // In the range: 0.6 - 1.0.
        let saturation: Double = 0.6 + (hash % 40).asDouble / 100.0
        // In the range: 0.5 - 0.8.
        let brightness: Double = 0.5 + (hash % 30).asDouble / 100.0

        return .init(hue: hue, saturation: saturation, brightness: brightness)
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

    let imageSide: CGFloat = 100
    let imageGenerator = ImageGenerator(size: .init(square: imageSide))

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
        }.frame(square: imageSide)
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

#Preview("LazyHStack Example", traits: .fixedLayout(width: 400, height: 800)) {

    @Previewable @State var imageStatuses: [String: ImageStatus] =
        String.natoPhoneticAlphabet.dictionaryMap(value: .idle)

    @Previewable @State var loadedImages: [String: Image] = [:]

    let imageSide: Double = 120
    let imageGenerator = ImageGenerator(size: .init(square: imageSide))
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
                        .frame(square: imageSide)
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
