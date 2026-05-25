import SwiftUI

struct QuickActionsSettingsView: View {
    @State private var shakeToReport = true
    @State private var doubleTapToFlip = true
    @State private var swipeNavigation = true
    @State private var hapticFeedback = true
    
    @EnvironmentObject var settings: AppSettings
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    VStack(alignment: .leading, spacing: 24) {
                        headerSection
                        
                        VStack(spacing: 0) {
                            ToggleRow(title: Localization.string("quick_double_tap", lang: settings.appLanguage), subtitle: Localization.string("quick_double_tap_desc", lang: settings.appLanguage), isOn: $doubleTapToFlip, icon: "hand.tap.fill", color: .blue)
                            Divider().background(AppTheme.Colors.surfaceHighlight).padding(.leading, 56)
                            ToggleRow(title: Localization.string("quick_swipe", lang: settings.appLanguage), subtitle: Localization.string("quick_swipe_desc", lang: settings.appLanguage), isOn: $swipeNavigation, icon: "arrow.left.and.right", color: .green)
                            Divider().background(AppTheme.Colors.surfaceHighlight).padding(.leading, 56)
                            ToggleRow(title: Localization.string("quick_haptic", lang: settings.appLanguage), subtitle: Localization.string("quick_haptic_desc", lang: settings.appLanguage), isOn: $hapticFeedback, icon: "iphone.radiowaves.left.and.right", color: .orange)
                        }
                        .background(AppTheme.Colors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        
                        sectionLabel(Localization.string("common_advanced", lang: settings.appLanguage))
                        
                        VStack(spacing: 0) {
                            ToggleRow(title: Localization.string("quick_shake", lang: settings.appLanguage), subtitle: Localization.string("quick_shake_desc", lang: settings.appLanguage), isOn: $shakeToReport, icon: "hand.raised.fill", color: .purple)
                        }
                        .background(AppTheme.Colors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        
                        infoBox
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.top, 20)
            }
        }
        .navigationTitle(Localization.string("home_quick_actions", lang: settings.appLanguage))
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(Localization.string("home_quick_actions", lang: settings.appLanguage))
                .font(AppTheme.font(.title, weight: .black))
                .foregroundStyle(AppTheme.Colors.textPrimary)
            Text(Localization.string("quick_header_desc", lang: settings.appLanguage))
                .font(AppTheme.font(.subheadline))
                .foregroundStyle(AppTheme.Colors.textSecondary)
        }
    }
    
    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(AppTheme.font(.subheadline, weight: .bold))
            .foregroundStyle(AppTheme.Colors.textSecondary)
    }
    
    private var infoBox: some View {
        HStack(spacing: 16) {
            Image(systemName: "info.circle.fill")
                .foregroundStyle(AppTheme.Colors.primary)
            Text(Localization.string("quick_info_text", lang: settings.appLanguage))
                .font(AppTheme.font(.caption))
                .foregroundStyle(AppTheme.Colors.textSecondary)
        }
        .padding(20)
        .background(AppTheme.Colors.primary.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    NavigationStack {
        QuickActionsSettingsView()
    }
}
