import SwiftUI
import Wave

#Preview {
    MotionBlurView()
}

struct MotionBlurView: View {
    // ┌───────┐
    // │ State │
    // └───────┘
    @State var enabled: Bool = true
    @State var isDragging: Bool = false
    @State var initialTouchLocation: CGPoint = .zero
    
    static let restingPosition = CGPoint(x: 0.15, y: 0.85)
    static let restingScale = CGPoint(x: 1.0, y: 1.0)
    static let restingBlur = CGFloat(0.0)
    
    @State var position = restingPosition
    @State var scale = CGPoint(x: 1.0, y: 1.0)
    @State var blur: CGFloat = 0.0
    @State var angle: CGFloat = 0.0
    
    // ┌──────┐
    // │ Wave │
    // └──────┘
    @State var positionAnimator = SpringAnimator<CGPoint>(
        spring: .init(dampingRatio: 0.92, response: 0.2),
        value: restingPosition
    )
    @State var scaleAnimator = SpringAnimator<CGPoint>(
        spring: .init(dampingRatio: 0.92, response: 0.2),
        value:  CGPoint(x: 1.0, y: 1.0)
    )
    @State var blurAnimator = SpringAnimator<CGFloat>(
        spring: .init(dampingRatio: 0.92, response: 0.2),
        value:  CGFloat(0.0)
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
            if(enabled) {
                Image("drag")
                    .resizable()
                    // A shader cannot expand beyond the host's view. To avoid cropping of the motion blur effect, the actual assets is larger with plenty of padding
                    .frame(width: 700, height: 700)
                    .offset(x: position.x, y: position.y)
                    .scaleEffect(x: scale.x, y: scale.y)
                    .layerEffect(
                        shader,
                        maxSampleOffset: .zero)
            }
            else {
                Image("drag")
                    .resizable()
                    .frame(width: 700, height: 700)
                    .offset(x: position.x, y: position.y)
            }
            EffectToggle(enabled: $enabled)
                .position(x: 510, y: 40)
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
                }
                .onEnded { value in
                    // Position
                    positionAnimator.spring = .init(dampingRatio: 0.72, response: 0.7)
                    positionAnimator.target = Self.restingPosition
                    positionAnimator.start()
                    
                    // Scale
                    scaleAnimator.spring = .init(dampingRatio: 0.92, response: 0.2)
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
        // Scale and blur based on the position value's velocity
        // For the demo, I only considered the y velocity
        // with a constant vertical motion blur...
        .onChange(of: position) { _, value in
            let avgVelocity = (positionAnimator.velocity.x + positionAnimator.velocity.y)  / 2
            
            // Scale
            let scaleX = 1.0 - (abs(positionAnimator.velocity.x) * 0.00005)
            let scaleY = 1.0 - (abs(positionAnimator.velocity.y) * 0.00005)
            let scaleTarget = isDragging ? CGPoint(x: scaleY, y: scaleX) : CGPoint(x: 1.0, y: 1.0)
            scaleAnimator.spring = .init(dampingRatio: 0.45, response: 0.52)
            scaleAnimator.target = scaleTarget
            scaleAnimator.start()
            
            // Blur
            let blurAmount =  avgVelocity * 0.00007
            let blurTarget = isDragging ? blurAmount : 0.0
            blurAnimator.spring = .init(dampingRatio: 0.92, response: 0.2)
            blurAnimator.target = blurTarget
            blurAnimator.start()
            
            let xVel = positionAnimator.velocity.x
            let yVel = positionAnimator.velocity.y
            let thetaRadians = atan2(yVel, xVel)
            angle = thetaRadians
        }
        .ignoresSafeArea()
        .statusBar(hidden: true)
    }
}
