import SwiftUI

struct DestructionAnimationOverlay: View {
    let theme: AppTheme
    let onComplete: () -> Void

    @State private var particles: [Particle] = []
    @State private var textOpacity: Double = 1
    @State private var overlayOpacity: Double = 0

    var body: some View {
        ZStack {
            theme.background
                .opacity(overlayOpacity)
                .ignoresSafeArea()

            ForEach(particles) { p in
                Circle()
                    .fill(theme.subtleText.opacity(p.opacity))
                    .frame(width: p.size, height: p.size)
                    .position(p.position)
                    .blur(radius: p.blur)
            }

            VStack(spacing: 12) {
                Image(systemName: "wind")
                    .font(.system(size: 28, weight: .ultraLight))
                    .foregroundStyle(theme.subtleText.opacity(0.6))

                Text("Gone.")
                    .font(.system(size: 24, weight: .light, design: .rounded))
                    .foregroundStyle(theme.subtleText.opacity(0.5))
            }
            .opacity(textOpacity)
        }
        .onAppear { animate() }
    }

    private func animate() {
        // Spawn particles across the screen
        particles = (0..<60).map { _ in
            Particle(
                position: CGPoint(
                    x: CGFloat.random(in: 40...340),
                    y: CGFloat.random(in: 100...700)
                ),
                size: CGFloat.random(in: 2...6),
                opacity: Double.random(in: 0.3...0.7),
                blur: CGFloat.random(in: 0...1.5)
            )
        }

        withAnimation(.easeIn(duration: 0.3)) { overlayOpacity = 1 }

        withAnimation(.easeOut(duration: 1.4).delay(0.3)) {
            particles = particles.map { p in
                var m = p
                m.position.y -= CGFloat.random(in: 60...200)
                m.opacity = 0
                return m
            }
        }

        withAnimation(.easeOut(duration: 0.6).delay(1.2)) { textOpacity = 0 }

        withAnimation(.easeOut(duration: 0.5).delay(1.8)) { overlayOpacity = 0 }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) { onComplete() }
    }
}

private struct Particle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var size: CGFloat
    var opacity: Double
    var blur: CGFloat
}
