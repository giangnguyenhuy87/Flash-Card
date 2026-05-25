import SwiftUI
import SwiftData

struct CreateFolderView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var settings: AppSettings
    
    var parentFolder: Folder? = nil
    
    @State private var name = ""
    @State private var emoji = "📁"
    @State private var colorHex = "8B5CF6"
    
    let emojis = ["📁", "🗂️", "💼", "🏢", "🏠", "🎒", "🎓", "🌟"]
    let colors = ["6366F1", "EC4899", "14B8A6", "F59E0B", "EF4444", "8B5CF6"]
    
    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.background.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        // Minimalist Preview
                        VStack(spacing: 16) {
                            Text(emoji)
                                .font(.system(size: 80))
                            
                            Text(name.isEmpty ? Localization.string("folder_create_preview_ph", lang: settings.appLanguage) : name)
                                .font(AppTheme.font(.title3, weight: .bold))
                                .foregroundStyle(.white)
                        }
                        .padding(.top, 40)
                        
                        // Input
                        VStack(alignment: .leading, spacing: 12) {
                            Text(Localization.string("folder_create_name_label", lang: settings.appLanguage))
                                .font(AppTheme.font(.caption, weight: .bold))
                                .foregroundStyle(AppTheme.Colors.textSecondary)
                            
                            TextField("", text: $name, prompt: Text(Localization.string("folder_create_name_ph", lang: settings.appLanguage)).foregroundColor(.white.opacity(0.3)))
                                .font(AppTheme.font(.body))
                                .foregroundStyle(.white)
                                .padding(16)
                                .background(AppTheme.Colors.surface)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .padding(.horizontal, 24)
                        
                        // Emoji Picker (Subtle)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(emojis, id: \.self) { e in
                                    Button(action: { emoji = e }) {
                                        Text(e)
                                            .font(.title2)
                                            .frame(width: 50, height: 50)
                                            .background(emoji == e ? AppTheme.Colors.primary.opacity(0.1) : Color.clear)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(emoji == e ? AppTheme.Colors.primary : Color.clear, lineWidth: 2))
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                    }
                }
                
                // Create Button
                VStack {
                    Spacer()
                    Button(action: {
                        let folder = Folder(name: name, emoji: emoji, colorHex: colorHex)
                        if let parent = parentFolder {
                            folder.parentFolder = parent
                        }
                        modelContext.insert(folder)
                        dismiss()
                    }) {
                        Text(Localization.string("folder_create_button", lang: settings.appLanguage))
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
            .navigationTitle(Localization.string("folder_create_new_title", lang: settings.appLanguage))
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
