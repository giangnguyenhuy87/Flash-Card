import SwiftUI
import Combine

class AppSettings: ObservableObject {
    @Published var selectedTheme: Int {
        didSet {
            UserDefaults.standard.set(selectedTheme, forKey: "selectedTheme")
        }
    }
    
    @Published var fontSizeMultiplier: Double {
        didSet {
            UserDefaults.standard.set(fontSizeMultiplier, forKey: "fontSizeMultiplier")
        }
    }
    
    @Published var usePremiumColors: Bool {
        didSet {
            UserDefaults.standard.set(usePremiumColors, forKey: "usePremiumColors")
        }
    }
    
    @Published var appLanguage: String {
        didSet {
            UserDefaults.standard.set(appLanguage, forKey: "appLanguage")
        }
    }
    
    @Published var hasUsedTrial: Bool {
        didSet {
            UserDefaults.standard.set(hasUsedTrial, forKey: "hasUsedTrial")
        }
    }
    
    @Published var isPremium: Bool {
        didSet {
            UserDefaults.standard.set(isPremium, forKey: "isPremium")
        }
    }
    
    static let shared = AppSettings()
    
    init() {
        self.selectedTheme = UserDefaults.standard.integer(forKey: "selectedTheme")
        
        let storedFontSize = UserDefaults.standard.double(forKey: "fontSizeMultiplier")
        self.fontSizeMultiplier = storedFontSize == 0 ? 1.0 : storedFontSize
        
        if UserDefaults.standard.object(forKey: "usePremiumColors") == nil {
            self.usePremiumColors = true
        } else {
            self.usePremiumColors = UserDefaults.standard.bool(forKey: "usePremiumColors")
        }

        self.appLanguage = UserDefaults.standard.string(forKey: "appLanguage") ?? "vi"
        self.hasUsedTrial = UserDefaults.standard.bool(forKey: "hasUsedTrial")
        self.isPremium = UserDefaults.standard.bool(forKey: "isPremium")
    }
    
    var colorScheme: ColorScheme? {
        switch selectedTheme {
        case 0: return .dark
        case 1: return .light
        default: return nil
        }
    }
}
