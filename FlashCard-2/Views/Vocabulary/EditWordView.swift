import SwiftUI
import SwiftData

struct EditWordView: View {
    @Bindable var card: Card
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var settings: AppSettings
    
    @State private var front: String
    @State private var back: String
    @State private var pronunciation: String
    @State private var example: String
    @State private var notes: String
    @State private var showingAISuggestions = false
    
    init(card: Card) {
        self.card = card
        _front = State(initialValue: card.front)
        _back = State(initialValue: card.back)
        _pronunciation = State(initialValue: card.pronunciation ?? "")
        _example = State(initialValue: card.example ?? "")
        _notes = State(initialValue: card.notes ?? "")
    }
    
    var isValid: Bool {
        !front.trimmingCharacters(in: .whitespaces).isEmpty &&
        !back.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.background.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Preview Card
                        previewCard
                        
                        // Form Fields
                        VStack(spacing: 20) {
                            // Front (Word)
                            FormField(
                                title: Localization.string("add_word_front_label", lang: settings.appLanguage),
                                placeholder: Localization.string("add_word_front_ph", lang: settings.appLanguage),
                                text: $front,
                                icon: "textformat.abc"
                            )
                            
                            // Back (Meaning)
                            FormField(
                                title: Localization.string("add_word_back_label", lang: settings.appLanguage),
                                placeholder: Localization.string("add_word_back_ph", lang: settings.appLanguage),
                                text: $back,
                                icon: "text.bubble"
                            )
                            
                            // Pronunciation
                            FormField(
                                title: Localization.string("add_word_pron_label", lang: settings.appLanguage),
                                placeholder: Localization.string("add_word_pron_ph", lang: settings.appLanguage),
                                text: $pronunciation,
                                icon: "speaker.wave.2"
                            )
                            
                            // Example
                            FormField(
                                title: Localization.string("add_word_ex_label", lang: settings.appLanguage),
                                placeholder: "VD: Hello, how are you?",
                                text: $example,
                                icon: "quote.bubble",
                                isMultiline: true
                            )
                            
                            // Notes
                            FormField(
                                title: Localization.string("add_word_notes_label", lang: settings.appLanguage),
                                placeholder: Localization.string("add_word_notes_ph", lang: settings.appLanguage),
                                text: $notes,
                                icon: "note.text",
                                isMultiline: true
                            )
                        }
                        .padding(.horizontal, 24)
                        
                        // AI Suggestions (Optional)
                        aiSuggestionsSection
                    }
                    .padding(.top, 24)
                    .padding(.bottom, 120)
                }
                
                // Save Button (Floating)
                VStack {
                    Spacer()
                    
                    Button(action: saveWord) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text(Localization.string("common_done", lang: settings.appLanguage))
                        }
                        .font(AppTheme.font(.headline, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            isValid
                                ? AppTheme.Colors.primaryGradient
                                : LinearGradient(colors: [AppTheme.Colors.surfaceHighlight], startPoint: .leading, endPoint: .trailing)
                        )
                        .clipShape(Capsule())
                        .shadow(
                            color: isValid ? AppTheme.Colors.primary.opacity(0.4) : Color.clear,
                            radius: 15,
                            x: 0,
                            y: 8
                        )
                    }
                    .disabled(!isValid)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle(Localization.string("common_edit", lang: settings.appLanguage))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(Localization.string("common_cancel", lang: settings.appLanguage)) {
                        dismiss()
                    }
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                }
            }
        }
    }
    
    // MARK: - Preview Card
    
    private var previewCard: some View {
        VStack(spacing: 16) {
            Text(Localization.string("add_word_preview", lang: settings.appLanguage))
                .font(AppTheme.font(.caption, weight: .semibold))
                .foregroundStyle(AppTheme.Colors.textSecondary)
            
            VStack(spacing: 12) {
                // Front
                VStack(spacing: 8) {
                    Text(front.isEmpty ? Localization.string("add_word_front_label", lang: settings.appLanguage) : front)
                        .font(AppTheme.font(.title2, weight: .black))
                        .foregroundStyle(.white)
                    
                    if !pronunciation.isEmpty {
                        HStack(spacing: 6) {
                            Image(systemName: "speaker.wave.2.fill")
                                .font(.caption)
                            Text(pronunciation)
                                .font(AppTheme.font(.subheadline))
                        }
                        .foregroundStyle(AppTheme.Colors.primary)
                    }
                }
                
                Divider()
                    .background(AppTheme.Colors.surfaceHighlight)
                
                // Back
                VStack(spacing: 8) {
                    Text(back.isEmpty ? Localization.string("add_word_back_label", lang: settings.appLanguage) : back)
                        .font(AppTheme.font(.headline))
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                    
                    if !example.isEmpty {
                        Text(example)
                            .font(AppTheme.font(.caption))
                            .foregroundStyle(AppTheme.Colors.textSecondary.opacity(0.7))
                            .italic()
                            .multilineTextAlignment(.center)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(AppTheme.Colors.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.1), Color.clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
            .shadow(color: Color.black.opacity(0.2), radius: 15, x: 0, y: 8)
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - AI Suggestions
    
    private var aiSuggestionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Button(action: {
                AppTheme.haptic(.light)
                showingAISuggestions.toggle()
            }) {
                HStack {
                    Image(systemName: "sparkles")
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "F59E0B"), Color(hex: "EC4899")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text(Localization.string("add_word_ai_title", lang: settings.appLanguage))
                        .font(AppTheme.font(.subheadline, weight: .semibold))
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    Image(systemName: showingAISuggestions ? "chevron.up" : "chevron.down")
                        .font(.caption.bold())
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
                .padding(16)
                .background(AppTheme.Colors.surface)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            
            if showingAISuggestions {
                VStack(spacing: 12) {
                    AISuggestionCard(
                        title: Localization.string("add_word_ex_label", lang: settings.appLanguage),
                        suggestion: "Hello! Nice to meet you.",
                        icon: "quote.bubble"
                    ) {
                        example = "Hello! Nice to meet you."
                    }
                    
                    AISuggestionCard(
                        title: Localization.string("add_word_pron_label", lang: settings.appLanguage),
                        suggestion: "/həˈloʊ/",
                        icon: "speaker.wave.2"
                    ) {
                        pronunciation = "/həˈloʊ/"
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.horizontal, 24)
        .animation(.spring(response: 0.3), value: showingAISuggestions)
    }
    
    // MARK: - Actions
    
    func saveWord() {
        guard isValid else { return }
        
        AppTheme.haptic(.medium)
        
        card.front = front.trimmingCharacters(in: .whitespaces)
        card.back = back.trimmingCharacters(in: .whitespaces)
        card.pronunciation = pronunciation.isEmpty ? nil : pronunciation
        card.example = example.isEmpty ? nil : example
        card.notes = notes.isEmpty ? nil : notes
        
        dismiss()
    }
}
