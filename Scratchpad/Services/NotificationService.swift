import Foundation
import UserNotifications
import Observation

@Observable
@MainActor
final class NotificationService {
    private(set) var isAuthorized: Bool = false
    var remindersEnabled: Bool = true {
        didSet { UserDefaults.standard.set(remindersEnabled, forKey: "notifications_enabled") }
    }

    init() {
        remindersEnabled = UserDefaults.standard.object(forKey: "notifications_enabled") as? Bool ?? true
        Task { await checkAuthorization() }
    }

    func requestPermission() async {
        let center = UNUserNotificationCenter.current()
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            isAuthorized = granted
        } catch {
            isAuthorized = false
        }
    }

    func scheduleNotifications(for note: ScratchpadNote) {
        guard isAuthorized && remindersEnabled else { return }
        cancelAll()
        let center = UNUserNotificationCenter.current()

        let oneHourBefore = note.expiresAt.addingTimeInterval(-3_600)
        if oneHourBefore > Date() {
            schedule(
                id: "sp_warn",
                title: "Scratchpad expiring soon",
                body: "Your note disappears in 1 hour — tap to extend.",
                at: oneHourBefore,
                center: center
            )
        }

        if note.expiresAt > Date() {
            schedule(
                id: "sp_gone",
                title: "Scratchpad cleared",
                body: "Your note has disappeared. Start fresh anytime.",
                at: note.expiresAt,
                center: center
            )
        }
    }

    func cancelAll() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["sp_warn", "sp_gone"])
    }

    private func checkAuthorization() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        isAuthorized = settings.authorizationStatus == .authorized
    }

    private func schedule(id: String, title: String, body: String, at date: Date, center: UNUserNotificationCenter) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        center.add(UNNotificationRequest(identifier: id, content: content, trigger: trigger))
    }
}
