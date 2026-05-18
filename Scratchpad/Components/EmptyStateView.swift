import SwiftUI

struct EmptyStateView: View {
    let theme: AppTheme
    @State private var opacity: Double = 0

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "square.and.pencil")
                .font(.system(size: 38, weight: .ultraLight))
                .foregroundStyle(theme.subtleText)

            VStack(spacing: 6) {
                Text("Nothing here yet")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundStyle(theme.subtleText)
                Text("Start typing anything — it disappears in 24 hours.")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundStyle(theme.subtleText.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, 40)
        .opacity(opacity)
        .onAppear {
            withAnimation(.easeIn(duration: 0.6).delay(0.2)) {
                opacity = 1
            }
        }
        .allowsHitTesting(false)
    }
}
