import WidgetKit
import SwiftUI
import AppIntents

struct ScratchpadWidget: Widget {
    let kind = "ScratchpadWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ScratchpadWidgetProvider()) { entry in
            ScratchpadWidgetView(entry: entry)
                .containerBackground(for: .widget) {
                    WThemeBackground(themeKey: entry.themeKey)
                }
        }
        .configurationDisplayName("Scratchpad")
        .description("Your temporary scratchpad, always on your home screen.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .systemLarge,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline,
        ])
    }
}

// Thin SwiftUI background that reads the theme key directly
private struct WThemeBackground: View {
    let themeKey: String

    var bg: Color {
        switch themeKey {
        case "Dark":       return Color(red: 0.11, green: 0.11, blue: 0.13)
        case "Warm Paper": return Color(red: 0.97, green: 0.94, blue: 0.87)
        case "Midnight":   return Color(red: 0.05, green: 0.05, blue: 0.12)
        default:           return Color(red: 0.98, green: 0.98, blue: 0.99)
        }
    }

    var body: some View {
        bg
    }
}
