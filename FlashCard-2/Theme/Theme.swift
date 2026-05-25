import SwiftUI
#if canImport(AppKit)
import AppKit
#endif

enum AppTheme {
    private static func dynamicColor(lightHex: String, darkHex: String) -> Color {
#if canImport(UIKit)
        Color(PlatformColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? PlatformColor(hex: darkHex) : PlatformColor(hex: lightHex)
        })
#else
        Color(NSColor(name: NSColor.Name("AppThemeDynamicColor")) { appearance in
            appearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua ? NSColor(hex: darkHex) : NSColor(hex: lightHex)
        })
#endif
    }

    // MARK: - Colors
    struct Colors {
        // Backgrounds
        static var background: Color {
            dynamicColor(lightHex: "FFFFFF", darkHex: "000000")
        }
        
        static var surface: Color {
            dynamicColor(lightHex: "F2F2F7", darkHex: "1C1C1E")
        }
        
        static var surfaceHighlight: Color {
            dynamicColor(lightHex: "E5E5EA", darkHex: "2C2C2E")
        }
        
        // Vibrant Accents
        static let primary = Color(hex: "6D28D9") // Electric Purple
        static let primaryGradient = LinearGradient(colors: [Color(hex: "8B5CF6"), Color(hex: "6D28D9")], startPoint: .topLeading, endPoint: .bottomTrailing)
        
        static let secondary = Color(hex: "EC4899") // Hot Pink
        static let secondaryGradient = LinearGradient(colors: [Color(hex: "F472B6"), Color(hex: "DB2777")], startPoint: .topLeading, endPoint: .bottomTrailing)
        
        static let accentTeal = Color(hex: "14B8A6") // Teal
        static let accentYellow = Color(hex: "FBBF24") // Amber
        
        // Semantic
        static let success = Color(hex: "10B981") // Emerald
        static let warning = Color(hex: "F59E0B") // Amber
        static let error = Color(hex: "EF4444") // Red
        
        static var textPrimary: Color {
            dynamicColor(lightHex: "000000", darkHex: "FFFFFF")
        }
        
        static var textSecondary: Color {
            dynamicColor(lightHex: "6B7280", darkHex: "9CA3AF")
        }
    }
    
    // MARK: - Layout
    struct Layout {
        static let cornerRadius: CGFloat = 32.0 // Super rounded
        static let smallCornerRadius: CGFloat = 16.0
        static let padding: CGFloat = 24.0
    }
    
    // MARK: - Typography
    static func font(_ style: Font.TextStyle, weight: Font.Weight = .regular, italic: Bool = false) -> Font {
        // Apply scaling factor from AppSettings
        let scale = AppSettings.shared.fontSizeMultiplier
        
        let customSize: CGFloat
        switch style {
        case .largeTitle:
            customSize = 28 * scale
        case .title:
            customSize = 24 * scale
        case .title2:
            customSize = 20 * scale
        case .title3:
            customSize = 18 * scale
        case .headline:
            customSize = 15 * scale
        case .subheadline:
            customSize = 13 * scale
        case .body:
            customSize = 15 * scale
        case .callout:
            customSize = 14 * scale
        case .caption:
            customSize = 11 * scale
        case .caption2:
            customSize = 10 * scale
        default:
            customSize = 15 * scale
        }
        
        var font = Font.system(size: customSize, weight: weight, design: italic ? .default : .rounded)
        if italic {
            font = font.italic()
        }
        return font
    }
    
    // Icon sizes
    static let iconSmall: CGFloat = 14
    static let iconMedium: CGFloat = 18
    static let iconLarge: CGFloat = 24
    static let iconXLarge: CGFloat = 32
    
    // MARK: - Haptics
    static func haptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    static func notificationHaptic(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    // MARK: - Standard Components
    struct Header: View {
        let title: String
        let action: () -> Void
        
        var body: some View {
            HStack(alignment: .center) {
                Text(title)
                    .font(AppTheme.font(.title2, weight: .black))
                    .foregroundStyle(.white)
                
                Spacer()
                
                Button(action: {
                    haptic(.medium)
                    action()
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(AppTheme.Colors.primaryGradient)
                        .clipShape(Circle())
                        .shadow(color: AppTheme.Colors.primary.opacity(0.3), radius: 10, x: 0, y: 5)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
        }
    }

    // MARK: - Button Styles
    struct LinkButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
                .opacity(configuration.isPressed ? 0.7 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
        }
    }
}

// MARK: - View Modifiers

struct GenZCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius)
                    .fill(AppTheme.Colors.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius)
                    .stroke(LinearGradient(colors: [.white.opacity(0.1), .clear], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.3), radius: 15, x: 0, y: 10)
    }
}

extension View {
    func genZCardStyle() -> some View {
        self.modifier(GenZCard())
    }
    
    func mainGradient() -> some View {
        self.foregroundStyle(AppTheme.Colors.primaryGradient)
    }
    
    func linkButtonStyle() -> some View {
        self.buttonStyle(AppTheme.LinkButtonStyle())
    }
}

// Keep the Hex Helper
extension Color {
    init(hex: String) {
        self.init(PlatformColor(hex: hex))
    }

    func toHex() -> String? {
#if canImport(UIKit)
        let platformColor = PlatformColor(self)
        guard let components = platformColor.cgColor.components, components.count >= 3 else { return nil }
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        return String(format: "#%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
#else
        return nil
#endif
    }
}

// MARK: - Shapes
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        #if canImport(UIKit)
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
        #else
        return RoundedRectangle(cornerRadius: radius).path(in: rect)
        #endif
    }
}
