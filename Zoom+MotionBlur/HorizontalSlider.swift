import SwiftUI

struct HorizontalSlider: View {
    @Binding var value: CGFloat
    var range: ClosedRange<CGFloat>
    var steps: Double
    var label: String
    var color: Color = .blue

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(label)
                    .foregroundColor(.white.opacity(0.35))
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                Spacer()
                Text("\(value, specifier: "%.2f")")
                    .foregroundColor(.white)
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
            }
            .padding()
            Slider(value: $value, in: range, step: steps)
                .padding()
                .accentColor(color)
        }
        .background(RoundedRectangle(cornerRadius: 24.0).fill(.gray.opacity(0.15)))
    }
}
