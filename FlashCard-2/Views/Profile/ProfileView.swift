import SwiftUI
import SwiftData
import PhotosUI

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var navManager: NavigationManager
    @EnvironmentObject var settings: AppSettings
    
    // Mock user data for UI demonstration
    @State private var userName = "Giang Nguyen Huy"
    @State private var userEmail = "giang.nguyen@lumina.com"
    private var joinDate: String {
        settings.appLanguage == "vi" ? "Tháng 1, 2024" : "Jan 2024"
    }
    @State private var isPremium = true
    
    // Avatar support
    @State private var avatarItem: PhotosPickerItem? = nil
    @State private var avatarImage: Image? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.background.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        // 1. Profile Header
                        profileHeader
                        
                        // 2. Stats & Achievements Card
                        achievementsSection
                        
                        // 3. Subscription Management
                        subscriptionCard
                        
                        // 4. Account Settings Section
                        VStack(alignment: .leading, spacing: 16) {
                            sectionLabel(Localization.string("profile_account", lang: settings.appLanguage))
                            
                            VStack(spacing: 0) {
                                NavigationLink(destination: PersonalInfoView().onAppear { navManager.isTabBarHidden = true }.onDisappear { navManager.isTabBarHidden = false }) {
                                    SettingsRow(icon: "person.fill", title: Localization.string("profile_personal_info", lang: settings.appLanguage), value: userName)
                                }
                                Divider().background(AppTheme.Colors.surfaceHighlight).padding(.leading, 56)
                                
                                NavigationLink(destination: PersonalInfoView().onAppear { navManager.isTabBarHidden = true }.onDisappear { navManager.isTabBarHidden = false }) {
                                    SettingsRow(icon: "envelope.fill", title: Localization.string("profile_email", lang: settings.appLanguage), value: userEmail)
                                }
                                Divider().background(AppTheme.Colors.surfaceHighlight).padding(.leading, 56)
                                
                                NavigationLink(destination: ChangePasswordView().onAppear { navManager.isTabBarHidden = true }.onDisappear { navManager.isTabBarHidden = false }) {
                                    SettingsRow(icon: "lock.fill", title: Localization.string("profile_change_password", lang: settings.appLanguage))
                                }
                            }
                            .background(AppTheme.Colors.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                        }
                        .padding(.horizontal, 24)
                        
                        // 5. System Settings & Apps
                        VStack(alignment: .leading, spacing: 16) {
                            sectionLabel(Localization.string("profile_app", lang: settings.appLanguage))
                            
                            VStack(spacing: 0) {
                                NavigationLink(destination: NotificationSettingsView().onAppear { navManager.isTabBarHidden = true }.onDisappear { navManager.isTabBarHidden = false }) {
                                    SettingsRow(icon: "bell.fill", title: Localization.string("settings_notif", lang: settings.appLanguage), color: .orange)
                                }
                                Divider().background(AppTheme.Colors.surfaceHighlight).padding(.leading, 56)
                                
                                NavigationLink(destination: LanguageSelectionView().onAppear { navManager.isTabBarHidden = true }.onDisappear { navManager.isTabBarHidden = false }) {
                                    SettingsRow(icon: "globe", title: Localization.string("settings_language", lang: settings.appLanguage), value: AppLanguage(rawValue: settings.appLanguage)?.name ?? "Tiếng Việt", color: .blue)
                                }
                                Divider().background(AppTheme.Colors.surfaceHighlight).padding(.leading, 56)
                                
                                NavigationLink(destination: QuickActionsSettingsView().onAppear { navManager.isTabBarHidden = true }.onDisappear { navManager.isTabBarHidden = false }) {
                                    SettingsRow(icon: "bolt.fill", title: Localization.string("home_quick_actions", lang: settings.appLanguage), color: .cyan)
                                }
                                Divider().background(AppTheme.Colors.surfaceHighlight).padding(.leading, 56)
                                
                                NavigationLink(destination: AppearanceSettingsView().onAppear { navManager.isTabBarHidden = true }.onDisappear { navManager.isTabBarHidden = false }) {
                                    SettingsRow(icon: "paintpalette.fill", title: Localization.string("settings_theme", lang: settings.appLanguage), color: AppTheme.Colors.secondary)
                                }
                            }
                            .background(AppTheme.Colors.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                        }
                        .padding(.horizontal, 24)
                        
                        // 6. Support & Privacy
                        VStack(alignment: .leading, spacing: 16) {
                            sectionLabel(Localization.string("profile_support", lang: settings.appLanguage))
                            
                            VStack(spacing: 0) {
                                NavigationLink(destination: FeedbackView().onAppear { navManager.isTabBarHidden = true }.onDisappear { navManager.isTabBarHidden = false }) {
                                    SettingsRow(icon: "heart.text.square.fill", title: Localization.string("settings_feedback", lang: settings.appLanguage), color: .pink)
                                }
                                Divider().background(AppTheme.Colors.surfaceHighlight).padding(.leading, 56)
                                
                                NavigationLink(destination: AppInfoDetailView(title: Localization.string("info_privacy_title", lang: settings.appLanguage), content: Localization.string("info_privacy_content", lang: settings.appLanguage)).onAppear { navManager.isTabBarHidden = true }.onDisappear { navManager.isTabBarHidden = false }) {
                                    SettingsRow(icon: "hand.raised.fill", title: Localization.string("info_privacy_title", lang: settings.appLanguage), color: .green)
                                }
                                Divider().background(AppTheme.Colors.surfaceHighlight).padding(.leading, 56)
                                
                                NavigationLink(destination: AppInfoDetailView(title: Localization.string("info_terms_title", lang: settings.appLanguage), content: Localization.string("info_terms_content", lang: settings.appLanguage)).onAppear { navManager.isTabBarHidden = true }.onDisappear { navManager.isTabBarHidden = false }) {
                                    SettingsRow(icon: "doc.text.fill", title: Localization.string("info_terms_title", lang: settings.appLanguage), color: .gray)
                                }
                                Divider().background(AppTheme.Colors.surfaceHighlight).padding(.leading, 56)
                                
                                NavigationLink(destination: AppInfoDetailView(title: Localization.string("info_about_title", lang: settings.appLanguage), content: Localization.string("info_about_content", lang: settings.appLanguage)).onAppear { navManager.isTabBarHidden = true }.onDisappear { navManager.isTabBarHidden = false }) {
                                    SettingsRow(icon: "info.circle.fill", title: Localization.string("info_about_title", lang: settings.appLanguage), color: .accentColor)
                                }
                            }
                            .background(AppTheme.Colors.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                        }
                        .padding(.horizontal, 24)
                        
                        // 7. Logout
                        Button(action: {
                            AppTheme.notificationHaptic(.warning)
                        }) {
                            Text(Localization.string("profile_logout", lang: settings.appLanguage))
                                .font(AppTheme.font(.headline, weight: .bold))
                                .foregroundStyle(AppTheme.Colors.error)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(AppTheme.Colors.error.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(AppTheme.Colors.error.opacity(0.2), lineWidth: 1)
                                )
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 120)
                    }
                    .padding(.top, 20)
                }
            }
            .navigationTitle(Localization.string("tab_profile", lang: settings.appLanguage))
            .navigationBarHidden(true)
        }
        .onChange(of: avatarItem) { old, newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self) {
                    if let uiImage = UIImage(data: data) {
                        avatarImage = Image(uiImage: uiImage)
                    }
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    private var profileHeader: some View {
        VStack(spacing: 16) {
            // Avatar with Glow & Badges
            PhotosPicker(selection: $avatarItem, matching: .images) {
                ZStack {
                    Circle()
                        .fill(AppTheme.Colors.primaryGradient)
                        .frame(width: 110, height: 110)
                        .blur(radius: 20)
                        .opacity(0.3)
                    
                    Circle()
                        .stroke(AppTheme.Colors.primaryGradient, lineWidth: 3)
                        .frame(width: 100, height: 100)
                    
                    Group {
                        if let avatarImage = avatarImage {
                            avatarImage
                                .resizable()
                                .scaledToFill()
                        } else {
                            Image(systemName: "person.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(.white)
                        }
                    }
                    .frame(width: 88, height: 88)
                    .background(AppTheme.Colors.surfaceHighlight)
                    .clipShape(Circle())
                }
                .overlay(alignment: .bottomTrailing) {
                    // Edit Capsule
                    ZStack {
                        Circle()
                            .fill(AppTheme.Colors.primary)
                            .frame(width: 32, height: 32)
                        Image(systemName: "camera.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(.white)
                    }
                    .offset(x: -2, y: -2)
                }
                .overlay(alignment: .topTrailing) {
                    // Plus Badge
                    if isPremium {
                        ZStack {
                            Circle()
                                .fill(AppTheme.Colors.accentYellow)
                                .frame(width: 28, height: 28)
                                .shadow(color: .black.opacity(0.3), radius: 4)
                            Image(systemName: "crown.fill")
                                .font(.system(size: 12))
                                .foregroundStyle(.black)
                        }
                        .offset(x: 5, y: 5)
                    }
                }
            }
            
            VStack(spacing: 4) {
                Text(userName)
                    .font(AppTheme.font(.title2, weight: .black))
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                
                let joinText = String(format: Localization.string("profile_join_date", lang: settings.appLanguage), joinDate)
                Text(joinText)
                    .font(AppTheme.font(.caption, weight: .medium))
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
        }
    }
    
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionLabel(Localization.string("profile_achievements", lang: settings.appLanguage))
            
            HStack(spacing: 12) {
                AchievementCard(title: Localization.string("home_streak", lang: settings.appLanguage), value: "7", unit: Localization.string("home_day", lang: settings.appLanguage), icon: "flame.fill", color: .orange)
                AchievementCard(title: Localization.string("home_mastered", lang: settings.appLanguage), value: "128", unit: Localization.string("home_card", lang: settings.appLanguage), icon: "book.fill", color: AppTheme.Colors.primary)
                AchievementCard(title: Localization.string("stats_accuracy", lang: settings.appLanguage), value: "92", unit: "%", icon: "target", color: .green)
            }
            .padding(.horizontal, 24)
        }
    }
    
    private var subscriptionCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionLabel(Localization.string("profile_membership", lang: settings.appLanguage))
            
            NavigationLink(destination: SubscriptionDetailView().onAppear { navManager.isTabBarHidden = true }.onDisappear { navManager.isTabBarHidden = false }) {
                HStack(spacing: 20) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(AppTheme.Colors.primaryGradient)
                            .frame(width: 56, height: 56)
                        
                        Image(systemName: "sparkles")
                            .font(.title2)
                            .foregroundStyle(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(isPremium ? Localization.string("profile_plus_member", lang: settings.appLanguage) : Localization.string("profile_upgrade_plus", lang: settings.appLanguage))
                            .font(AppTheme.font(.headline, weight: .bold))
                            .foregroundStyle(AppTheme.Colors.textPrimary)
                        
                        let subDetails = isPremium ? 
                            String(format: Localization.string("profile_annual_plan", lang: settings.appLanguage), "12/05/2024") : 
                            Localization.string("profile_unlimited_study", lang: settings.appLanguage)
                            
                        Text(subDetails)
                            .font(AppTheme.font(.caption))
                            .foregroundStyle(AppTheme.Colors.textSecondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption.bold())
                        .foregroundStyle(AppTheme.Colors.textSecondary.opacity(0.5))
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(AppTheme.Colors.surface)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(AppTheme.Colors.primary.opacity(0.3), lineWidth: 1)
                        )
                )
            }
            .padding(.horizontal, 24)
        }
    }
    
    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(AppTheme.font(.subheadline, weight: .bold))
            .foregroundStyle(AppTheme.Colors.textSecondary)
            .padding(.horizontal, 24)
    }
}

// MARK: - Components

struct AchievementCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(color)
            
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(value)
                        .font(AppTheme.font(.title3, weight: .black))
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                    Text(unit)
                        .font(AppTheme.font(.caption2, weight: .bold))
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
                
                Text(title)
                    .font(AppTheme.font(.caption2, weight: .medium))
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppTheme.Colors.surfaceHighlight, lineWidth: 1)
        )
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    var value: String? = nil
    var color: Color = AppTheme.Colors.textSecondary
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(color)
            }
            
            Text(title)
                .font(AppTheme.font(.body, weight: .medium))
                .foregroundStyle(AppTheme.Colors.textPrimary)
            
            Spacer()
            
            if let value = value {
                Text(value)
                    .font(AppTheme.font(.subheadline))
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
            
            Image(systemName: "chevron.right")
                .font(.caption.bold())
                .foregroundStyle(AppTheme.Colors.textSecondary.opacity(0.3))
        }
        .padding(16)
        .contentShape(Rectangle()) // Essential for full-row tap in NavigationLink
    }
}

#Preview {
    ProfileView()
        .environmentObject(NavigationManager())
}
