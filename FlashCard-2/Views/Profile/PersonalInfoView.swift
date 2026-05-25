import SwiftUI
import PhotosUI

struct PersonalInfoView: View {
    @State private var name: String = "Giang Nguyen Huy"
    @State private var email: String = "giang.nguyen@lumina.com"
    @State private var birthday: Date = Date()
    @State private var bio: String = "Đam mê học hỏi và khám phá tri thức mới. 💡"
    
    @EnvironmentObject var settings: AppSettings
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    // Profile Image Section covered in EditProfileView, 
                    // focusing here on the form data
                    
                    VStack(alignment: .leading, spacing: 24) {
                        sectionLabel(Localization.string("profile_basic_info", lang: settings.appLanguage))
                        
                        VStack(spacing: 20) {
                            CustomTextField(label: Localization.string("profile_full_name", lang: settings.appLanguage), text: $name, icon: "person.fill")
                            CustomTextField(label: Localization.string("profile_email", lang: settings.appLanguage), text: $email, icon: "envelope.fill", keyboardType: .emailAddress)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text(Localization.string("profile_birthday", lang: settings.appLanguage))
                                    .font(AppTheme.font(.caption, weight: .bold))
                                    .foregroundStyle(AppTheme.Colors.textSecondary)
                                
                                DatePicker("", selection: $birthday, displayedComponents: .date)
                                    .labelsHidden()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(16)
                                    .background(AppTheme.Colors.surface)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text(Localization.string("profile_bio", lang: settings.appLanguage))
                                    .font(AppTheme.font(.caption, weight: .bold))
                                    .foregroundStyle(AppTheme.Colors.textSecondary)
                                
                                TextEditor(text: $bio)
                                    .font(AppTheme.font(.body))
                                    .foregroundStyle(AppTheme.Colors.textPrimary)
                                    .padding(12)
                                    .frame(height: 100)
                                    .background(AppTheme.Colors.surface)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .scrollContentBackground(.hidden)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    Button(action: {
                        AppTheme.notificationHaptic(.success)
                        dismiss()
                    }) {
                        Text(Localization.string("common_save_changes", lang: settings.appLanguage))
                            .font(AppTheme.font(.headline, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(AppTheme.Colors.primaryGradient)
                            .clipShape(Capsule())
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
                .padding(.top, 20)
            }
        }
        .navigationTitle(Localization.string("profile_personal_info", lang: settings.appLanguage))
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(AppTheme.font(.subheadline, weight: .bold))
            .foregroundStyle(AppTheme.Colors.textSecondary)
    }
}

struct CustomTextField: View {
    let label: String
    @Binding var text: String
    var icon: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(AppTheme.font(.caption, weight: .bold))
                .foregroundStyle(AppTheme.Colors.textSecondary)
            
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundStyle(AppTheme.Colors.primary)
                TextField("", text: $text)
                    .font(AppTheme.font(.body))
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                    .keyboardType(keyboardType)
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

#Preview {
    NavigationStack {
        PersonalInfoView()
    }
}
