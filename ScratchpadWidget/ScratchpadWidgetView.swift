import WidgetKit
import SwiftUI
import AppIntents

// MARK: - Widget View Router

struct ScratchpadWidgetView: View {
    let entry: ScratchpadEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .accessoryCircular:
            AccessoryCircularView(entry: entry)
        case .accessoryRectangular:
            AccessoryRectangularView(entry: entry)
        case .accessoryInline:
            AccessoryInlineView(entry: entry)
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Theme Helpers (widget-side, no AppTheme import needed)

private struct WTheme {
    let background: Color
    let surface: Color
    let text: Color
    let subtle: Color
    let accent: Color
    let urgent: Color

    static func from(_ key: String) -> WTheme {
        switch key {
        case "Dark":
            return WTheme(
                background: Color(red: 0.11, green: 0.11, blue: 0.13),
                surface:    Color(red: 0.17, green: 0.17, blue: 0.20),
                text:       Color(red: 0.92, green: 0.92, blue: 0.94),
                subtle:     Color(red: 0.50, green: 0.50, blue: 0.55),
                accent:     Color(red: 0.40, green: 0.65, blue: 1.00),
                urgent:     Color(red: 1.00, green: 0.38, blue: 0.38)
            )
        case "Warm Paper":
            return WTheme(
                background: Color(red: 0.97, green: 0.94, blue: 0.87),
                surface:    Color(red: 0.99, green: 0.97, blue: 0.92),
                text:       Color(red: 0.22, green: 0.18, blue: 0.12),
                subtle:     Color(red: 0.52, green: 0.45, blue: 0.35),
                accent:     Color(red: 0.65, green: 0.42, blue: 0.18),
                urgent:     Color(red: 0.85, green: 0.35, blue: 0.20)
            )
        case "Midnight":
            return WTheme(
                background: Color(red: 0.05, green: 0.05, blue: 0.12),
                surface:    Color(red: 0.10, green: 0.10, blue: 0.20),
                text:       Color(red: 0.88, green: 0.88, blue: 0.96),
                subtle:     Color(red: 0.45, green: 0.45, blue: 0.60),
                accent:     Color(red: 0.55, green: 0.45, blue: 1.00),
                urgent:     Color(red: 1.00, green: 0.38, blue: 0.38)
            )
        default: // Light
            return WTheme(
                background: Color(red: 0.98, green: 0.98, blue: 0.99),
                surface:    Color.white,
                text:       Color(red: 0.10, green: 0.10, blue: 0.12),
                subtle:     Color(red: 0.55, green: 0.55, blue: 0.60),
                accent:     Color(red: 0.30, green: 0.55, blue: 1.00),
                urgent:     Color(red: 1.00, green: 0.38, blue: 0.38)
            )
        }
    }
}

// MARK: - Time Helpers

private func timeString(for entry: ScratchpadEntry) -> String {
    guard let exp = entry.expiresAt, !entry.isExpired else { return "—" }
    let r = max(0, exp.timeIntervalSinceNow)
    let h = Int(r) / 3600
    let m = (Int(r) % 3600) / 60
    if h > 0 { return "\(h)h \(m)m" }
    return "\(m)m"
}

private func progressFraction(for entry: ScratchpadEntry) -> Double {
    guard let exp = entry.expiresAt else { return 1 }
    let r = max(0, exp.timeIntervalSinceNow)
    return 1.0 - (r / 86_400.0)
}

private func isUrgent(_ entry: ScratchpadEntry) -> Bool {
    guard let exp = entry.expiresAt else { return false }
    return exp.timeIntervalSinceNow < 3_600
}

// MARK: - Small Widget

struct SmallWidgetView: View {
    let entry: ScratchpadEntry
    private var t: WTheme { WTheme.from(entry.themeKey) }

    var body: some View {
        if entry.isExpired || entry.noteText.isEmpty {
            smallEmpty
        } else {
            smallActive
        }
    }

    private var smallEmpty: some View {
        VStack(spacing: 8) {
            Image(systemName: "square.and.pencil")
                .font(.system(size: 20, weight: .ultraLight))
                .foregroundStyle(t.subtle)
            Text("Tap to write")
                .font(.system(size: 12, design: .rounded))
                .foregroundStyle(t.subtle)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .widgetURL(URL(string: "scratchpad://open"))
    }

    private var smallActive: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(t.accent)
                Spacer()
                Text(timeString(for: entry))
                    .font(.system(size: 9, weight: .semibold, design: .monospaced))
                    .foregroundStyle(isUrgent(entry) ? t.urgent : t.subtle)
            }
            .padding(.bottom, 7)

            Text(entry.noteText)
                .font(.system(size: 13, design: .rounded))
                .foregroundStyle(t.text)
                .lineLimit(5)
                .lineSpacing(2)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer(minLength: 0)
            progressBar
        }
        .padding(14)
        .widgetURL(URL(string: "scratchpad://open"))
    }

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(t.subtle.opacity(0.15)).frame(height: 2.5)
                Capsule()
                    .fill(isUrgent(entry) ? t.urgent.opacity(0.8) : t.accent.opacity(0.6))
                    .frame(width: geo.size.width * CGFloat(1 - progressFraction(for: entry)), height: 2.5)
            }
        }
        .frame(height: 2.5)
    }
}

// MARK: - Medium Widget

struct MediumWidgetView: View {
    let entry: ScratchpadEntry
    private var t: WTheme { WTheme.from(entry.themeKey) }

    var body: some View {
        if entry.isExpired || entry.noteText.isEmpty {
            mediumEmpty
        } else {
            mediumActive
        }
    }

