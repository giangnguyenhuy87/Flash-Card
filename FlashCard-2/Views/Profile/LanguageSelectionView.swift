import SwiftUI

struct LanguageSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var settings: AppSettings
    
    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.Colors.primary.opacity(0.1))
                            .frame(width: 80, height: 80)
                        Image(systemName: "globe.asia.australia.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(AppTheme.Colors.primaryGradient)
                    }
                    
                    Text(Localization.string("settings_language", lang: settings.appLanguage))
                        .font(AppTheme.font(.title2, weight: .black))
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                    
                    Text(Localization.string("settings_language_desc", lang: settings.appLanguage))
                        .font(AppTheme.font(.subheadline))
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .padding(.top, 20)
                
                // Language List
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        ForEach(AppLanguage.allCases) { lang in
                            Button(action: {
                                AppTheme.haptic(.medium)
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                    settings.appLanguage = lang.rawValue
                                }
                            }) {
                                HStack(spacing: 20) {
                                    Text(lang.flag)
                                        .font(.title)
                                    
                                    Text(lang.name)
                                        .font(AppTheme.font(.body, weight: .bold))
                                        .foregroundStyle(AppTheme.Colors.textPrimary)
                                    
                                    Spacer()
                                    
                                    if settings.appLanguage == lang.rawValue {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.title3)
                                            .foregroundStyle(AppTheme.Colors.primary)
                                            .transition(.scale.combined(with: .opacity))
                                    }
                                }
                                .padding(20)
                                .background(AppTheme.Colors.surface)
                                .clipShape(RoundedRectangle(cornerRadius: 24))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24)
                                        .stroke(settings.appLanguage == lang.rawValue ? AppTheme.Colors.primary.opacity(0.5) : AppTheme.Colors.surfaceHighlight, lineWidth: 2)
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 120) // Extra space for the fixed button
                }
            }
            
            // Bottom Action Button - Fixed
            VStack {
                Spacer()
                Button(action: { dismiss() }) {
                    Text(Localization.string("common_done", lang: settings.appLanguage))
                        .font(AppTheme.font(.headline, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(AppTheme.Colors.primaryGradient)
                        .clipShape(Capsule())
                        .shadow(color: AppTheme.Colors.primary.opacity(0.3), radius: 10, y: 5)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 34) // Safe area padding
                .background(
                    AppTheme.Colors.background
                        .mask(LinearGradient(colors: [.clear, .black], startPoint: .top, endPoint: .bottom))
                        .ignoresSafeArea()
                )
            }
        }
        .navigationTitle(Localization.string("settings_language", lang: settings.appLanguage))
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        LanguageSelectionView()
            .environmentObject(AppSettings.shared)
    }
}
