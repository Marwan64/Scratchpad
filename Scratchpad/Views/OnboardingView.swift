import SwiftUI

struct OnboardingView: View {
    let onComplete: () -> Void

    @State private var page = 0
    @State private var appear = false

    private let pages: [OnboardPage] = [
        OnboardPage(
            icon: "tray.full.fill",
            title: "Your Notes app is full of temporary junk.",
            body: "Parking spots. WiFi passwords. Tracking codes. Random reminders. All mixed in with the stuff that actually matters.",
            accent: Color(red: 0.95, green: 0.55, blue: 0.35)
        ),
        OnboardPage(
            icon: "clock.arrow.circlepath",
            title: "Scratchpad is for things you only need briefly.",
            body: "It's not a notes app. It's digital RAM for your brain — a temporary buffer that clears itself automatically.",
            accent: Color(red: 0.35, green: 0.65, blue: 1.0)
        ),
        OnboardPage(
            icon: "timer",
            title: "One scratchpad. Auto-clears in 24 hours.",
            body: "Write anything. Close your phone. Come back later. When 24 hours pass, it quietly disappears on its own.",
            accent: Color(red: 0.40, green: 0.82, blue: 0.62)
        ),
        OnboardPage(
            icon: "rectangle.3.group.fill",
            title: "Always visible. Zero friction.",
            body: "Add the widget to your home screen. Your note lives there — tap to edit instantly, no loading, no navigation.",
            accent: Color(red: 0.70, green: 0.50, blue: 1.0)
        ),
        OnboardPage(
            icon: "bolt.fill",
            title: "Just write and move on.",
            body: "No folders. No sync. No account. No organization. The fastest way to temporarily remember something on your iPhone.",
            accent: Color(red: 0.35, green: 0.65, blue: 1.0)
        ),
    ]

    var body: some View {
        ZStack {
            Color(red: 0.06, green: 0.06, blue: 0.10).ignoresSafeArea()

            VStack(spacing: 0) {
                TabView(selection: $page) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { idx, p in
                        pageView(p).tag(idx)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(response: 0.5), value: page)

                // Progress dots
                HStack(spacing: 6) {
                    ForEach(0..<pages.count, id: \.self) { i in
                        Capsule()
                            .fill(i == page ? pages[page].accent : Color.white.opacity(0.18))
                            .frame(width: i == page ? 22 : 6, height: 6)
                            .animation(.spring(response: 0.35), value: page)
                    }
                }
                .padding(.bottom, 28)

                // Action button
                Button {
                    HapticManager.shared.impact(.light)
                    if page < pages.count - 1 {
                        withAnimation(.spring(response: 0.45)) { page += 1 }
                    } else {
                        onComplete()
                    }
                } label: {
                    Text(page < pages.count - 1 ? "Continue" : "Open My Scratchpad")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(pages[page].accent, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .animation(.easeInOut(duration: 0.2), value: page)
                .padding(.horizontal, 28)
                .padding(.bottom, 52)
            }
        }
        .opacity(appear ? 1 : 0)
        .onAppear { withAnimation(.easeIn(duration: 0.4)) { appear = true } }
    }

    private func pageView(_ p: OnboardPage) -> some View {
        VStack(spacing: 32) {
            Spacer()

            ZStack {
                Circle()
                    .fill(p.accent.opacity(0.10))
                    .frame(width: 110, height: 110)
                Circle()
                    .fill(p.accent.opacity(0.06))
                    .frame(width: 140, height: 140)
                Image(systemName: p.icon)
                    .font(.system(size: 40, weight: .medium))
                    .foregroundStyle(p.accent)
            }

            VStack(spacing: 14) {
                Text(p.title)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Text(p.body)
                    .font(.system(size: 16, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.55))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.horizontal, 36)

            Spacer()
            Spacer()
        }
    }
}

private struct OnboardPage {
    let icon: String
    let title: String
    let body: String
    let accent: Color
}
