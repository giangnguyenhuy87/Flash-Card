import SwiftUI

struct FeedbackView: View {
    @EnvironmentObject var settings: AppSettings
    @Environment(\.dismiss) private var dismiss
    @State private var feedbackType: FeedbackType = .general
    @State private var message: String = ""
    @State private var rating: Int = 0
    @State private var isSubmitting = false
    @State private var showingSuccess = false
    
    enum FeedbackType: String, CaseIterable, Identifiable {
        case bug = "Báo lỗi"
        case feature = "Yêu cầu tính năng"
        case general = "Góp ý chung"
        case layout = "Giao diện"
        
        var id: String { self.rawValue }
        var localizedName: String {
            switch self {
            case .bug: return Localization.string("feedback_bug", lang: "vi") // Base key
            case .feature: return Localization.string("feedback_feature", lang: "vi")
            case .general: return Localization.string("feedback_general", lang: "vi")
            case .layout: return Localization.string("feedback_layout", lang: "vi")
            }
        }
        
        func localizedName(lang: String) -> String {
            switch self {
            case .bug: return Localization.string("feedback_bug", lang: lang)
            case .feature: return Localization.string("feedback_feature", lang: lang)
            case .general: return Localization.string("feedback_general", lang: lang)
            case .layout: return Localization.string("feedback_layout", lang: lang)
            }
        }
        var icon: String {
            switch self {
            case .bug: return "ant.fill"
            case .feature: return "star.bubble.fill"
            case .general: return "message.fill"
            case .layout: return "paintpalette.fill"
            }
        }
    }
    
    var isValid: Bool {
        !message.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()
            
            if showingSuccess {
                successOverlay
                    .transition(.scale.combined(with: .opacity))
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        // Header info
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(AppTheme.Colors.primary.opacity(0.1))
                                    .frame(width: 80, height: 80)
                                Image(systemName: "heart.text.square.fill")
                                    .font(.system(size: 36))
                                    .foregroundStyle(AppTheme.Colors.primaryGradient)
                            }
                            
                            Text(Localization.string("settings_feedback", lang: settings.appLanguage))
                                .font(AppTheme.font(.title2, weight: .black))
                                .foregroundStyle(AppTheme.Colors.textPrimary)
                            
                            Text(Localization.string("feedback_success_msg", lang: settings.appLanguage)) // Using a simpler description for now as placeholder
                                .font(AppTheme.font(.subheadline))
                                .foregroundStyle(AppTheme.Colors.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        .padding(.top, 20)
                        
                        // Rating Section
                        VStack(spacing: 16) {
                            Text(Localization.string("feedback_rating_question", lang: settings.appLanguage))
                                .font(AppTheme.font(.headline, weight: .bold))
                                .foregroundStyle(AppTheme.Colors.textPrimary)
                            
                            HStack(spacing: 12) {
                                ForEach(1...5, id: \.self) { index in
                                    Button(action: {
                                        AppTheme.haptic(.light)
                                        withAnimation(.spring(response: 0.3)) {
                                            rating = index
                                        }
                                    }) {
                                        Image(systemName: index <= rating ? "star.fill" : "star")
                                            .font(.system(size: 32))
                                            .foregroundStyle(index <= rating ? AppTheme.Colors.accentYellow : AppTheme.Colors.surfaceHighlight)
                                    }
                                }
                            }
                        }
                        .padding(24)
                        .background(AppTheme.Colors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(AppTheme.Colors.surfaceHighlight, lineWidth: 1)
                        )
                        .padding(.horizontal, 24)
                        
                        // Feedback Form
                        VStack(alignment: .leading, spacing: 20) {
                            // Topic Selection
                            VStack(alignment: .leading, spacing: 12) {
                                Text(Localization.string("feedback_topic_label", lang: settings.appLanguage))
                                    .font(AppTheme.font(.caption, weight: .bold))
                                    .foregroundStyle(AppTheme.Colors.textSecondary)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(FeedbackType.allCases) { type in
                                            Button(action: {
                                                AppTheme.haptic(.light)
                                                feedbackType = type
                                            }) {
                                                HStack(spacing: 8) {
                                                    Image(systemName: type.icon)
                                                    Text(type.localizedName(lang: settings.appLanguage))
                                                }
                                                .font(AppTheme.font(.subheadline, weight: .semibold))
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 10)
                                                .background(
                                                    feedbackType == type 
                                                    ? AppTheme.Colors.primaryGradient 
                                                    : LinearGradient(colors: [AppTheme.Colors.surfaceHighlight], startPoint: .leading, endPoint: .trailing)
                                                )
                                                .foregroundStyle(feedbackType == type ? .white : AppTheme.Colors.textPrimary)
                                                .clipShape(Capsule())
                                            }
                                        }
                                    }
                                }
                            }
                            
                            // Message field
                            VStack(alignment: .leading, spacing: 12) {
                                TextField(Localization.string("feedback_placeholder", lang: settings.appLanguage), text: $message, axis: .vertical)
                                    .font(AppTheme.font(.body))
                                    .foregroundStyle(AppTheme.Colors.textPrimary)
                                    .lineLimit(5...10)
                                    .padding(20)
                                    .background(AppTheme.Colors.surface)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(AppTheme.Colors.surfaceHighlight, lineWidth: 1)
                                    )
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        // Submit Button
                        Button(action: submitFeedback) {
                            HStack {
                                if isSubmitting {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text(Localization.string("feedback_submit", lang: settings.appLanguage))
                                        .font(AppTheme.font(.headline, weight: .bold))
                                }
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(isValid ? AppTheme.Colors.primaryGradient : LinearGradient(colors: [AppTheme.Colors.surfaceHighlight], startPoint: .leading, endPoint: .trailing))
                            .clipShape(Capsule())
                            .shadow(color: isValid ? AppTheme.Colors.primary.opacity(0.3) : .clear, radius: 10, y: 5)
                        }
                        .disabled(!isValid || isSubmitting)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 50)
                    }
                }
            }
        }
        .navigationTitle(Localization.string("feedback_title", lang: settings.appLanguage))
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var successOverlay: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(AppTheme.Colors.success.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(AppTheme.Colors.success)
            }
            
            VStack(spacing: 12) {
                Text(Localization.string("feedback_thanks", lang: settings.appLanguage))
                    .font(AppTheme.font(.title2, weight: .black))
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                
                Text(Localization.string("feedback_success_msg", lang: settings.appLanguage))
                    .font(AppTheme.font(.subheadline))
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Button(action: { dismiss() }) {
                Text(Localization.string("common_close", lang: settings.appLanguage))
                    .font(AppTheme.font(.headline, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 60)
                    .padding(.vertical, 16)
                    .background(AppTheme.Colors.primaryGradient)
                    .clipShape(Capsule())
            }
        }
    }
    
    private func submitFeedback() {
        guard isValid else { return }
        
        isSubmitting = true
        AppTheme.haptic(.medium)
        
        // Mocking an API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isSubmitting = false
            withAnimation(.spring()) {
                showingSuccess = true
            }
            AppTheme.notificationHaptic(.success)
        }
    }
}

#Preview {
    NavigationStack {
        FeedbackView()
    }
}
