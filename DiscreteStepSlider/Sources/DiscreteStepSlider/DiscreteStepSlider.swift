//
//  DiscreteStepSlider
//  Created by Maic Lopez Saenz.
//



import SwiftUI


struct PrototypeSlider: View {

    var body: some View {
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
    }

}


#Preview {
    PrototypeSlider()
}
