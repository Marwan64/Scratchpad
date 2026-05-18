import SwiftUI

struct ScratchpadEditorBackground: View {
    let theme: AppTheme

    var body: some View {
        ZStack {
            theme.background

            LinearGradient(
                stops: [
                    .init(color: theme.editorAccentWash, location: 0),
                    .init(color: .clear, location: 0.38),
                    .init(color: theme.secondaryAccentColor.opacity(0.05), location: 1),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: 27) {
                ForEach(0..<30, id: \.self) { _ in
                    Rectangle()
                        .fill(theme.editorRuleColor)
                        .frame(height: 0.6)
                }
            }
            .padding(.top, 118)
            .padding(.horizontal, 20)
            .mask(
                LinearGradient(
                    stops: [
                        .init(color: .clear, location: 0),
                        .init(color: .black.opacity(0.7), location: 0.12),
                        .init(color: .black.opacity(0.45), location: 0.68),
                        .init(color: .clear, location: 1),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
    }
}

struct EmptyEditorHintView: View {
    let theme: AppTheme

    var body: some View {
        HStack(spacing: 8) {
            Label("Fresh note", systemImage: "sparkle")
            Circle()
                .fill(theme.subtleText.opacity(0.28))
                .frame(width: 3, height: 3)
            Label("Auto-clears in 24h", systemImage: "timer")
        }
        .font(.system(size: 12, weight: .semibold, design: .rounded))
        .foregroundStyle(theme.subtleText.opacity(0.58))
        .symbolRenderingMode(.hierarchical)
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background {
            Capsule()
                .fill(theme.surfaceColor.opacity(0.64))
                .overlay {
                    Capsule()
                        .strokeBorder(theme.dividerColor, lineWidth: 0.5)
                }
        }
    }
}

struct ThemeSwatch: View {
    let theme: AppTheme
    let isSelected: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(theme.background)
                .overlay(alignment: .bottomTrailing) {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    theme.accentColor.opacity(0.85),
                                    theme.secondaryAccentColor.opacity(0.75),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 20, height: 20)
                        .padding(3)
                }

            if isSelected {
                Image(systemName: "checkmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 18, height: 18)
                    .background(theme.accentColor, in: Circle())
            }
        }
        .frame(width: 34, height: 34)
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .strokeBorder(isSelected ? theme.accentColor : theme.dividerColor, lineWidth: isSelected ? 1.5 : 0.7)
        }
    }
}
