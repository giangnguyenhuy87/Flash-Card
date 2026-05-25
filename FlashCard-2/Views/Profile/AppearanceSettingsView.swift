import SwiftUI

struct AppearanceSettingsView: View {
    @EnvironmentObject var settings: AppSettings
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    VStack(alignment: .leading, spacing: 24) {
                        headerSection
                        
                        // Theme Selection
                        VStack(alignment: .leading, spacing: 16) {
                            sectionLabel(Localization.string("profile_display_mode", lang: settings.appLanguage))
                            
                            HStack(spacing: 12) {
                                ThemeButton(title: Localization.string("profile_theme_dark", lang: settings.appLanguage), icon: "moon.fill", isSelected: settings.selectedTheme == 0) { 
                                    settings.selectedTheme = 0 
                                }
                                ThemeButton(title: Localization.string("profile_theme_light", lang: settings.appLanguage), icon: "sun.max.fill", isSelected: settings.selectedTheme == 1) { 
                                    settings.selectedTheme = 1 
                                }
                                ThemeButton(title: Localization.string("profile_theme_auto", lang: settings.appLanguage), icon: "circle.lefthalf.filled", isSelected: settings.selectedTheme == 2) { 
                                    settings.selectedTheme = 2 
                                }
                            }
                        }
                        
                        // Customization
                        VStack(alignment: .leading, spacing: 16) {
                            sectionLabel(Localization.string("profile_personalize", lang: settings.appLanguage))
                            
                            VStack(spacing: 0) {
                                ToggleRow(title: Localization.string("profile_premium_colors", lang: settings.appLanguage), subtitle: Localization.string("profile_premium_colors_desc", lang: settings.appLanguage), isOn: $settings.usePremiumColors, icon: "paintpalette.fill", color: AppTheme.Colors.secondary)
                                
                                Divider().background(AppTheme.Colors.surfaceHighlight).padding(.leading, 56)
                                
                                VStack(alignment: .leading, spacing: 16) {
                                    HStack {
                                        Image(systemName: "textformat.size")
                                            .foregroundStyle(AppTheme.Colors.textSecondary)
                                            .font(.system(size: 16, weight: .bold))
                                            .frame(width: 40)
                                        
                                        Text(Localization.string("profile_font_size", lang: settings.appLanguage))
                                            .font(AppTheme.font(.body, weight: .bold))
                                            .foregroundStyle(.white)
                                    }
                                    
                                    Slider(value: $settings.fontSizeMultiplier, in: 0.8...1.4, step: 0.1)
                                        .tint(AppTheme.Colors.primary)
                                        .padding(.horizontal, 16)
                                    
                                    HStack {
                                        Text("A").font(.system(size: 12))
                                        Spacer()
                                        Text("A").font(.system(size: 24))
                                    }
                                    .foregroundStyle(AppTheme.Colors.textSecondary)
                                }
                                .padding(16)
                            }
                            .background(AppTheme.Colors.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                        }
                        
                        previewSection
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.top, 20)
                .padding(.bottom, 150)
            }
        }
        .navigationTitle(Localization.string("settings_theme", lang: settings.appLanguage))
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(Localization.string("settings_theme", lang: settings.appLanguage))
                .font(AppTheme.font(.title, weight: .black))
                .foregroundStyle(.white)
            Text(Localization.string("profile_appearance_desc", lang: settings.appLanguage))
                .font(AppTheme.font(.subheadline))
                .foregroundStyle(AppTheme.Colors.textSecondary)
        }
    }
    
    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(AppTheme.font(.subheadline, weight: .bold))
            .foregroundStyle(AppTheme.Colors.textSecondary)
    }
    
    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionLabel(Localization.string("deck_create_preview", lang: settings.appLanguage))
            
            VStack(spacing: 12) {
                Text("LuminaCards")
                    .font(AppTheme.font(.title3, weight: .black))
                    .foregroundStyle(.white)
                
                Text(Localization.string("profile_appearance_preview_text", lang: settings.appLanguage))
                    .font(AppTheme.font(.body))
                    .scaleEffect(settings.fontSizeMultiplier)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(32)
            .background(AppTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(AppTheme.Colors.primary.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

struct ThemeButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(AppTheme.font(.caption, weight: .bold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(isSelected ? AppTheme.Colors.primary.opacity(0.15) : AppTheme.Colors.surface)
            .foregroundStyle(isSelected ? AppTheme.Colors.primary : AppTheme.Colors.textSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? AppTheme.Colors.primary : AppTheme.Colors.surfaceHighlight, lineWidth: 2)
            )
        }
    }
}

#Preview {
    NavigationStack {
        AppearanceSettingsView()
    }
}