    private var mediumEmpty: some View {
        HStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 22, weight: .ultraLight))
                    .foregroundStyle(t.subtle)
                Text("Your scratchpad is clear.")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(t.text)
                Text("Tap to start writing.")
                    .font(.system(size: 12, design: .rounded))
                    .foregroundStyle(t.subtle)
            }
            Spacer()
            Button(intent: OpenScratchpadIntent()) {
                Text("Write")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(t.accent, in: Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .widgetURL(URL(string: "scratchpad://open"))
    }

    private var mediumActive: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 5) {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(t.accent)
                    Text(timeString(for: entry))
                        .font(.system(size: 10, weight: .semibold, design: .monospaced))
                        .foregroundStyle(isUrgent(entry) ? t.urgent : t.subtle)
                }

                Text(entry.noteText)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundStyle(t.text)
                    .lineLimit(4)
                    .lineSpacing(3)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Spacer(minLength: 0)

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(t.subtle.opacity(0.12)).frame(height: 2.5)
                        Capsule()
                            .fill(isUrgent(entry) ? t.urgent.opacity(0.8) : t.accent.opacity(0.55))
                            .frame(width: geo.size.width * CGFloat(1 - progressFraction(for: entry)), height: 2.5)
                    }
                }
                .frame(height: 2.5)
            }

            // Quick actions (premium only)
            if entry.isUnlocked {
                VStack(spacing: 8) {
                    Button(intent: ExtendScratchpadIntent()) {
                        Image(systemName: "pin.fill")
                            .font(.system(size: 13))
                            .foregroundStyle(t.accent)
                            .frame(width: 36, height: 36)
                            .background(t.accent.opacity(0.12), in: Circle())
                    }
                    .buttonStyle(.plain)

                    Button(intent: ClearScratchpadIntent()) {
                        Image(systemName: "trash")
                            .font(.system(size: 13))
                            .foregroundStyle(t.subtle)
                            .frame(width: 36, height: 36)
                            .background(t.subtle.opacity(0.10), in: Circle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(16)
        .widgetURL(URL(string: "scratchpad://open"))
    }
}

// MARK: - Large Widget

struct LargeWidgetView: View {
    let entry: ScratchpadEntry
    private var t: WTheme { WTheme.from(entry.themeKey) }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                HStack(spacing: 5) {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(t.accent)
                    Text("Scratchpad")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(t.subtle)
                }
                Spacer()
                Text(timeString(for: entry))
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundStyle(isUrgent(entry) ? t.urgent : t.subtle)

                if entry.isUnlocked {
                    Button(intent: ExtendScratchpadIntent()) {
                        Image(systemName: "pin")
                            .font(.system(size: 13))
                            .foregroundStyle(t.accent)
                            .padding(6)
                            .background(t.accent.opacity(0.12), in: Circle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.bottom, 14)

            if entry.noteText.isEmpty || entry.isExpired {
                VStack(spacing: 10) {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 28, weight: .ultraLight))
                        .foregroundStyle(t.subtle)
                    Text("Your scratchpad is clear.\nTap anywhere to write.")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundStyle(t.subtle)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Text(entry.noteText)
                    .font(.system(size: 15, design: .rounded))
                    .foregroundStyle(t.text)
                    .lineSpacing(5)
                    .lineLimit(14)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Spacer(minLength: 0)

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(t.subtle.opacity(0.12)).frame(height: 3)
                        Capsule()
                            .fill(isUrgent(entry) ? t.urgent.opacity(0.8) : t.accent.opacity(0.55))
                            .frame(width: geo.size.width * CGFloat(1 - progressFraction(for: entry)), height: 3)
                    }
                }
                .frame(height: 3)
                .padding(.top, 12)
            }
        }
        .padding(18)
        .widgetURL(URL(string: "scratchpad://open"))
    }
}

// MARK: - Accessory Circular (Lock Screen)

struct AccessoryCircularView: View {
    let entry: ScratchpadEntry

    var progress: Double {
        1.0 - progressFraction(for: entry)
    }

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            if entry.isExpired || entry.noteText.isEmpty {
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 16, weight: .medium))
            } else {
                VStack(spacing: 1) {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 11, weight: .medium))
                    Text(timeString(for: entry))
                        .font(.system(size: 9, weight: .semibold, design: .monospaced))
                }
            }
        }
        .widgetURL(URL(string: "scratchpad://open"))
    }
}

// MARK: - Accessory Rectangular (Lock Screen)

struct AccessoryRectangularView: View {
    let entry: ScratchpadEntry

    var body: some View {
        if entry.isExpired || entry.noteText.isEmpty {
            Label("Tap to write", systemImage: "square.and.pencil")
                .font(.system(size: 12, design: .rounded))
                .widgetURL(URL(string: "scratchpad://open"))
        } else {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 9, weight: .semibold))
                    Text(timeString(for: entry))
                        .font(.system(size: 9, weight: .semibold, design: .monospaced))
                }
                .foregroundStyle(.secondary)

                Text(entry.noteText)
                    .font(.system(size: 12, design: .rounded))
                    .lineLimit(2)
                    .lineSpacing(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .widgetURL(URL(string: "scratchpad://open"))
        }
    }
}

// MARK: - Accessory Inline (Lock Screen)

struct AccessoryInlineView: View {
    let entry: ScratchpadEntry

    var body: some View {
        if entry.isExpired || entry.noteText.isEmpty {
            Label("Scratchpad: empty", systemImage: "square.and.pencil")
        } else {
            let firstLine = entry.noteText.components(separatedBy: "\n").first ?? entry.noteText
            Label(firstLine, systemImage: "square.and.pencil")
        }
    }
}
