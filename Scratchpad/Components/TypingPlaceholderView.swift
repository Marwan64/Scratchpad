import SwiftUI

struct TypingPlaceholderView: View {
    let theme: AppTheme
    @State private var cursorVisible = true
    @State private var displayedText = ""
    @State private var charIndex = 0

    private let phrases = [
        "Parking spot: B3",
        "WiFi: HomeNetwork_5G",
        "Flight: UA 2847",
        "Package: 1Z999AA10123456",
        "Reminder: call dentist",
        "Grocery: milk, eggs, oat milk",
    ]
    @State private var phraseIndex = 0

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            Text(displayedText)
                .font(.system(size: 18, weight: .regular, design: .rounded))
                .foregroundStyle(theme.subtleText.opacity(0.5))

            Rectangle()
                .frame(width: 2, height: 22)
                .foregroundStyle(theme.subtleText.opacity(cursorVisible ? 0.4 : 0))
                .animation(.easeInOut(duration: 0.5), value: cursorVisible)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .allowsHitTesting(false)
        .onAppear {
            startTyping()
            startCursorBlink()
        }
    }

    private func startCursorBlink() {
        Timer.scheduledTimer(withTimeInterval: 0.55, repeats: true) { _ in
            cursorVisible.toggle()
        }
    }

    private func startTyping() {
        charIndex = 0
        displayedText = ""
        let phrase = phrases[phraseIndex % phrases.count]

        Timer.scheduledTimer(withTimeInterval: 0.065, repeats: true) { timer in
            if charIndex < phrase.count {
                let idx = phrase.index(phrase.startIndex, offsetBy: charIndex)
                displayedText += String(phrase[idx])
                charIndex += 1
            } else {
                timer.invalidate()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                    withAnimation(.easeOut(duration: 0.35)) { displayedText = "" }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        phraseIndex += 1
                        startTyping()
                    }
                }
            }
        }
    }
}
