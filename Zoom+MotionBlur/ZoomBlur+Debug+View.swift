import SwiftUI
import Wave

struct ZoomBlurDebugView: View {
    @State var isDragging: Bool = false
    @State var initialTouchLocation: CGPoint = .zero
    
    static let restingPosition = CGPoint(x: 0.0, y: 0.0)
    @State var position: CGPoint = restingPosition
    @State var blur: CGFloat = .zero
    
    @State var positionAnimator = SpringAnimator<CGPoint>(
        spring: .init(dampingRatio: 0.92, response: 0.2),
        value: restingPosition
    )
    
    let shaderFunction = ShaderFunction(library: .default, name: "zoom")
    var shader: Shader { Shader(function: shaderFunction, arguments: [
        .boundingRect,
        .float(blur), // Blur strength
    ])
    }
    
    @State private var abc: CGFloat = 0.0
    
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
            Image("maps")
                .resizable()
                .frame(width: 600, height: 600)
                .offset(x: position.x, y: position.y)
                .scaleEffect(0.5)
                .allowsHitTesting(false)
                .layerEffect(
                    shader,
                    maxSampleOffset: .zero)
            VStack {
                Spacer()
                HorizontalSlider(value: $blur, range: 0.0...1.0, steps: 0.01, label: "Zoom Blur")
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

#Preview {
    ZoomBlurDebugView()
}

