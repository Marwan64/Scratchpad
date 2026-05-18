import Foundation

struct ScratchpadNote: Codable, Equatable, Identifiable {
    var id: UUID
    var text: String
    var createdAt: Date
    var expiresAt: Date

    static func fresh(text: String = "") -> ScratchpadNote {
        let now = Date()
        return ScratchpadNote(
            id: UUID(),
            text: text,
            createdAt: now,
            expiresAt: now.addingTimeInterval(86_400)
        )
    }

    var isExpired: Bool { Date() >= expiresAt }

    var timeRemaining: TimeInterval { max(0, expiresAt.timeIntervalSinceNow) }

    // 0 = fresh, 1 = fully expired
    var progressFraction: Double {
        let total = expiresAt.timeIntervalSince(createdAt)
        guard total > 0 else { return 1 }
        let elapsed = Date().timeIntervalSince(createdAt)
        return max(0, min(1, elapsed / total))
    }

    var isUrgent: Bool { timeRemaining < 3_600 }

    mutating func extendByOneDay() {
        expiresAt = max(expiresAt, Date()).addingTimeInterval(86_400)
    }

    // Human-readable remaining time
    var formattedTimeRemaining: String {
        let r = timeRemaining
        if r <= 0 { return "Expired" }
        let h = Int(r) / 3600
        let m = (Int(r) % 3600) / 60
        let s = Int(r) % 60
        if h > 0 { return String(format: "%d:%02d:%02d", h, m, s) }
        return String(format: "%d:%02d", m, s)
    }
}
