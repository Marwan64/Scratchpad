import SwiftUI

struct FloatingCountdownView: View {
    let note: ScratchpadNote?
    let theme: AppTheme

    @State private var pulse = false

    private var isUrgent: Bool { note?.isUrgent ?? false }

    private var timeString: String {
        guard let note, !note.isExpired else { return "—" }
        return note.formattedTimeRemaining
    }

    var body: some View {
        HStack(spacing: 6) {
            MiniExpirationRing(
                progress: note?.progressFraction ?? 0,
                isUrgent: isUrgent,
                theme: theme
            )
            Text(timeString)
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundStyle(isUrgent ? theme.urgentColor : theme.subtleText)
                .contentTransition(.numericText())
                .animation(.linear(duration: 1), value: timeString)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background {
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay {
                    Capsule()
                        .strokeBorder(
                            isUrgent
                                ? theme.urgentColor.opacity(0.5)
                                : theme.dividerColor,
                            lineWidth: 0.5
                        )
                }
        }
        .scaleEffect(pulse ? 1.04 : 1.0)
        .onAppear { startPulseIfNeeded() }
        .onChange(of: isUrgent) { _, _ in startPulseIfNeeded() }
    }

    private func startPulseIfNeeded() {
        if isUrgent {
            withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) {
                pulse = true
            }
        } else {
            withAnimation { pulse = false }
        }
    }
}

struct MiniExpirationRing: View {
    let progress: Double
    let isUrgent: Bool
    let theme: AppTheme

    var ringColor: Color {
        if isUrgent { return theme.urgentColor }
        if progress > 0.8 { return theme.accentColor.opacity(0.6) }
        return theme.accentColor
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(theme.dividerColor, lineWidth: 1.5)
            Circle()
                .trim(from: 0, to: max(0.02, 1.0 - progress))
                .stroke(ringColor, style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: progress)
        }
        .frame(width: 13, height: 13)
    }
}
