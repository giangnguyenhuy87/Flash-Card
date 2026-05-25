import SwiftUI

struct ChangePasswordView: View {
    @State private var oldPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var showPassword = false
    
    @EnvironmentObject var settings: AppSettings
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()
            
            VStack(spacing: 32) {
                VStack(alignment: .leading, spacing: 24) {
                    Text(Localization.string("profile_change_password", lang: settings.appLanguage))
                        .font(AppTheme.font(.title, weight: .black))
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                    
                    VStack(spacing: 20) {
                        SecureFieldGroup(label: Localization.string("profile_current_password", lang: settings.appLanguage), text: $oldPassword, showPassword: $showPassword)
                        SecureFieldGroup(label: Localization.string("profile_new_password", lang: settings.appLanguage), text: $newPassword, showPassword: $showPassword)
                        SecureFieldGroup(label: Localization.string("profile_confirm_password", lang: settings.appLanguage), text: $confirmPassword, showPassword: $showPassword)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        PasswordRequirementRow(text: Localization.string("profile_pwd_8_chars", lang: settings.appLanguage), isMet: newPassword.count >= 8)
                        PasswordRequirementRow(text: Localization.string("profile_pwd_letters_numbers", lang: settings.appLanguage), isMet: containsLetterAndNumber(newPassword))
                        PasswordRequirementRow(text: Localization.string("profile_pwd_match", lang: settings.appLanguage), isMet: !newPassword.isEmpty && newPassword == confirmPassword)
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                Button(action: {
                    if canSubmit {
                        AppTheme.notificationHaptic(.success)
                        dismiss()
                    }
                }) {
                    Text(Localization.string("profile_pwd_update", lang: settings.appLanguage))
                        .font(AppTheme.font(.headline, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(canSubmit ? AppTheme.Colors.primaryGradient : LinearGradient(colors: [AppTheme.Colors.surfaceHighlight], startPoint: .top, endPoint: .bottom))
                        .clipShape(Capsule())
                        .opacity(canSubmit ? 1.0 : 0.6)
                }
                .disabled(!canSubmit)
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
            .padding(.top, 20)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var canSubmit: Bool {
        !oldPassword.isEmpty && 
        newPassword.count >= 8 && 
        newPassword == confirmPassword && 
        containsLetterAndNumber(newPassword)
    }
    
    private func containsLetterAndNumber(_ string: String) -> Bool {
        let hasLetters = string.rangeOfCharacter(from: .letters) != nil
        let hasNumbers = string.rangeOfCharacter(from: .decimalDigits) != nil
        return hasLetters && hasNumbers
    }
}

struct SecureFieldGroup: View {
    let label: String
    @Binding var text: String
    @Binding var showPassword: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(AppTheme.font(.caption, weight: .bold))
                .foregroundStyle(AppTheme.Colors.textSecondary)
            
            ZStack(alignment: .trailing) {
                if showPassword {
                    TextField("", text: $text)
                        .font(AppTheme.font(.body))
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                } else {
                    SecureField("", text: $text)
                        .font(AppTheme.font(.body))
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                }
                
                Button(action: { showPassword.toggle() }) {
                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
            }
            .padding(16)
            .background(AppTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(AppTheme.Colors.surfaceHighlight, lineWidth: 1)
            )
        }
    }
}

struct PasswordRequirementRow: View {
    let text: String
    let isMet: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: isMet ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 14))
                .foregroundStyle(isMet ? AppTheme.Colors.success : AppTheme.Colors.textSecondary.opacity(0.3))
            
            Text(text)
                .font(AppTheme.font(.caption))
                .foregroundStyle(isMet ? AppTheme.Colors.textPrimary : AppTheme.Colors.textSecondary)
        }
    }
}

#Preview {
    NavigationStack {
        ChangePasswordView()
    }
}
