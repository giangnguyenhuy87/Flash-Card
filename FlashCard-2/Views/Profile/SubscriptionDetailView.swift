import SwiftUI

struct SubscriptionDetailView: View {
    @EnvironmentObject var settings: AppSettings
    @Environment(\.dismiss) var dismiss
    @State private var selectedPlanIndex = 1 // 0: Monthly, 1: Yearly
    @State private var isProcessing = false
    @State private var showApplePaySheet = false
    
    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    // Header Image/Icon
                    VStack(spacing: 20) {
                        ZStack {
                            Circle()
                                .fill(AppTheme.Colors.primaryGradient)
                                .frame(width: 120, height: 120)
                                .blur(radius: 30)
                                .opacity(0.4)
                            
                            Image(systemName: "sparkles")
                                .font(.system(size: 60))
                                .foregroundStyle(AppTheme.Colors.primaryGradient)
                        }
                        
                        VStack(spacing: 8) {
                            Text(Localization.string("profile_plus_upgrade", lang: settings.appLanguage))
                                .font(AppTheme.font(.title, weight: .black))
                                .foregroundStyle(.white)
                            Text(Localization.string("profile_plus_tagline", lang: settings.appLanguage))
                                .font(AppTheme.font(.subheadline))
                                .foregroundStyle(AppTheme.Colors.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.top, 40)
                    
                    // Benefits List
                    VStack(alignment: .leading, spacing: 16) {
                        BenefitRow(icon: "infinity", title: Localization.string("profile_benefit_unlimited_title", lang: settings.appLanguage), subtitle: Localization.string("profile_benefit_unlimited_desc", lang: settings.appLanguage))
                        BenefitRow(icon: "eye.slash.fill", title: Localization.string("profile_benefit_ads_title", lang: settings.appLanguage), subtitle: Localization.string("profile_benefit_ads_desc", lang: settings.appLanguage))
                        BenefitRow(icon: "brain.head.profile", title: Localization.string("profile_benefit_srs_title", lang: settings.appLanguage), subtitle: Localization.string("profile_benefit_srs_desc", lang: settings.appLanguage))
                        BenefitRow(icon: "arrow.down.circle.fill", title: Localization.string("profile_benefit_offline_title", lang: settings.appLanguage), subtitle: Localization.string("profile_benefit_offline_desc", lang: settings.appLanguage))
                        BenefitRow(icon: "photo.stack.fill", title: Localization.string("profile_benefit_media_title", lang: settings.appLanguage), subtitle: Localization.string("profile_benefit_media_desc", lang: settings.appLanguage))
                    }
                    .padding(.horizontal, 24)
                    
                    // Pricing Cards
                    VStack(spacing: 16) {
                        PricingCard(title: Localization.string("profile_plan_monthly", lang: settings.appLanguage), 
                                   price: "$0.99", 
                                   period: "/mo", 
                                   isSelected: selectedPlanIndex == 0) {
                            withAnimation(.spring()) { selectedPlanIndex = 0 }
                        }
                        
                        PricingCard(title: Localization.string("profile_plan_yearly", lang: settings.appLanguage), 
                                   price: "$9.99", 
                                   period: "/yr", 
                                   subtitle: String(format: Localization.string("profile_plan_save", lang: settings.appLanguage), "20%"), 
                                   isSelected: selectedPlanIndex == 1) {
                            withAnimation(.spring()) { selectedPlanIndex = 1 }
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // Action Button
                    Button(action: {
                        AppTheme.haptic(.medium)
                        showApplePaySheet = true
                    }) {
                        HStack {
                            Text(!settings.hasUsedTrial ? Localization.string("profile_trial_start", lang: settings.appLanguage) : Localization.string("profile_subscribe", lang: settings.appLanguage))
                                .font(AppTheme.font(.headline, weight: .bold))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(AppTheme.Colors.primaryGradient)
                        .clipShape(Capsule())
                        .shadow(color: AppTheme.Colors.primary.opacity(0.4), radius: 15, x: 0, y: 8)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                    
                    Text(Localization.string("profile_subscription_disclaimer", lang: settings.appLanguage))
                        .font(AppTheme.font(.caption2))
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                        .padding(.bottom, 20)
                }
            }
            
            // Mock Apple Pay Sheet Overlay
            if showApplePaySheet {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture { if !isProcessing { showApplePaySheet = false } }
                
                VStack {
                    Spacer()
                    MockApplePaySheet(
                        planTitle: selectedPlanIndex == 0 ? Localization.string("profile_plan_monthly", lang: settings.appLanguage) : Localization.string("profile_plan_yearly", lang: settings.appLanguage),
                        price: selectedPlanIndex == 0 ? "$0.99" : "$9.99",
                        isTrial: !settings.hasUsedTrial,
                        isProcessing: $isProcessing,
                        onConfirm: {
                            isProcessing = true
                            // Simulate Apple Purchase
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                settings.isPremium = true
                                settings.hasUsedTrial = true
                                isProcessing = false
                                showApplePaySheet = false
                                AppTheme.notificationHaptic(.success)
                                dismiss()
                            }
                        }
                    )
                    .transition(.move(edge: .bottom))
                }
                .ignoresSafeArea()
            }
        }
        .navigationTitle(Localization.string("profile_membership", lang: settings.appLanguage))
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct MockApplePaySheet: View {
    let planTitle: String
    let price: String
    let isTrial: Bool
    @Binding var isProcessing: Bool
    let onConfirm: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Apple Pay Header
            HStack {
                Image(systemName: "applelogo")
                    .font(.title3)
                Text("Pay")
                    .font(AppTheme.font(.title3, weight: .semibold))
            }
            .padding(.top, 20)
            .padding(.bottom, 30)
            
            // App Info
            HStack(spacing: 15) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppTheme.Colors.primaryGradient)
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text("L")
                            .font(AppTheme.font(.title2, weight: .black))
                            .foregroundStyle(.white)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("LuminaCards Plus")
                        .font(.headline)
                    Text(planTitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 20)
            
            Divider().padding(.horizontal, 30)
            
            // Payment Detail
            VStack(spacing: 15) {
                HStack {
                    Text("Account")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("giang.nguyen@icloud.com")
                }
                
                HStack {
                    Text("Payment Method")
                        .foregroundStyle(.secondary)
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: "creditcard.fill")
                        Text("MasterCard (•••• 1234)")
                    }
                }
                
                HStack {
                    Text(isTrial ? "Trial period" : "Total")
                        .foregroundStyle(.secondary)
                        .fontWeight(.bold)
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text(isTrial ? "7 Days Free" : price)
                            .fontWeight(.bold)
                        if isTrial {
                            Text("then \(price)/period")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .font(.subheadline)
            .padding(.horizontal, 30)
            .padding(.vertical, 20)
            
            // Action
            if isProcessing {
                ProgressView()
                    .padding(.vertical, 30)
            } else {
                Button(action: {
                    AppTheme.haptic(.heavy)
                    onConfirm()
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: "faceid")
                            .font(.system(size: 40))
                        Text("Double Click to Pay")
                            .font(AppTheme.font(.caption, weight: .semibold))
                            .textCase(.uppercase)
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 30)
                    .background(Color.black)
                }
            }
        }
        .background(Color(uiColor: .systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .shadow(radius: 20)
    }
}

struct BenefitRow: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(AppTheme.Colors.surfaceHighlight)
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundStyle(AppTheme.Colors.primary)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppTheme.font(.headline, weight: .bold))
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                Text(subtitle)
                    .font(AppTheme.font(.caption))
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct PricingCard: View {
    let title: String
    let price: String
    let period: String
    var subtitle: String? = nil
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(AppTheme.font(.headline, weight: .bold))
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(AppTheme.font(.caption2, weight: .black))
                            .foregroundStyle(AppTheme.Colors.primary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(AppTheme.Colors.primary.opacity(0.1))
                            .clipShape(Capsule())
                    }
                }
                
                Spacer()
                
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(price)
                        .font(AppTheme.font(.title3, weight: .black))
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                    Text(period)
                        .font(AppTheme.font(.caption, weight: .medium))
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? AppTheme.Colors.primary : AppTheme.Colors.surfaceHighlight)
                    .padding(.leading, 12)
            }
            .padding(20)
            .background(AppTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(isSelected ? AppTheme.Colors.primary : AppTheme.Colors.surfaceHighlight, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    NavigationStack {
        SubscriptionDetailView()
    }
}
