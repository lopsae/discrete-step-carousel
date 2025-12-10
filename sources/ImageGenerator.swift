//
//  DiscreteStepSlider
//  Created by Maic Lopez Saenz.
//


import CryptoKit
import SwiftUI


@MainActor @Observable
class ImageGeneratorStore {

    let generator: ImageGenerator

    private(set) var status: [String: GenerationStatus] = [:]
    private(set) var images: [String: Image] = [:]


    init(size: CGSize) {
        generator = .init(size: size)
    }


    @concurrent @discardableResult
    func generateImage(with text: String) async -> Image {
        if let image = await images[text] {
            return image
        }
        let requestThreadNumber = ThreadInfo.currentDisplayNumber()
        await markAsRequested(text: text, threadName: requestThreadNumber)

        let storageThreadNumber = ThreadInfo.currentDisplayNumber()
        let generateTuple = await generator.generateImage(with: text)
        await storeImage(
            generateTuple.image, text: text,
            threadName: storageThreadNumber,
            requestThreadName: requestThreadNumber,
            generationThreadName: generateTuple.threadNumber
        )

        return generateTuple.image
    }


    private func markAsRequested(text: String, threadName: String) {
        status[text] = .requested(threadName: threadName)
    }


    private func storeImage(
        _ image: Image,
        text: String,
        threadName: String,
        requestThreadName: String,
        generationThreadName: String
    ) {
        images[text] = image
        status[text] = .stored(
            threadName: threadName,
            requestThreadName: requestThreadName,
            generationThreadName: generationThreadName)
    }


    enum GenerationStatus {

        case requested(threadName: String)
        case stored(threadName: String, requestThreadName: String, generationThreadName: String)

        var statusColor: Color {
            switch self {
            case .requested: .orange
            case .stored:    .green
            }
        }

        var statusText: String {
            switch self {
            case let .requested(threadName):
                "Requested in \(threadName)"
            case let .stored(
                threadName,
                requestThreadName: requestThreadName,
                generationThreadName: generationThreadName
            ):
                "Stored in \(threadName) ← gen:\(generationThreadName) ← req:\(requestThreadName)"
            }
        }


        var compactStatusText: String {
            switch self {
            case let .requested(threadName):
                "req:\(threadName)"
            case let .stored(
                threadName,
                requestThreadName: requestThreadName,
                generationThreadName: generationThreadName
            ):
                "s:\(threadName) ← g:\(generationThreadName) ← r:\(requestThreadName)"
            }
        }

    }

}

