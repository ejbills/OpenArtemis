import Foundation
import SwiftUI
import Defaults

extension UIColor {
    func darker(by percentage: CGFloat) -> UIColor {
        return self.adjust(by: -abs(percentage))
    }

    private func adjust(by percentage: CGFloat) -> UIColor {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        guard self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return self
        }
        return UIColor(red: max(red + percentage/100, 0.0),
                       green: max(green + percentage/100, 0.0),
                       blue: max(blue + percentage/100, 0.0),
                       alpha: alpha)
    }
}


extension Color {
    static let artemisAccent = Defaults[.accentColor]
    
    func darker(by percentage: CGFloat) -> Color {
        let baseUIColor = UIColor(self)
        return Color(baseUIColor.darker(by: percentage))
    }
}

struct BackgroundModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    @Default(.darkBackground) private var darkBackground
    @Default(.lightBackground) private var lightBackground
    @Default(.preferredThemeMode) private var preferredThemeMode
    let isDarker: Bool
    let isListRow: Bool

    private func calculateBackgroundColor() -> Color {
        var backgroundColor: Color

        switch preferredThemeMode.id {
        case 0:
            backgroundColor = colorScheme == .dark ? darkBackground : lightBackground
        case 1:
            backgroundColor = lightBackground
        case 2:
            backgroundColor = darkBackground
        default:
            backgroundColor = Color(uiColor: UIColor.systemBackground)
        }

        if isDarker {
            backgroundColor = backgroundColor.darker(by: 3)
        }

        return backgroundColor
    }

    func body(content: Content) -> some View {
        Group {
            if isListRow {
                content.listRowBackground(calculateBackgroundColor())
            } else {
                content.background(calculateBackgroundColor())
            }
        }
    }
}

extension View {
    func themedBackground(isDarker: Bool = false, isListRow: Bool = false) -> some View {
        self.modifier(BackgroundModifier(isDarker: isDarker, isListRow: isListRow))
    }
}
