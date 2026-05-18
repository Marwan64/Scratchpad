import SwiftUI
import UIKit

@main
struct ScratchpadApp: App {
    @State private var storage = NoteStorageService()
    @State private var expiration = ExpirationTimerService()
    @State private var notifications = NotificationService()
    @State private var purchases = PurchaseManager()
    @State private var deepLink = DeepLinkManager()

    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            RootView(
                storage: storage,
                expiration: expiration,
                notifications: notifications,
                purchases: purchases,
                deepLink: deepLink
            )
            .onOpenURL { url in
                deepLink.handle(url, storage: storage, expiration: expiration)
            }
            .onChange(of: scenePhase) { _, phase in
                switch phase {
                case .active:
                    expiration.refresh()
                    WidgetSyncService.reloadWidgets()
                    Task { await notifications.requestPermission() }
                case .background:
                    WidgetSyncService.reloadWidgets()
                default:
                    break
                }
            }
        }
    }
}

// MARK: - Root View

struct RootView: View {
    let storage: NoteStorageService
    let expiration: ExpirationTimerService
    let notifications: NotificationService
    let purchases: PurchaseManager
    let deepLink: DeepLinkManager

    var body: some View {
        Group {
            if !storage.hasOnboarded {
                OnboardingView {
                    storage.markOnboarded()
                    expiration.start(storage: storage, notifications: notifications)
                }
                .transition(.opacity)
            } else {
                ScratchpadView(
                    storage: storage,
                    expiration: expiration,
                    notifications: notifications,
                    purchases: purchases,
                    deepLink: deepLink
                )
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: storage.hasOnboarded)
        .onAppear {
            if storage.hasOnboarded {
                expiration.start(storage: storage, notifications: notifications)
            }
        }
    }
}
