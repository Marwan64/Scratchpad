import AppIntents
import WidgetKit

// MARK: - Open Editor

struct OpenScratchpadIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Scratchpad"
    static var description = IntentDescription("Open Scratchpad to start typing immediately.")
    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        .result()
    }
}

// MARK: - Extend +24h

struct ExtendScratchpadIntent: AppIntent {
    static var title: LocalizedStringResource = "Extend Scratchpad +24h"
    static var description = IntentDescription("Add 24 hours to your scratchpad's expiration without opening the app.")
    static var openAppWhenRun: Bool = false

    func perform() async throws -> some IntentResult {
        let defaults = UserDefaults(suiteName: "group.com.scratchpad.app") ?? .standard
        if let data = defaults.data(forKey: "scratchpad_note_v1"),
           var note = try? JSONDecoder().decode(WidgetNotePayload.self, from: data) {
            let base = max(note.expiresAt, Date())
            note.expiresAt = base.addingTimeInterval(86_400)
            if let encoded = try? JSONEncoder().encode(note) {
                defaults.set(encoded, forKey: "scratchpad_note_v1")
            }
        }
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}

// MARK: - Clear

struct ClearScratchpadIntent: AppIntent {
    static var title: LocalizedStringResource = "Clear Scratchpad"
    static var description = IntentDescription("Immediately clear your scratchpad.")
    static var openAppWhenRun: Bool = false

    func perform() async throws -> some IntentResult {
        let defaults = UserDefaults(suiteName: "group.com.scratchpad.app") ?? .standard
        defaults.removeObject(forKey: "scratchpad_note_v1")
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}

// Minimal Codable mirror of ScratchpadNote — avoids cross-target imports
struct WidgetNotePayload: Codable {
    var id: UUID
    var text: String
    var createdAt: Date
    var expiresAt: Date
}
