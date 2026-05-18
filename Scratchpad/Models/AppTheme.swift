import SwiftUI

enum AppTheme: String, CaseIterable, Codable {
    case light      = "Light"
    case dark       = "Dark"
    case warmPaper  = "Warm Paper"
    case midnight   = "Midnight"

    var background: Color {
        switch self {
        case .light:     return Color(red: 0.98, green: 0.98, blue: 0.99)
        case .dark:      return Color(red: 0.11, green: 0.11, blue: 0.13)
        case .warmPaper: return Color(red: 0.97, green: 0.94, blue: 0.87)
        case .midnight:  return Color(red: 0.05, green: 0.05, blue: 0.12)
        }
    }

    var surfaceColor: Color {
        switch self {
        case .light:     return Color.white
        case .dark:      return Color(red: 0.17, green: 0.17, blue: 0.20)
        case .warmPaper: return Color(red: 0.99, green: 0.97, blue: 0.92)
        case .midnight:  return Color(red: 0.10, green: 0.10, blue: 0.20)
        }
    }

    var textColor: Color {
        switch self {
        case .light:     return Color(red: 0.10, green: 0.10, blue: 0.12)
        case .dark:      return Color(red: 0.92, green: 0.92, blue: 0.94)
        case .warmPaper: return Color(red: 0.22, green: 0.18, blue: 0.12)
        case .midnight:  return Color(red: 0.88, green: 0.88, blue: 0.96)
        }
    }

    var subtleText: Color {
        switch self {
        case .light:     return Color(red: 0.55, green: 0.55, blue: 0.60)
        case .dark:      return Color(red: 0.50, green: 0.50, blue: 0.55)
        case .warmPaper: return Color(red: 0.52, green: 0.45, blue: 0.35)
        case .midnight:  return Color(red: 0.45, green: 0.45, blue: 0.60)
        }
    }

    var accentColor: Color {
        switch self {
        case .light:     return Color(red: 0.30, green: 0.55, blue: 1.00)
        case .dark:      return Color(red: 0.40, green: 0.65, blue: 1.00)
        case .warmPaper: return Color(red: 0.65, green: 0.42, blue: 0.18)
        case .midnight:  return Color(red: 0.55, green: 0.45, blue: 1.00)
        }
    }

    var urgentColor: Color {
        switch self {
        case .warmPaper: return Color(red: 0.85, green: 0.35, blue: 0.20)
        default:         return Color(red: 1.00, green: 0.38, blue: 0.38)
        }
    }

    var dividerColor: Color { textColor.opacity(0.08) }

    var preferredColorScheme: ColorScheme? {
        switch self {
        case .light, .warmPaper: return .light
        case .dark, .midnight:   return .dark
        }
    }

    var iconName: String {
        switch self {
        case .light:     return "sun.min"
        case .dark:      return "moon"
        case .warmPaper: return "doc.plaintext"
        case .midnight:  return "moon.stars"
        }
    }
}
