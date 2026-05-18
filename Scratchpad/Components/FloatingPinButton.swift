import SwiftUI

struct FloatingPinButton: View {
    let theme: AppTheme
    let action: () -> Void

    @State private var pressed = false

    var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            action()
        }) {
            HStack(spacing: 6) {
                Image(systemName: "pin.fill")
                    .font(.system(size: 12, weight: .semibold))
                Text("Pin +24h")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 18)
            .padding(.vertical, 11)
            .background(
                Capsule()
                    .fill(theme.accentColor)
                    .shadow(color: theme.accentColor.opacity(0.35), radius: 10, y: 4)
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .accessibilityLabel("Pin note for another 24 hours")
    }
}

