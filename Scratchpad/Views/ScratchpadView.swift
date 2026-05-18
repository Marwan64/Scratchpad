import SwiftUI

struct ScratchpadView: View {
    let storage: NoteStorageService
    let expiration: ExpirationTimerService
    let notifications: NotificationService
    let purchases: PurchaseManager
    let deepLink: DeepLinkManager

    @State private var text = ""
    @State private var showSettings = false
    @State private var showPinToast = false
    @State private var showClearToast = false
    @State private var charCount = 0
    @State private var saveTask: Task<Void, Never>?

    private var theme: AppTheme { storage.theme }
    private var currentNote: ScratchpadNote? { expiration.state.note }

    var body: some View {
        ZStack(alignment: .top) {
            theme.background.ignoresSafeArea()

            // Full-screen instant-keyboard editor
            MinimalTextEditor(
                text: $text,
                theme: theme,
                autoFocus: true,
                onTextChange: { newText in
                    charCount = newText.count
                    scheduleSave(newText)
                }
            )
            .ignoresSafeArea(edges: .bottom)

            // Typing placeholder when empty
            if text.isEmpty {
                VStack(alignment: .leading) {
                    Spacer().frame(height: 104)
                    TypingPlaceholderView(theme: theme)
                        .padding(.horizontal, 20)
                        .allowsHitTesting(false)
                    Spacer()
                }
            }

            // Top chrome
            VStack(spacing: 0) {
                topBar
                    .background(.ultraThinMaterial)
                    .overlay(alignment: .bottom) {
                        Rectangle()
                            .fill(theme.dividerColor)
                            .frame(height: 0.5)
                    }
                Spacer()
                bottomBar
                    .background(.ultraThinMaterial)
                    .overlay(alignment: .top) {
                        Rectangle()
                            .fill(theme.dividerColor)
                            .frame(height: 0.5)
                    }
            }
            .ignoresSafeArea(edges: .bottom)

            // Expiration dissolution
            if expiration.state.showDestructionAnimation {
                DestructionAnimationOverlay(theme: theme) {
                    expiration.clearDestructionAnimation()
                }
                .ignoresSafeArea()
                .zIndex(20)
            }

            // Clear toast
            if showClearToast {
                VStack {
                    Spacer()
                    Label("Cleared. Timer reset.", systemImage: "arrow.counterclockwise")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(theme.textColor)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background {
                            Capsule()
                                .fill(theme.surfaceColor)
                                .shadow(color: .black.opacity(0.10), radius: 14, y: 5)
                        }
                        .padding(.bottom, 88)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .zIndex(10)
            }

            // Pin toast
            if showPinToast {
                VStack {
                    Spacer()
                    Label("Extended 24 hours", systemImage: "checkmark.circle.fill")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(theme.textColor)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(theme.accentColor, theme.textColor)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background {
                            Capsule()
                                .fill(theme.surfaceColor)
                                .shadow(color: .black.opacity(0.10), radius: 14, y: 5)
                        }
                        .padding(.bottom, 88)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .zIndex(10)
            }
        }
        .preferredColorScheme(theme.preferredColorScheme)
        .onAppear { syncText() }
        .onChange(of: expiration.state) { _, newState in
            switch newState {
            case .active(let note), .expiring(let note):
                if text != note.text { text = note.text }
            case .empty, .justExpired:
                text = ""
                charCount = 0
            }
        }
        .onChange(of: deepLink.shouldFocusEditor) { _, focus in
            if focus { deepLink.consumeFocus() }
        }
        .sheet(isPresented: $showSettings) {
            MinimalSettingsView(
                storage: storage,
                notifications: notifications,
                purchases: purchases,
                theme: Binding(get: { storage.theme }, set: { storage.setTheme($0) })
            )
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack(spacing: 12) {
            if let note = currentNote, !note.isExpired {
                FloatingCountdownView(note: note, theme: theme)
                    .transition(.scale(scale: 0.8).combined(with: .opacity))
            } else {
                HStack(spacing: 5) {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(theme.accentColor)
                    Text("Scratchpad")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(theme.subtleText)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Capsule().fill(theme.surfaceColor.opacity(0.7)))
            }

            Spacer()

            if charCount > 0 {
                Text("\(charCount)")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(theme.subtleText.opacity(0.6))
                    .contentTransition(.numericText())
                    .animation(.spring, value: charCount)
            }

            Button {
                HapticManager.shared.impact(.light)
                showSettings = true
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(theme.subtleText)
                    .frame(width: 36, height: 36)
                    .contentShape(Rectangle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .padding(.top, 2)
    }

    // MARK: - Bottom Bar

    private var bottomBar: some View {
        HStack(spacing: 12) {
            if !text.isEmpty || currentNote != nil {
                Button {
                    clearNote()
                } label: {
                    Label("Clear & Reset", systemImage: "arrow.counterclockwise")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(theme.subtleText.opacity(0.8))
                }
                .buttonStyle(.plain)
                .transition(.opacity)
            }

            Spacer()

            if currentNote != nil {
                Button { extendNote() } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "pin.fill")
                            .font(.system(size: 11))
                        Text("Pin +24h")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 9)
                    .background {
                        Capsule()
                            .fill(theme.accentColor)
                            .shadow(color: theme.accentColor.opacity(0.35), radius: 10, y: 3)
                    }
                }
                .buttonStyle(ScaleButtonStyle())
                .transition(.scale(scale: 0.8).combined(with: .opacity))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .padding(.bottom, 20)
        .animation(.spring(response: 0.3), value: currentNote != nil)
        .animation(.easeInOut(duration: 0.2), value: text.isEmpty)
    }

    // MARK: - Actions

    private func syncText() {
        text = currentNote?.text ?? ""
        charCount = text.count
    }

    private func scheduleSave(_ newText: String) {
        saveTask?.cancel()
        saveTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }
            if !newText.isEmpty {
                storage.updateText(newText)
                if let note = storage.note {
                    notifications.scheduleNotifications(for: note)
                }
            }
            expiration.refresh()
            WidgetSyncService.reloadWidgets()
        }
    }

    private func extendNote() {
        HapticManager.shared.success()
        expiration.extendNote()
        WidgetSyncService.reloadWidgets()
        withAnimation(.spring(response: 0.4)) { showPinToast = true }
        Task {
            try? await Task.sleep(nanoseconds: 2_300_000_000)
            withAnimation(.easeOut(duration: 0.25)) { showPinToast = false }
        }
    }

    private func clearNote() {
        HapticManager.shared.impact(.medium)
        withAnimation {
            storage.deleteNote()
            text = ""
            charCount = 0
            expiration.refresh()
            WidgetSyncService.reloadWidgets()
        }
        withAnimation(.spring(response: 0.4)) { showClearToast = true }
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            withAnimation(.easeOut(duration: 0.25)) { showClearToast = false }
        }
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.93 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.65), value: configuration.isPressed)
    }
}
