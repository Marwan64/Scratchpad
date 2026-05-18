import SwiftUI

struct CountdownRing: View {
    let progress: Double       // 0 = fresh, 1 = expired
    let timeString: String
    let isUrgent: Bool
    let theme: AppTheme

    @State private var pulse = false

    private var ringColor: Color {
        isUrgent ? theme.urgentColor : theme.accentColor
    }

    var body: some View {
        ZStack {
            // Track
            Circle()
                .stroke(ringColor.opacity(0.12), lineWidth: 3)

            // Progress arc (clockwise consumption)
            Circle()
                .trim(from: 0, to: CGFloat(1 - progress))
                .stroke(
                    ringColor,
                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: progress)

            // Time label
            VStack(spacing: 0) {
                Text(timeString)
                    .font(.system(size: 9, weight: .semibold, design: .monospaced))
                    .foregroundStyle(ringColor)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
            }
        }
        .frame(width: 52, height: 52)
        .scaleEffect(pulse ? 1.05 : 1.0)
        .onChange(of: isUrgent) { _, urgent in
            if urgent {
                withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                    pulse = true
                }
            } else {
                withAnimation(.default) { pulse = false }
            }
        }
    }
}
