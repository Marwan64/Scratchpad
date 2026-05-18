import UIKit

@MainActor
final class HapticManager {
    static let shared = HapticManager()
    private init() {}

    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let g = UIImpactFeedbackGenerator(style: style)
        g.prepare()
        g.impactOccurred()
    }

    func success() {
        let g = UINotificationFeedbackGenerator()
        g.notificationOccurred(.success)
    }

    func warning() {
        let g = UINotificationFeedbackGenerator()
        g.notificationOccurred(.warning)
    }

    func selectionChanged() {
        UISelectionFeedbackGenerator().selectionChanged()
    }
}
