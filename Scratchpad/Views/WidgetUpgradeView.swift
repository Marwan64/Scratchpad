import SwiftUI

struct WidgetUpgradeView: View {
    @Environment(\.dismiss) private var dismiss
    let purchases: PurchaseManager
    let theme: AppTheme

    @State private var appear = false

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(theme.subtleText)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)

                ScrollView {
                    VStack(spacing: 32) {
                        // Widget preview mock
                        widgetPreview

                        // Feature list
                        VStack(alignment: .leading, spacing: 16) {
                            featureRow("rectangle.3.group", "Home Screen Widget", "See your scratchpad without opening the app.")
                            featureRow("timer", "Live Countdown", "Watch the 24-hour timer right on your home screen.")
                            featureRow("hand.tap", "Quick Edit", "Tap the widget to jump straight to editing.")
                            featureRow("arrow.clockwise", "Always Up-to-Date", "Widget stays in sync with your latest text.")
                        }
                        .padding(.horizontal, 28)

                        // Price tag
                        VStack(spacing: 8) {
                            Text("One-time purchase")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundStyle(theme.subtleText)

                            Text(purchases.formattedPrice)
                                .font(.system(size: 42, weight: .bold, design: .rounded))
                                .foregroundStyle(theme.textColor)

                            Text("No subscription. Yours forever.")
                                .font(.system(size: 13, design: .rounded))
                                .foregroundStyle(theme.subtleText.opacity(0.7))
                        }

                        // Buy button
                        VStack(spacing: 12) {
                            Button {
                                Task { await purchases.purchase() }
                            } label: {
                                HStack(spacing: 8) {
                                    if purchases.isPurchasing {
                                        ProgressView()
                                            .tint(.white)
                                            .scaleEffect(0.85)
                                    } else {
                                        Image(systemName: "sparkles")
                                        Text("Unlock Widget — \(purchases.formattedPrice)")
                                    }
                                }
                                .font(.system(size: 17, weight: .semibold, design: .rounded))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(theme.accentColor, in: RoundedRectangle(cornerRadius: 16))
                                .shadow(color: theme.accentColor.opacity(0.3), radius: 12, y: 4)
                            }
                            .disabled(purchases.isPurchasing)

                            Button {
                                Task { await purchases.restorePurchases() }
                            } label: {
                                Text("Restore Purchase")
                                    .font(.system(size: 14, design: .rounded))
                                    .foregroundStyle(theme.subtleText)
                            }
                        }
                        .padding(.horizontal, 28)
                        .padding(.bottom, 40)
                    }
                    .padding(.top, 24)
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 20)
                    .animation(.spring(response: 0.5).delay(0.1), value: appear)
                }
            }
        }
        .onAppear { appear = true }
    }

    private var widgetPreview: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(theme.surfaceColor)
                .shadow(color: theme.textColor.opacity(0.06), radius: 20, y: 8)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 13))
                        .foregroundStyle(theme.accentColor)
                    Text("SCRATCHPAD")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(theme.accentColor)
                    Spacer()
                    Text("23:45:00")
                        .font(.system(size: 10, weight: .semibold, design: .monospaced))
                        .foregroundStyle(theme.subtleText)
                }

                Text("Parking spot B3\nWiFi: Guest_5G\nFlight UA2847")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundStyle(theme.textColor)
                    .lineSpacing(3)
            }
            .padding(16)
        }
        .frame(width: 200, height: 140)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(theme.accentColor.opacity(0.2), lineWidth: 1.5)
        )
    }

    private func featureRow(_ icon: String, _ title: String, _ description: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(theme.accentColor)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(theme.textColor)
                Text(description)
                    .font(.system(size: 13, design: .rounded))
                    .foregroundStyle(theme.subtleText)
            }
        }
    }
}
