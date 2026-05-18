import Foundation

enum ExpirationState: Equatable {
    case empty                    // no note exists
    case active(ScratchpadNote)   // note is alive
    case expiring(ScratchpadNote) // < 1 hour remaining
    case justExpired              // expired this session, show animation
}

extension ExpirationState {
    var note: ScratchpadNote? {
        switch self {
        case .active(let n), .expiring(let n): return n
        default: return nil
        }
    }

    var hasNote: Bool { note != nil }

    var isUrgent: Bool {
        if case .expiring = self { return true }
        return false
    }

    var showDestructionAnimation: Bool {
        if case .justExpired = self { return true }
        return false
    }
}
