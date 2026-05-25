import SwiftUI

struct SearchableLanguagePicker: View {
    @Binding var selectedLanguage: String
    let languages: [String]
    @State private var searchText = ""
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var settings: AppSettings
    
    var filteredLanguages: [String] {
        if searchText.isEmpty {
            return languages
        } else {
            return languages.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.background.ignoresSafeArea()
                
                List {
                    ForEach(filteredLanguages, id: \.self) { language in
                        Button {
                            AppTheme.haptic(.light)
                            selectedLanguage = language
                            dismiss()
                        } label: {
                            HStack {
                                Text(language)
                                    .foregroundStyle(.white)
                                Spacer()
                                if selectedLanguage == language {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(AppTheme.Colors.primary)
                                        .font(.system(size: 14, weight: .bold))
                                }
                            }
                            .padding(.vertical, 8)
                        }
                        .listRowBackground(selectedLanguage == language ? AppTheme.Colors.surfaceHighlight.opacity(0.3) : AppTheme.Colors.surface)
                    }
                }
                .listStyle(.plain)
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            }
            .navigationTitle(Localization.string("deck_create_language_label", lang: settings.appLanguage))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(Localization.string("common_done", lang: settings.appLanguage)) {
                        dismiss()
                    }
                }
            }
        }
    }
}
