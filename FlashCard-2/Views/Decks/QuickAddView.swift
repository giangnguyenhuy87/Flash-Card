import SwiftUI

struct QuickAddView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var settings: AppSettings
    
    @State private var front: String = ""
    @State private var back: String = ""
    @State private var example: String = ""
    
    var termLang: String = ""
    var defLang: String = ""
    
    var onAdd: (String, String, String) -> Void
    
    var isValid: Bool {
        !front.trimmingCharacters(in: .whitespaces).isEmpty &&
        !back.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.background.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            // Front
                            VStack(alignment: .leading, spacing: 8) {
                                Text("\(Localization.string("deck_create_term_lang", lang: settings.appLanguage))\(termLang.isEmpty ? "" : " (\(termLang))")")
                                    .font(AppTheme.font(.caption, weight: .bold))
                                    .foregroundStyle(AppTheme.Colors.textSecondary)
                                
                                TextField("", text: $front)
                                    .font(AppTheme.font(.body))
                                    .padding()
                                    .background(AppTheme.Colors.surface)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(AppTheme.Colors.surfaceHighlight, lineWidth: 1)
                                    )
                            }
                            
                            // Back
                            VStack(alignment: .leading, spacing: 8) {
                                Text("\(Localization.string("deck_create_def_lang", lang: settings.appLanguage))\(defLang.isEmpty ? "" : " (\(defLang))")")
                                    .font(AppTheme.font(.caption, weight: .bold))
                                    .foregroundStyle(AppTheme.Colors.textSecondary)
                                
                                TextField("", text: $back)
                                    .font(AppTheme.font(.body))
                                    .padding()
                                    .background(AppTheme.Colors.surface)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(AppTheme.Colors.surfaceHighlight, lineWidth: 1)
                                    )
                            }
                            
                            // Example (New)
                            VStack(alignment: .leading, spacing: 8) {
                                Text(Localization.string("add_word_ex_label", lang: settings.appLanguage))
                                    .font(AppTheme.font(.caption, weight: .bold))
                                    .foregroundStyle(AppTheme.Colors.textSecondary)
                                
                                TextField("", text: $example, axis: .vertical)
                                    .lineLimit(2...4)
                                    .font(AppTheme.font(.body))
                                    .padding()
                                    .background(AppTheme.Colors.surface)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(AppTheme.Colors.surfaceHighlight, lineWidth: 1)
                                    )
                            }
                        }
                        .padding(24)
                    }
                    
                    Button {
                        onAdd(front, back, example)
                        front = ""
                        back = ""
                        example = ""
                        AppTheme.haptic(.medium)
                    } label: {
                        Text(Localization.string("deck_edit_add_card", lang: settings.appLanguage))
                            .font(AppTheme.font(.headline, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isValid ? AnyShapeStyle(AppTheme.Colors.primaryGradient) : AnyShapeStyle(AppTheme.Colors.surfaceHighlight))
                            .clipShape(Capsule())
                    }
                    .disabled(!isValid)
                    .padding(24)
                }
            }
            .navigationTitle(Localization.string("deck_add_manual", lang: settings.appLanguage))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(Localization.string("common_done", lang: settings.appLanguage)) {
                        dismiss()
                    }
                    .font(AppTheme.font(.headline, weight: .bold))
                }
            }
        }
    }
}
