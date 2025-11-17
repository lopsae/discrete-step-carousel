//
//  DiscreteStepSlider
//  Created by Maic Lopez Saenz.
//


import SwiftUI


struct PrototypeSlider: View {

    @Binding var selectedValue: Float

    // Possible values for `selectedValue`
    private(set) var values: [Float]
    // Spacing between the mark for each value.
    private(set) var spacing: CGFloat = 10


    init(_ values: [Float], selectedValue: Binding<Float>) {
        self.values = values
        self._selectedValue = selectedValue
    }

    var body: some View {
        // TODO: this is a mockup view of the intended ui.
        VStack {
            Text("1.5").monospacedDigit()
            Image(systemName: "arrowtriangle.down.fill")
            HStack {
                ForEach(0..<11) { index in
                    GeometryReader { geometry in
                        Path { path in
                            let halfWidth = geometry.frame(in: .local).width / 2
                            path.move(to: CGPoint(x: halfWidth, y: 0))
                            path.addLine(to: CGPoint(x: halfWidth, y: 40))
                        }
                        .stroke(.gray, lineWidth: 2)
                    }
                }
            }
        }
        .task {
            print(values)
        }
    }

}


#Preview {
    @Previewable @State var selectedValue: Float = 1.5
    let values: [Float] = Array(stride(from: 0.0, to: 3.0, by: 0.1))
    PrototypeSlider(values, selectedValue: $selectedValue)
}
