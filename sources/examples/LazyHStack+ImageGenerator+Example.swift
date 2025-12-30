//
//  DiscreteStepSlider
//  Created by Maic Lopez Saenz.
//


import PreviewUtilities
import SwiftUI


private struct ImageStatusGrid: View {
    let items: [String]
    let columns: Int
    let status: [String: ImageGeneratorStore.GenerationStatus]
    let visibleItems: Set<String>

    var body: some View {
        LazyVGrid(
            columns: Array(
                repeating: .init(.flexible()),
                count: columns
            ),
            alignment: .leading
        ) {

            ForEach(items.columnMajorReordered(columns: columns), id: \.self) { item in
                let itemStatus = status[item]
                let isVisible = visibleItems.contains(item)
                HStack(spacing: 4) {
                    Text(String(item.first!))
                        .frame(width: 20, alignment: .leading)
                    Circle()
                        .fill(isVisible ? .blue : .gray.opacity(0.5))
                        .frame(square: 15)
                    Circle()
                        .fill(itemStatus?.statusColor ?? .gray)
                        .frame(square: 15)

                    Text(itemStatus?.compactStatusText ?? "Idle")
                        .font(.caption)
                        .lineLimit(1)
                        .maxWidthFrame(alignment: .leading)
                }
            } // ForEach
        } // LazyVGrid
    }
}


#Preview("Default", traits: .zeroSpacing, .fixedLayout(width: 400, height: 800)) {
    @Previewable @State var imageGenerator = ImageGeneratorStore(size: .init(square: 120))
    @Previewable @State var visibleScrollTargets: Set<String> = []
    @Previewable @State var scrollContentSize: CGFloat = 0.0

    let items = String.natoPhoneticAlphabet.map(\.capitalized)

    ScrollView(.horizontal) {
        LazyHStack(spacing: 16) {
            ForEach(items, id: \.self) { item in
                VStack {
                    ZStack {
                        let maybeImage = imageGenerator.images[item]

                        // Placeholder
                        ZStack(alignment: .top) {
                            Rectangle()
                                .fill(.secondary)
                            if maybeImage == nil {
                                ProgressView().padding(.top)
                            } else {
                                Image(systemName: "checkmark.circle").padding(.top)
                            }
                        }

                        if let image = maybeImage {
                            image
                                .resizable()
                                .scaledToFill()
                                .opacity(0.8)
                        }
                    }
                    .frame(size: item == "Alfa" ? imageGenerator.size.setting(width: 300) : imageGenerator.size)
                    .roundedRectangleClip(cornerRadius: 8)

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
        visibleScrollTargets = Set(identifiers)
    }
    .onScrollGeometryChange(of: \.contentSize.width, binding: $scrollContentSize)

    Divider()

    List {
        let columns: Int = 2
        ImageStatusGrid(
            items: items, columns: columns,
            status: imageGenerator.status,
            visibleItems: visibleScrollTargets)

        Text("ContentSize: \(shortFraction: scrollContentSize)")
            .monospaced()
            .maxWidthFrame()
    } // List
}


func withAnimation(_ animation: Animation, condition: Bool, body: () -> Void) {
    if condition {
        withAnimation(animation, body)
    } else {
        body()
    }
}


#Preview("Animated", traits: .zeroSpacing, .fixedLayout(width: 400, height: 800)) {
    @Previewable @State var imageGenerator = ImageGeneratorStore(size: .init(square: 120))
    @Previewable @State var visibleScrollTargets: Set<String> = []
    // Separate states to handle specific animations
    @Previewable @State var isLoaded: Set<String> = []
    @Previewable @State var displayImage: [String: Image] = [:]

    let items = String.natoPhoneticAlphabet

    ScrollView(.horizontal) {
        LazyHStack(spacing: 16) {
            ForEach(items, id: \.self) { item in
                VStack {
                    ZStack {
                        // Placeholder
                        ZStack(alignment: .top) {
                            Rectangle()
                                .fill(.secondary)
                            if isLoaded.contains(item) {
                                Image(systemName: "checkmark.circle").padding(.top)
                            } else {
                                ProgressView().padding(.top)
                            }
                        }
                        .transition(.blurReplace)

                        // Image
                        if let image = displayImage[item] {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .opacity(0.8)
                                .transition(.scale)
                        }
                    }
                    .frame(size: imageGenerator.size)
                    .roundedRectangleClip(cornerRadius: 8)

                    Text(item)
                        .font(.caption)
                        .lineLimit(1)
                } // VStack
                .onChange(of: imageGenerator.images[item]) { _, newValue in
                    guard let image = newValue else { return }

                    withAnimation(.linear(duration: 1.0), condition: visibleScrollTargets.contains(item)) {
                        isLoaded.insert(item)
                    }

                    Task {
                        try? await Task.sleep(for: .seconds(2))
                        withAnimation(.snappy(duration: 3.0), condition: visibleScrollTargets.contains(item)) {
                            displayImage[item] = image
                        }
                    }
                }
                .task {
                    guard imageGenerator.status[item] == nil else {
                        // Image already requested.
                        return
                    }
                    await imageGenerator.generateImage(with: item)
                }
            } // ForEach
        } // LazyHStack
        .scrollTargetLayout()
        .padding(.horizontal)
    } // ScrollView
    .debugOutline()
    .frame(height: 160)
    .safeAreaPadding(.horizontal, 140)
    // Note: `threshold` value of 0.0 will report as visible the same views that LazyHStack loads,
    // which is far more that the visible items.
    .onScrollTargetVisibilityChange(idType: String.self, threshold: 0.01) { identifiers in
        visibleScrollTargets = Set(identifiers)
    }

    Divider()

    List {
        let columns: Int = 2
        ImageStatusGrid(
            items: items, columns: columns,
            status: imageGenerator.status,
            visibleItems: visibleScrollTargets)
    } // List
}
