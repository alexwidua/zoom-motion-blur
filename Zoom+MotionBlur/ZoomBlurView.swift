import SwiftUI
import Wave

#Preview {
    ZoomBlurView()
}

struct ZoomBlurView: View {
    // ┌───────┐
    // │ State │
    // └───────┘
    @State var enabled: Bool = true
    @State var isDragging: Bool = false
    @State var initialTouchLocation: CGPoint = .zero
    
    static let restingPosition = CGPoint(x: 0.0, y: 0.0)
    static let restingScale = CGPoint(x: 0.5, y: 0.5)
    static let restingBlur = CGFloat(0.0)
    
    @State var position: CGPoint = restingPosition
    @State var scale: CGPoint = restingScale
    @State var blur: CGFloat = restingBlur
    
    // ┌──────┐
    // │ Wave │
    // └──────┘
    @State var positionAnimator = SpringAnimator<CGPoint>(
        spring: .init(dampingRatio: 0.92, response: 0.2),
        value: restingPosition
    )
    @State var scaleAnimator = SpringAnimator<CGPoint>(
        spring: .init(dampingRatio: 0.92, response: 0.2),
        value:  restingScale
    )
    @State var blurAnimator = SpringAnimator<CGFloat>(
        spring: .init(dampingRatio: 0.92, response: 0.2),
        value:  restingBlur
    )
    
    // ┌────────┐
    // │ Shader │
    // └────────┘
    let shaderFunction = ShaderFunction(library: .default, name: "zoom")
    var shader: Shader { Shader(function: shaderFunction, arguments: [
        .boundingRect,
        .float(blur), // Blur strength
    ])
    }
    
    var body: some View {
        ZStack {
            Color(.black)
            if(enabled) {
                Image("maps")
                    .resizable()
                    // A shader cannot expand beyond the host's view. To avoid cropping of the motion blur effect, the actual assets is larger with plenty of padding
                    .frame(width: 600, height: 600)
                    .offset(x: position.x, y: position.y)
                    .scaleEffect(x: scale.x, y: scale.y)
                    .layerEffect(
                        shader,
                        maxSampleOffset: .zero)
            }
            else {
                Image("maps")
                    .resizable()
                    .frame(width: 600, height: 600)
                    .offset(x: position.x, y: position.y)
                    .scaleEffect(x: scale.x, y: scale.y)
            }
            EffectToggle(enabled: $enabled)
                .position(x: 460, y: 40)
        }
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
                    
                    // Scale
                    scaleAnimator.spring = .init(dampingRatio: 0.8, response: 0.5)
                    scaleAnimator.target = CGPoint(x: 1.0, y: 1.0)
                    scaleAnimator.start()
                }
                .onEnded { value in
                    // Position
                    positionAnimator.spring = .init(dampingRatio: 0.72, response: 0.7)
                    positionAnimator.target = Self.restingPosition
                    positionAnimator.start()
                    
                    // Scale
                    // Scale 0.92, 0.2
                    scaleAnimator.spring = .init(dampingRatio: 0.95, response: 0.25)
                    scaleAnimator.target = Self.restingScale
                    scaleAnimator.start()
                    
                    initialTouchLocation = .zero
                    isDragging = false
                }
        )
        .onAppear {
            positionAnimator.valueChanged = { value in
                position = value
            }
            scaleAnimator.valueChanged = { value in
                scale = value
            }
            blurAnimator.valueChanged = { value in
                blur = value
            }
        }
        // Blur icon based on the scale value's velocity
        .onChange(of: position) { _, value in
            // Because we scale the icon uniformly, x == y velocity
            let blurTarget = isDragging ? Self.restingBlur : abs(scaleAnimator.velocity.x) * 0.1
            blurAnimator.spring = .init(dampingRatio: 0.92, response: 0.2)
            blurAnimator.target = blurTarget
            blurAnimator.start()
        }
        .ignoresSafeArea()
        .statusBar(hidden: true)
    }
}

