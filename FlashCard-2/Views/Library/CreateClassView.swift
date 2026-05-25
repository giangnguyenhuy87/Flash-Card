import SwiftUI
import SwiftData

struct CreateClassView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var settings: AppSettings
    
    @State private var name = ""
    @State private var teacherName = ""
    
    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty && 
        !teacherName.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.background.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        // Minimalist Preview
                        VStack(spacing: 16) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 30)
                                    .fill(AppTheme.Colors.surface)
                                    .frame(width: 120, height: 120)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 30)
                                            .stroke(AppTheme.Colors.surfaceHighlight, lineWidth: 1)
                                    )
                                
                                Image(systemName: "person.3.fill")
                                    .font(.system(size: 40))
                                    .foregroundStyle(AppTheme.Colors.primaryGradient)
                            }
                            
                            Text(name.isEmpty ? Localization.string("class_create_new_title", lang: settings.appLanguage) : name)
                                .font(AppTheme.font(.title3, weight: .bold))
                                .foregroundStyle(AppTheme.Colors.textPrimary)
                        }
                        .padding(.top, 40)
                        
                        VStack(spacing: 24) {
                            // Class Name
                            VStack(alignment: .leading, spacing: 12) {
                                Text(Localization.string("class_create_name_label", lang: settings.appLanguage))
                                    .font(AppTheme.font(.caption, weight: .bold))
                                    .foregroundStyle(AppTheme.Colors.textSecondary)
                                
                                TextField("", text: $name, prompt: Text(Localization.string("class_create_name_ph", lang: settings.appLanguage)).foregroundColor(.white.opacity(0.3)))
                                    .font(AppTheme.font(.body))
                                    .foregroundStyle(AppTheme.Colors.textPrimary)
                                    .padding(16)
                                    .background(AppTheme.Colors.surface)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                            
                            // Teacher Name
                            VStack(alignment: .leading, spacing: 12) {
                                Text(Localization.string("class_create_teacher_label", lang: settings.appLanguage))
                                    .font(AppTheme.font(.caption, weight: .bold))
                                    .foregroundStyle(AppTheme.Colors.textSecondary)
                                
                                TextField("", text: $teacherName, prompt: Text(Localization.string("class_create_teacher_ph", lang: settings.appLanguage)).foregroundColor(.white.opacity(0.3)))
                                    .font(AppTheme.font(.body))
                                    .foregroundStyle(AppTheme.Colors.textPrimary)
                                    .padding(16)
                                    .background(AppTheme.Colors.surface)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                            
                            Text(Localization.string("class_create_auto_code_msg", lang: settings.appLanguage))
                                .font(AppTheme.font(.caption))
                                .foregroundStyle(AppTheme.Colors.textSecondary)
                                .padding(.top, 8)
                        }
                        .padding(.horizontal, 24)
                    }
                    .padding(.bottom, 100)
                }
                
                // Create Button
                VStack {
                    Spacer()
                    Button(action: {
                        let classRoom = ClassRoom(name: name, teacherName: teacherName)
                        modelContext.insert(classRoom)
                        dismiss()
                    }) {
                        Text(Localization.string("class_create_button", lang: settings.appLanguage))
                            .font(AppTheme.font(.headline, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(isValid ? AppTheme.Colors.primaryGradient : LinearGradient(colors: [AppTheme.Colors.surfaceHighlight], startPoint: .leading, endPoint: .trailing))
                            .clipShape(Capsule())
                    }
                    .disabled(!isValid)
                    .padding(24)
                }
            }
            .navigationTitle(Localization.string("class_create_new_title", lang: settings.appLanguage))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(Localization.string("common_cancel", lang: settings.appLanguage)) { dismiss() }
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
            }
        }
    }
}
