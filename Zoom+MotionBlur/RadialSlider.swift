//
import SwiftUI

struct RadialSlider: View {
    @Binding var angle: CGFloat
    @State private var isDragging: Bool = false
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(.white.opacity(0.1), lineWidth: 3)
                .frame(width: 64, height: 64)
            Rectangle()
                .fill(isDragging ? .blue : .white.opacity(0.1))
                .frame(width: 4, height: 32)
                .offset(y: -16)
                .rotationEffect(Angle(degrees: 90))
                .rotationEffect(Angle(radians: angle))
            Circle()
                .fill(.white)
                .frame(width: 28, height: 28)
                .offset(x: 32)
                .rotationEffect(Angle(radians: angle))
                .gesture(
                    DragGesture(minimumDistance: 0.0)
                        .onChanged { value in
                            let vector = CGVector(dx: value.location.x, dy: value.location.y)
                            angle = atan2(vector.dy, vector.dx)
                            isDragging = true
                        }
                        .onEnded { _ in
                            isDragging = false
                        }
                )
        }
        .padding(24.0)
        .background(RoundedRectangle(cornerRadius: 24.0).fill(.gray.opacity(0.15)))
    }
    
}


