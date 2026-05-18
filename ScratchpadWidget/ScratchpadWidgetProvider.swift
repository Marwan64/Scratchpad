import WidgetKit
import SwiftUI

struct ScratchpadEntry: TimelineEntry {
    let date: Date
    let noteText: String
    let expiresAt: Date?
    let isExpired: Bool
    let isUnlocked: Bool
    let themeKey: String
}

struct ScratchpadWidgetProvider: TimelineProvider {
    private let appGroupID = "group.com.scratchpad.app"
    private let noteKey    = "scratchpad_note_v1"
    private let themeKey   = "scratchpad_theme_v1"
    private let unlockKey  = "sp_widget_unlocked"

    func placeholder(in context: Context) -> ScratchpadEntry {
        ScratchpadEntry(
            date: .now,
            noteText: "Parking: Level B3, spot 42\nWiFi: Guest_5G / park2024",
            expiresAt: Date().addingTimeInterval(86400),
            isExpired: false,
            isUnlocked: true,
            themeKey: "Light"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (ScratchpadEntry) -> Void) {
        completion(entry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ScratchpadEntry>) -> Void) {
        let current = entry()
        var entries = [current]
        var policy: TimelineReloadPolicy = .after(Date().addingTimeInterval(300))

        if let exp = current.expiresAt, exp > Date() {
            entries.append(ScratchpadEntry(
                date: exp,
                noteText: "",
                expiresAt: nil,
                isExpired: true,
                isUnlocked: current.isUnlocked,
                themeKey: current.themeKey
            ))
            policy = .after(exp.addingTimeInterval(5))
        }

        completion(Timeline(entries: entries, policy: policy))
    }

    private func entry() -> ScratchpadEntry {
        let defaults = UserDefaults(suiteName: appGroupID) ?? .standard

        let isUnlocked = defaults.bool(forKey: unlockKey)
        let resolvedTheme = resolveTheme(defaults: defaults)

        guard let data = defaults.data(forKey: noteKey),
              let raw = try? JSONDecoder().decode(WidgetNote.self, from: data)
        else {
            return ScratchpadEntry(date: .now, noteText: "", expiresAt: nil, isExpired: false,
                                   isUnlocked: isUnlocked, themeKey: resolvedTheme)
        }

        let expired = Date() >= raw.expiresAt
        return ScratchpadEntry(
            date: .now,
            noteText: expired ? "" : raw.text,
            expiresAt: expired ? nil : raw.expiresAt,
            isExpired: expired,
            isUnlocked: isUnlocked,
            themeKey: resolvedTheme
        )
    }

    private func resolveTheme(defaults: UserDefaults) -> String {
        guard let data = defaults.data(forKey: themeKey),
              let str = try? JSONDecoder().decode(String.self, from: data)
        else { return "Light" }
        return str
    }
}

private struct WidgetNote: Codable {
    var id: UUID
    var text: String
    var createdAt: Date
    var expiresAt: Date
}
