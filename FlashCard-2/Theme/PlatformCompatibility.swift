import SwiftUI

#if canImport(UIKit)
import UIKit

public typealias PlatformColor = UIColor
public typealias PlatformImage = UIImage

#elseif canImport(AppKit)
import AppKit

public typealias PlatformColor = NSColor
public typealias UIImage = NSImage

extension Image {
    init(uiImage image: UIImage) {
        self.init(nsImage: image)
    }
}

public enum UIKeyboardType {
    case `default`
    case emailAddress
}

extension View {
    func keyboardType(_ type: UIKeyboardType) -> some View {
        self
    }
}

public struct UIImpactFeedbackGenerator {
    public enum FeedbackStyle {
        case light, medium, heavy, soft, rigid
    }

    public init(style: FeedbackStyle) {}
    public func impactOccurred() {}
}

public struct UINotificationFeedbackGenerator {
    public enum FeedbackType {
        case success, warning, error
    }

    public init() {}
    public func notificationOccurred(_ type: FeedbackType) {}
}

public struct UIRectCorner: OptionSet {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let topLeft = UIRectCorner(rawValue: 1 << 0)
    public static let topRight = UIRectCorner(rawValue: 1 << 1)
    public static let bottomLeft = UIRectCorner(rawValue: 1 << 2)
    public static let bottomRight = UIRectCorner(rawValue: 1 << 3)
    public static let allCorners: UIRectCorner = [.topLeft, .topRight, .bottomLeft, .bottomRight]
}

#endif

extension PlatformColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64

        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
}

#if canImport(UIKit)
func presentShareMessage(_ message: String) {
    let activityVC = UIActivityViewController(activityItems: [message], applicationActivities: nil)

    if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene ?? UIApplication.shared.connectedScenes.first as? UIWindowScene,
       let rootVC = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController {

        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = rootVC.view
            popover.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }

        rootVC.present(activityVC, animated: true)
    }
}
#else
func presentShareMessage(_ message: String) {
    _ = message
}
#endif

#if os(macOS)
extension View {
    @ViewBuilder
    func navigationBarTitleDisplayMode(_ displayMode: NavigationBarItem.TitleDisplayMode) -> some View {
        self
    }
}
#endif