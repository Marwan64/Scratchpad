import SwiftUI

struct MinimalSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    let storage: NoteStorageService
    let notifications: NotificationService
    let purchases: PurchaseManager
    @Binding var theme: AppTheme

    @State private var showWidgetUpgrade = false

    var body: some View {
        NavigationView {
            ZStack {
                theme.background.ignoresSafeArea()

                List {
                    // Theme
                    Section {
                        ForEach(AppTheme.allCases, id: \.self) { t in
                            Button {
                                withAnimation(.spring(response: 0.3)) {
                                    theme = t
                                    storage.setTheme(t)
                                }
                            } label: {
                                HStack(spacing: 14) {
                                    Image(systemName: t.iconName)
                                        .font(.system(size: 16))
                                        .foregroundStyle(t.accentColor)
                                        .frame(width: 28)

                                    Text(t.rawValue)
                                        .font(.system(size: 16, design: .rounded))
                                        .foregroundStyle(theme.textColor)

                                    Spacer()

                                    if t == theme {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundStyle(theme.accentColor)
                                    }
                                }
                            }
                        }
                    } header: {
                        sectionHeader("Theme")
                    }
                    .listRowBackground(theme.surfaceColor)

                    // Notifications
                    Section {
                        Toggle(isOn: Bindable(notifications).remindersEnabled) {
                            Label("Expiration Reminders", systemImage: "bell")
                                .foregroundStyle(theme.textColor)
                        }
                        .tint(theme.accentColor)
                        .onChange(of: notifications.remindersEnabled) { _, _ in
                            if !notifications.isAuthorized {
                                Task { await notifications.requestPermission() }
                            }
                        }
                    } header: {
                        sectionHeader("Notifications")
                    } footer: {
                        Text("Get notified 1 hour before your scratchpad expires.")
                            .font(.system(size: 12, design: .rounded))
                            .foregroundStyle(theme.subtleText)
                    }
                    .listRowBackground(theme.surfaceColor)

                    // Widget
                    Section {
                        if purchases.isWidgetUnlocked {
                            HStack(spacing: 14) {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundStyle(theme.accentColor)
                                    .frame(width: 28)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Widget Unlocked")
                                        .font(.system(size: 16, design: .rounded))
                                        .foregroundStyle(theme.textColor)
                                    Text("Add the widget from your home screen.")
                                        .font(.system(size: 12, design: .rounded))
                                        .foregroundStyle(theme.subtleText)
                                }
                            }
                        } else {
                            Button {
                                showWidgetUpgrade = true
                            } label: {
                                HStack(spacing: 14) {
                                    Image(systemName: "rectangle.3.group")
                                        .foregroundStyle(theme.accentColor)
                                        .frame(width: 28)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Unlock Home Screen Widget")
                                            .font(.system(size: 16, weight: .medium, design: .rounded))
                                            .foregroundStyle(theme.textColor)
                                        Text("\(purchases.formattedPrice) · One-time purchase")
                                            .font(.system(size: 12, design: .rounded))
                                            .foregroundStyle(theme.subtleText)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12))
                                        .foregroundStyle(theme.subtleText)
                                }
                            }
                        }
                    } header: {
                        sectionHeader("Widget")
                    }
                    .listRowBackground(theme.surfaceColor)

                    // Privacy
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Privacy")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundStyle(theme.textColor)
                            Text("Your scratchpad lives entirely on your device. Nothing is uploaded, synced, or shared. Ever.")
                                .font(.system(size: 13, design: .rounded))
                                .foregroundStyle(theme.subtleText)
                                .lineSpacing(3)
                        }
                        .padding(.vertical, 4)
                    } header: {
                        sectionHeader("Privacy")
                    }
                    .listRowBackground(theme.surfaceColor)
                }
                .scrollContentBackground(.hidden)
                .listStyle(.insetGrouped)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(theme.accentColor)
                }
            }
        }
        .sheet(isPresented: $showWidgetUpgrade) {
            WidgetUpgradeView(purchases: purchases, theme: theme)
        }
    }

    private func sectionHeader(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.system(size: 11, weight: .semibold, design: .rounded))
            .foregroundStyle(theme.subtleText)
    }
}