// Package settings use the MainActor default isolation. `nonisolated` is necessary to allow
// functions in this class to run in the cooperative thread pool.
nonisolated final class ImageGenerator: Sendable {

    private struct Components: Sendable {
        let hue: CGFloat
        let saturation: CGFloat
        let brightness: CGFloat
    }


    let size: CGSize


    init(size: CGSize) {
        self.size = size
    }

    // TODO: add some tests for the following cases:
    // + nonisolated class with async function running in inherited main and background threads
    // + default isolated class with async function running in default main and concurrent threads, called from main and background threads

    // Package settings use the `NonisolatedNonsendingByDefault` upcoming feature, in which async
    // async functions by default will use the actor where it is called. Use `@concurrent` to use
    // the cooperative thread pool.
    @concurrent
    func generateImage(with text: String) async -> (image: Image, threadNumber: String) {
        // Simulate async work.
        let millis = (2000..<4000).randomElement()!
        // TODO: if canceled an additional status could be recorded
        try? await Task.sleep(for: .milliseconds(millis))

        let threadName = ThreadInfo.currentDisplayName()
        let threadNumber = ThreadInfo.currentDisplayNumber()
        let components = colorComponentsFromString(text)

        let image = buildImage(text: text, caption: threadName, components: components)
        return (image: image, threadNumber: threadNumber)
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


// MARK: - Previews


#Preview("Basic", traits: .fixedHeader) {
    @Previewable @State var images: [(text: String, image: Image?)] = [
        ("One",   nil),
        ("Two",   nil),
        ("Three", nil),
        ("Four",  nil),
        ("Five",  nil),
    ]

    let imageSide: CGFloat = 100
    let imageGenerator = ImageGenerator(size: .init(square: imageSide))

    VStack {
        ForEach(images.enumerated(), id: \.offset) { index, tuple in
            Group {
                if let image = tuple.image {
                    image.resizable()
                } else {
                    Rectangle().fill(.secondary)
                }
            }
            .frame(square: imageSide)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .task {
                let image = await imageGenerator.generateImage(with: tuple.text).image
                var mutableTuple = tuple
                mutableTuple.image = image
                images[index] = mutableTuple
            }
        }
    } // VStack
}


#Preview("LazyHStack", traits: .zeroSpacing, .fixedLayout(width: 400, height: 800)) {

    @Previewable @State var imageGenerator = ImageGeneratorStore(size: .init(square: 120))
    @Previewable @State var visibleScrollTargets: [String] = []
    @Previewable @State var scrollContentSize: CGFloat = 0.0

    let imageSide: Double = 120
    let items = String.natoPhoneticAlphabet

    ScrollView(.horizontal) {
        LazyHStack(spacing: 16) {
            ForEach(items, id: \.self) { item in
                VStack {
                    ZStack {
                        let maybeImage = imageGenerator.images[item]
                        Rectangle()
                            .fill(.secondary)
                            .overlay {
                                if maybeImage == nil {
                                    ProgressView()
                                        .transition(.blurReplace.animation(.linear(duration: 1.0)))
                                }
                            }

                        if let image = maybeImage {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .transition(.opacity.animation(.linear(duration: 1.0).delay(1.0)))
                        }
                    }
                    // Different frame options to see how ScrollView contentSize works with different sized items.
                    // .frame(square: imageSide)
                    // .frame(width: item.count.asDouble * 30, height: imageSide)
                    .frame(width: item == "Alfa" ? 500 : imageSide, height: imageSide)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                    Text(item)
                        .font(.caption)
                        .lineLimit(1)
                } // VStack
                .task {
                    guard imageGenerator.status[item] == nil else {
                        // Image already requested.
                        return
                    }

                    // TODO: experiment with a task group and cancelations
                    await imageGenerator.generateImage(with: item)
                }
            } // ForEach
        } // LazyHStack
        .scrollTargetLayout()
        .padding(.horizontal)
    } // ScrollView
    .debugOutline()
    .frame(height: 160)
    .safeAreaPadding(.horizontal, 40)
    // Note: `threshold` value of 0.0 will report as visible the same views that LazyHStack loads,
    // which is far more that the visible items.
    .onScrollTargetVisibilityChange(idType: String.self, threshold: 0.01) { identifiers in
        visibleScrollTargets = identifiers
    }
    .onScrollGeometryChange(of: \.contentSize.width, binding: $scrollContentSize)

    Divider()

    List {
        let columns: Int = 2
        LazyVGrid(
            columns: Array(
                repeating: .init(.flexible()),
                count: columns
            ),
            alignment: .leading
        ) {

            ForEach(items.columnMajorReordered(columns: columns), id: \.self) { item in
                let generationStatus = imageGenerator.status[item]
                let isVisible = visibleScrollTargets.contains(item)
                HStack(spacing: 4) {
                    Text(String(item.first!))
                        .frame(width: 20, alignment: .leading)
                    Circle()
                        .fill(isVisible ? .blue : .gray.opacity(0.5))
                        .frame(square: 15)
                    Circle()
                        .fill(generationStatus?.statusColor ?? .gray)
                        .frame(square: 15)

                    Text(generationStatus?.compactStatusText ?? "Idle")
                        .font(.caption)
                        .lineLimit(1)
                        .maxWidthFrame(alignment: .leading)
                }
            } // ForEach
        } // LazyVGrid

        Text("ContentSize: \(shortFraction: scrollContentSize)")
            .monospaced()
            .maxWidthFrame()
    } // ScrollView
}
