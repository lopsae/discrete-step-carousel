//
//  DiscreteStepSlider
//  Created by Maic Lopez Saenz.
//


import SwiftUI


private struct ImageStatusGrid: View {
    let items: [String]
    let columns: Int
    let status: [String: ImageGeneratorStore.GenerationStatus]
    let visibleItems: [String]

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
    @Previewable @State var visibleScrollTargets: [String] = []
    @Previewable @State var scrollContentSize: CGFloat = 0.0

    let items = String.natoPhoneticAlphabet

    ScrollView(.horizontal) {
        LazyHStack(spacing: 16) {
            ForEach(items, id: \.self) { item in
                VStack {
                    ZStack {
                        let maybeImage = imageGenerator.images[item]
                        let isVisible = visibleScrollTargets.contains(item)

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
                    .frame(size: item == "Alfa" ? imageGenerator.size.set(width: 300) : imageGenerator.size)
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
        ImageStatusGrid(
            items: items, columns: columns,
            status: imageGenerator.status,
            visibleItems: visibleScrollTargets)

        Text("ContentSize: \(shortFraction: scrollContentSize)")
            .monospaced()
            .maxWidthFrame()
    } // List
}


private struct PlaceHolderView: View {
    let image: Image?
    let isVisible: Bool
    var body: some View {
        ZStack {
            Rectangle()
                .fill(.secondary)
            if image == nil {
                ProgressView()
                    .transition(.scale.animation(.linear(duration: 1.0)))
                // conditionalTransition does not seem to work consistently here
//                    .conditionalTransition(.scale.animation(.linear(duration: 1.0)), enabled: isVisible)
                    .id("placeholderProgressView")
            }
        }
    }
}


private struct ConditionalImageView: View {
    let image: Image?
    let isVisible: Bool
    var body: some View {
        if let image {
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .conditionalTransition(.scale.animation(.snappy(duration: 3.0).delay(1.5)), enabled: isVisible)
                .id("conditionalImage")
        }
    }
}


extension View {

    func conditionalTransition<T: Transition>(_ aTransition: T, enabled: Bool) -> some View {
        self.transition(
            enabled
            ? AnyTransition(aTransition)
            : .identity
        )
    }

}


#Preview("Animated", traits: .zeroSpacing, .fixedLayout(width: 400, height: 800)) {
    @Previewable @State var imageGenerator = ImageGeneratorStore(size: .init(square: 120))
    @Previewable @State var visibleScrollTargets: [String] = []

    let items = String.natoPhoneticAlphabet

    ScrollView(.horizontal) {
        LazyHStack(spacing: 16) {
            ForEach(items, id: \.self) { item in
                VStack {
                    ZStack {
                        let maybeImage = imageGenerator.images[item]
                        let isVisible = visibleScrollTargets.contains(item)

                        PlaceHolderView(image: maybeImage, isVisible: isVisible)
                        ConditionalImageView(image: maybeImage, isVisible: isVisible)
                    }
                    .frame(size: imageGenerator.size)
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
                    await imageGenerator.generateImage(with: item)
                }
            } // ForEach
        } // LazyHStack
        .scrollTargetLayout()
        .padding(.horizontal)
    } // ScrollView
    .debugOutline()
    .frame(height: 160)
    .safeAreaPadding(.horizontal, 120)
    // Note: `threshold` value of 0.0 will report as visible the same views that LazyHStack loads,
    // which is far more that the visible items.
    .onScrollTargetVisibilityChange(idType: String.self, threshold: 0.01) { identifiers in
        visibleScrollTargets = identifiers
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
