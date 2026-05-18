import SwiftUI
import UIKit

struct MinimalTextEditor: UIViewRepresentable {
    @Binding var text: String
    let theme: AppTheme
    var fontSize: CGFloat = 18
    var autoFocus: Bool = true
    var onTextChange: ((String) -> Void)?

    func makeUIView(context: Context) -> UITextView {
        let tv = FocusableTextView()
        tv.delegate = context.coordinator
        tv.font = .systemFont(ofSize: fontSize, weight: .regular)
        tv.backgroundColor = .clear
        tv.isScrollEnabled = true
        tv.showsVerticalScrollIndicator = false
        tv.textContainerInset = UIEdgeInsets(top: 104, left: 20, bottom: 120, right: 20)
        tv.textContainer.lineFragmentPadding = 0
        tv.autocorrectionType = .yes
        tv.autocapitalizationType = .sentences
        tv.spellCheckingType = .yes
        tv.smartDashesType = .yes
        tv.smartQuotesType = .yes
        tv.keyboardDismissMode = .interactive
        tv.inputAccessoryView = makeAccessoryBar(for: tv, theme: theme)
        applyTheme(tv)

        if autoFocus {
            DispatchQueue.main.async {
                tv.becomeFirstResponder()
                let end = tv.endOfDocument
                tv.selectedTextRange = tv.textRange(from: end, to: end)
            }
        }
        return tv
    }

    func updateUIView(_ tv: UITextView, context: Context) {
        if tv.text != text {
            let range = tv.selectedRange
            tv.text = text
            let clampedLoc = min(range.location, tv.text.count)
            tv.selectedRange = NSRange(location: clampedLoc, length: 0)
        }
        applyTheme(tv)
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    // MARK: - Keyboard accessory bar ("Done" button above keyboard)

    private func makeAccessoryBar(for tv: UITextView, theme: AppTheme) -> UIToolbar {
        let bar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        bar.sizeToFit()

        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(
            title: "Done",
            style: .done,
            target: tv,
            action: #selector(UIResponder.resignFirstResponder)
        )
        done.tintColor = UIColor(theme.accentColor)
        bar.items = [spacer, done]
        bar.tintColor = UIColor(theme.accentColor)

        // Match bar background to theme with a hairline separator above the keyboard
        let appearance = UIToolbarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(theme.surfaceColor).withAlphaComponent(0.95)
        appearance.shadowColor = UIColor(theme.textColor).withAlphaComponent(0.08)
        bar.standardAppearance = appearance
        bar.compactAppearance = appearance

        return bar
    }

    private func applyTheme(_ tv: UITextView) {
        tv.textColor = UIColor(theme.textColor)
        tv.tintColor = UIColor(theme.accentColor)
    }

    // MARK: - Coordinator

    final class Coordinator: NSObject, UITextViewDelegate {
        var parent: MinimalTextEditor
        init(_ p: MinimalTextEditor) { parent = p }

        func textViewDidChange(_ tv: UITextView) {
            let t = tv.text ?? ""
            parent.text = t
            parent.onTextChange?(t)
        }
    }
}

private final class FocusableTextView: UITextView {
    override var canBecomeFirstResponder: Bool { true }
}
