import Foundation
import Observation
import Combine

@Observable
@MainActor
final class ExpirationTimerService {
    private(set) var state: ExpirationState = .empty
    private var timer: AnyCancellable?
    private weak var storage: NoteStorageService?
    private weak var notifications: NotificationService?

    func start(storage: NoteStorageService, notifications: NotificationService) {
        self.storage = storage
        self.notifications = notifications
        refresh()
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.tick() }
    }

    func stop() {
        timer?.cancel()
        timer = nil
    }

    func extendNote() {
        storage?.extendExpiration()
        if let n = storage?.note {
            notifications?.scheduleNotifications(for: n)
        }
        refresh()
    }

    // Called on foreground to catch expirations that happened while app was closed
    func refresh() {
        guard let storage else { return }
        if let note = storage.note {
            if note.isExpired {
                storage.deleteNote()
                state = .justExpired
            } else if note.isUrgent {
                state = .expiring(note)
            } else {
                state = .active(note)
            }
        } else {
            state = state == .justExpired ? .justExpired : .empty
        }
    }

    func clearDestructionAnimation() {
        state = .empty
    }

    private func tick() {
        guard let storage else { return }
        guard let note = storage.note else {
            if case .justExpired = state { } else { state = .empty }
            return
        }
        if note.isExpired {
            storage.deleteNote()
            notifications?.cancelAll()
            state = .justExpired
        } else if note.isUrgent {
            state = .expiring(note)
        } else {
            state = .active(note)
        }
    }
}
