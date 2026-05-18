import SwiftUI

struct ExpiredNoteAnimationView: View {
    let theme: AppTheme
    let onComplete: () -> Void

    var body: some View {
        DestructionAnimationOverlay(theme: theme, onComplete: onComplete)
            .transition(.opacity)
    }
}
