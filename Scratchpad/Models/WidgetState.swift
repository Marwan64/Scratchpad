import Foundation

struct WidgetState: Codable, Equatable {
    var noteText: String
    var expiresAt: Date?
    var isUnlocked: Bool

    var isEmpty: Bool {
        noteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var isExpired: Bool {
        guard let exp = expiresAt else { return isEmpty }
        return Date() >= exp
    }

    var timeRemaining: TimeInterval {
        guard let exp = expiresAt, !isExpired else { return 0 }
        return max(0, exp.timeIntervalSinceNow)
    }

    static var empty: WidgetState {
        WidgetState(noteText: "", expiresAt: nil, isUnlocked: false)
    }
}
