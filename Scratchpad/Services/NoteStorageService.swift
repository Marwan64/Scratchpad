import Foundation
import Observation

@Observable
@MainActor
final class NoteStorageService {
    static let appGroupID = "group.com.scratchpad.app"
    static let noteKey    = "scratchpad_note_v1"
    static let themeKey   = "scratchpad_theme_v1"
    static let onboardedKey = "scratchpad_onboarded_v1"

    private(set) var note: ScratchpadNote?
    private(set) var theme: AppTheme = .light
    var hasOnboarded: Bool = false

    private var defaults: UserDefaults

    init() {
        defaults = UserDefaults(suiteName: Self.appGroupID) ?? .standard
        note = Self.loadNote(from: defaults)
        theme = Self.loadTheme(from: defaults)
        hasOnboarded = defaults.bool(forKey: Self.onboardedKey)
    }

    func updateText(_ text: String) {
        if note != nil {
            note!.text = text
        } else {
            note = ScratchpadNote.fresh(text: text)
        }
        persist()
    }

    func createNoteIfNeeded(with text: String = "") {
        guard note == nil else { return }
        note = ScratchpadNote.fresh(text: text)
        persist()
    }

    func extendExpiration() {
        note?.extendByOneDay()
        persist()
    }

    func deleteNote() {
        note = nil
        persist()
    }

    func setTheme(_ t: AppTheme) {
        theme = t
        if let data = try? JSONEncoder().encode(t) {
            defaults.set(data, forKey: Self.themeKey)
        }
    }

    func markOnboarded() {
        hasOnboarded = true
        defaults.set(true, forKey: Self.onboardedKey)
    }

    private func persist() {
        guard let note else {
            defaults.removeObject(forKey: Self.noteKey)
            return
        }
        if let data = try? JSONEncoder().encode(note) {
            defaults.set(data, forKey: Self.noteKey)
        }
    }

    // MARK: Static helpers (safe to call before @MainActor init)

    static func loadNote(from defaults: UserDefaults) -> ScratchpadNote? {
        guard let data = defaults.data(forKey: noteKey) else { return nil }
        return try? JSONDecoder().decode(ScratchpadNote.self, from: data)
    }

    static func loadTheme(from defaults: UserDefaults) -> AppTheme {
        guard let data = defaults.data(forKey: themeKey),
              let t = try? JSONDecoder().decode(AppTheme.self, from: data)
        else { return .light }
        return t
    }
}
