import Foundation
import Observation

@Observable @MainActor
final class DeepLinkManager {
    var shouldFocusEditor = false

    func handle(_ url: URL, storage: NoteStorageService, expiration: ExpirationTimerService) {
        guard url.scheme == "scratchpad" else { return }
        switch url.host {
        case "extend":
            storage.extendExpiration()
            expiration.refresh()
            WidgetSyncService.reloadWidgets()
        case "clear":
            storage.deleteNote()
            expiration.refresh()
            WidgetSyncService.reloadWidgets()
        default:
            // "open", "edit", or any unknown host — just focus the editor
            shouldFocusEditor = true
        }
    }

    func consumeFocus() {
        shouldFocusEditor = false
    }
}
