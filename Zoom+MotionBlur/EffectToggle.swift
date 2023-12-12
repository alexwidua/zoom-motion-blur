import SwiftUI
import Wave

struct EffectToggle: View {
    @Binding var enabled: Bool
    @State var enabledBtnDown: Bool = false
    
    var body: some View {
        Rectangle()
            .fill(.black.opacity(0.0))
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged{ _ in
                        enabledBtnDown = true
                    }
                    .onEnded { _ in
                        enabledBtnDown = false
                        enabled.toggle()
                    }
            )
            .frame(width: 48, height: 48)
            .overlay {
                Ellipse()
                    .fill(enabled ? .green : .red)
                    .animation(nil)
                    .frame(width: 6, height: 6)
                    .scaleEffect(enabledBtnDown ? 0.5 : 1.0)
                    .animation(.spring(), value: enabledBtnDown)
            }
        
    }
}
