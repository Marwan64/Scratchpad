import Foundation
import WidgetKit

struct WidgetSyncService {
    static func reloadWidgets() {
        WidgetCenter.shared.reloadAllTimelines()
    }
}
