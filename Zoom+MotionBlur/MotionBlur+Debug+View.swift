import SwiftUI
import Wave

#Preview {
    MotionBlurDebugView()
}

struct MotionBlurDebugView: View {
    @State var isDragging: Bool = false
    @State var initialTouchLocation: CGPoint = .zero
    
    static let restingPosition = CGPoint(x: 0.0, y: 0.0)
    @State var position = restingPosition
    @State var blur: CGFloat = 0.0
    @State var angle: CGFloat = 0.0
    
    @State var positionAnimator = SpringAnimator<CGPoint>(
        spring: .init(dampingRatio: 0.92, response: 0.2),
        value: restingPosition
    )
    // ┌────────┐
    // │ Shader │
    // └────────┘
    let shaderFunction = ShaderFunction(library: .default, name: "motion")
    var shader: Shader { Shader(function: shaderFunction, arguments: [
        .boundingRect,
        .float(blur), // Blur strength
        .float(angle) // Blur angle (radians)
    ])
    }
    
    var body: some View {
        ZStack {
            Color(.black)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged{ value in
                            if initialTouchLocation == .zero {
                                initialTouchLocation = position
                                isDragging = true
                            }
                            
                            let newPosition = CGPoint(
                                x: initialTouchLocation.x + value.translation.width,
                                y: initialTouchLocation.y + value.translation.height
                            )
                            
                            // Position
                            positionAnimator.spring = .init(dampingRatio: 0.92, response: 0.2)
                            positionAnimator.target = newPosition
                            positionAnimator.start()
                        }
                        .onEnded { value in
                            // Position
                            positionAnimator.spring = .init(dampingRatio: 0.72, response: 0.7)
                            positionAnimator.target = Self.restingPosition
                            positionAnimator.start()
                            
                            initialTouchLocation = .zero
                            isDragging = false
                        }
                )
            Image("drag")
                .resizable()
                .frame(width: 600, height: 600)
                .offset(x: position.x, y: position.y)
                .allowsHitTesting(false)
                .layerEffect(
                    shader,
                    maxSampleOffset: .zero)
            VStack {
                Spacer()
                HStack {
                    
                    HorizontalSlider( value: $blur, range: 0.00...0.1, steps: 0.001, label: "Motion Blur")
                    RadialSlider(angle: $angle)
                }
            }
            .padding(.horizontal, 128.0)
            .padding(.vertical, 24.0)
        }
        .onAppear {
            positionAnimator.valueChanged = { value in
                position = value
            }
        }
        .ignoresSafeArea()
        .statusBar(hidden: true)
    }
}
