import SwiftUI
import SwiftData

struct CreateDeckView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var settings: AppSettings
    var targetFolder: Folder? = nil
    
    @State private var deckName = ""
    @State private var termLanguage = "Tiếng Anh"
    @State private var definitionLanguage = "Tiếng Việt"
    @State private var selectedEmoji = "📚"
    @State private var selectedColor = "6366F1"
    @State private var showEmojiPicker = false
    @State private var showingImport = false
    @State private var cardsToImport: [Card] = []
    @State private var showingManualAdd = false
    @State private var showingTermLangPicker = false
    @State private var showingDefLangPicker = false
    @State private var manualTerm = ""
    @State private var manualDefinition = ""
    
    let languages = ["Tiếng Việt", "Tiếng Anh", "Tiếng Nhật", "Tiếng Hàn", "Tiếng Trung", "Tiếng Pháp", "Tiếng Đức", "Tiếng Tây Ban Nha", "Tiếng Ý", "Tiếng Nga"]
    let emojiOptions = ["📚", "🇯🇵", "🇬🇧", "🇰🇷", "🇫🇷", "🇪🇸", "🇨🇳", "🇩🇪", "💡", "🎯", "🚀", "⭐️", "🔥", "💎", "🎨", "🎵"]
    let colorOptions = [
        "6366F1", // Indigo
        "EC4899", // Pink
        "F59E0B", // Amber
        "10B981", // Emerald
        "3B82F6", // Blue
        "8B5CF6", // Violet
        "EF4444"  // Red
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // 1. Icon & Name Section
                        VStack(spacing: 24) {
                            // Icon Picker
                            Button {
                                AppTheme.haptic(.light)
                                showEmojiPicker = true
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(Color(hex: selectedColor).opacity(0.2))
                                        .frame(width: 100, height: 100)
                                    
                                    Text(selectedEmoji)
                                        .font(.system(size: 50))
                                }
                                .overlay(
                                    Circle()
                                        .stroke(Color(hex: selectedColor).opacity(0.5), lineWidth: 2)
                                )
                                .shadow(color: Color(hex: selectedColor).opacity(0.3), radius: 15)
                            }
                            
                            // Name Input
                            VStack(alignment: .leading, spacing: 12) {
                                Text(Localization.string("deck_create_name_label", lang: settings.appLanguage))
                                    .font(AppTheme.font(.caption, weight: .bold))
                                    .foregroundStyle(AppTheme.Colors.textSecondary)
                                    .padding(.leading, 4)
                                
                                TextField("", text: $deckName, prompt: Text(Localization.string("deck_create_name_ph", lang: settings.appLanguage)).foregroundColor(.white.opacity(0.3)))
                                    .font(AppTheme.font(.title3, weight: .bold))
                                    .foregroundStyle(.white)
                                    .padding(20)
                                    .background(AppTheme.Colors.surface)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(AppTheme.Colors.surfaceHighlight, lineWidth: 1)
                                    )
                            }
                        }
                        .padding(.horizontal)
                        
                        // 2. Language & Style Customization
                        VStack(spacing: 24) {
                            // Languages UI
                            VStack(alignment: .leading, spacing: 12) {
                                Text(Localization.string("deck_create_language_label", lang: settings.appLanguage))
                                    .font(AppTheme.font(.subheadline, weight: .semibold))
                                    .foregroundStyle(AppTheme.Colors.textSecondary)
                                
                                HStack(spacing: 12) {
                                    Button {
                                        showingTermLangPicker = true
                                    } label: {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(Localization.string("deck_create_term_lang", lang: settings.appLanguage))
                                                .font(AppTheme.font(.caption2, weight: .semibold))
                                                .foregroundStyle(AppTheme.Colors.textSecondary)
                                            Text(termLanguage)
                                                .font(AppTheme.font(.body, weight: .bold))
                                                .foregroundStyle(.white)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(12)
                                        .background(AppTheme.Colors.surfaceHighlight)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                    
                                    Image(systemName: "arrow.right")
                                        .font(.caption.bold())
                                        .foregroundStyle(AppTheme.Colors.textSecondary)
                                    
                                    Button {
                                        showingDefLangPicker = true
                                    } label: {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(Localization.string("deck_create_def_lang", lang: settings.appLanguage))
                                                .font(AppTheme.font(.caption2, weight: .semibold))
                                                .foregroundStyle(AppTheme.Colors.textSecondary)
                                            Text(definitionLanguage)
                                                .font(AppTheme.font(.body, weight: .bold))
                                                .foregroundStyle(.white)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(12)
                                        .background(AppTheme.Colors.surfaceHighlight)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                }
                            }
                            
                            // Colors
                            VStack(alignment: .leading, spacing: 12) {
                                Text(Localization.string("deck_create_color_label", lang: settings.appLanguage))
                                    .font(AppTheme.font(.subheadline, weight: .semibold))
                                    .foregroundStyle(AppTheme.Colors.textSecondary)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(colorOptions, id: \.self) { color in
                                            Circle()
                                                .fill(Color(hex: color))
                                                .frame(width: 32, height: 32)
                                                .overlay(
                                                    Circle()
                                                        .stroke(.white, lineWidth: selectedColor == color ? 3 : 0)
                                                )
                                                .onTapGesture {
                                                    AppTheme.haptic(.light)
                                                    withAnimation(.spring(response: 0.3)) {
                                                        selectedColor = color
                                                    }
                                                }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // 3. Initial Cards Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text(Localization.string("deck_create_preview", lang: settings.appLanguage))
                                .font(AppTheme.font(.subheadline, weight: .bold))
                                .foregroundStyle(AppTheme.Colors.textSecondary)
                            
                            if cardsToImport.isEmpty {
                                emptyCardsPlaceholder
                            } else {
                                cardsPreviewList
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 32)
                }
            }
            .navigationTitle(Localization.string("deck_create_new_title", lang: settings.appLanguage))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(Localization.string("common_cancel", lang: settings.appLanguage)) { dismiss() }
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(Localization.string("deck_create_button", lang: settings.appLanguage)) {
                        createDeck()
                    }
                    .font(AppTheme.font(.body, weight: .bold))
                    .foregroundStyle(AppTheme.Colors.primary)
                    .disabled(deckName.isEmpty)
                }
            }
            .sheet(isPresented: $showEmojiPicker) {
                EmojiPickerSheet(selectedEmoji: $selectedEmoji, options: emojiOptions)
            }
            .sheet(isPresented: $showingImport) {
                VocabularyImportView { cards in
                    cardsToImport.append(contentsOf: cards)
                }
            }
            .sheet(isPresented: $showingManualAdd) {
                QuickAddView(termLang: termLanguage, defLang: definitionLanguage) { front, back, example in
                    cardsToImport.append(Card(front: front, back: back, example: example))
                }
            }
            .sheet(isPresented: $showingTermLangPicker) {
                SearchableLanguagePicker(selectedLanguage: $termLanguage, languages: languages)
            }
            .sheet(isPresented: $showingDefLangPicker) {
                SearchableLanguagePicker(selectedLanguage: $definitionLanguage, languages: languages)
            }
        }
    }
    
    private var emptyCardsPlaceholder: some View {
        VStack(spacing: 20) {
            HStack(spacing: 16) {
                Button {
                    AppTheme.haptic(.medium)
                    showingManualAdd = true
                } label: {
                    Label(Localization.string("deck_add_manual", lang: settings.appLanguage), systemImage: "plus.circle.fill")
                        .font(AppTheme.font(.subheadline, weight: .bold))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(AppTheme.Colors.surfaceHighlight)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
                
                Button {
                    AppTheme.haptic(.medium)
                    showingImport = true
                } label: {
                    Label(Localization.string("deck_smart_import", lang: settings.appLanguage), systemImage: "sparkles")
                        .font(AppTheme.font(.subheadline, weight: .bold))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(AppTheme.Colors.primaryGradient)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(32)
        .background(AppTheme.Colors.surface.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(AppTheme.Colors.surfaceHighlight, style: StrokeStyle(lineWidth: 1, dash: [5]))
        )
    }
    
    private var cardsPreviewList: some View {
        VStack(spacing: 12) {
            ForEach(cardsToImport.prefix(3)) { card in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(card.front)
                            .font(AppTheme.font(.body, weight: .bold))
                            .lineLimit(1)
                        
                        HStack(spacing: 8) {
                            Text(card.back)
                                .font(AppTheme.font(.caption))
                                .foregroundStyle(AppTheme.Colors.textSecondary)
                                .lineLimit(1)
                            
                            if let ex = card.example, !ex.isEmpty {
                                Image(systemName: "text.quote")
                                    .font(.system(size: 10))
                                    .foregroundStyle(AppTheme.Colors.primary.opacity(0.6))
                            }
                        }
                    }
                    Spacer()
                }
                .padding(16)
                .background(AppTheme.Colors.surface)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            if cardsToImport.count > 3 {
                Text("+ \(cardsToImport.count - 3) cards more")
                    .font(AppTheme.font(.caption))
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
            
            Button {
                cardsToImport.removeAll()
            } label: {
                Text(Localization.string("common_clear_all", lang: settings.appLanguage))
                    .font(AppTheme.font(.caption, weight: .bold))
                    .foregroundStyle(.red.opacity(0.8))
            }
            .padding(.top, 4)
        }
    }
    
    private func createDeck() {
        AppTheme.notificationHaptic(.success)
        let newDeck = Deck(
            title: deckName.trimmingCharacters(in: .whitespaces),
            emoji: selectedEmoji,
            language: termLanguage,
            colorHex: selectedColor
        )
        newDeck.termLanguage = termLanguage
        newDeck.definitionLanguage = definitionLanguage
        
        if let folder = targetFolder {
            newDeck.folder = folder
            folder.decks.append(newDeck)
        }
        
        for card in cardsToImport {
            newDeck.cards.append(Card(front: card.front, back: card.back, example: card.example))
        }
        
        modelContext.insert(newDeck)
        dismiss()
    }
}

struct EmojiPickerSheet: View {
    @Binding var selectedEmoji: String
    let options: [String]
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.background.ignoresSafeArea()
                
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 20) {
                        ForEach(options, id: \.self) { emoji in
                            Button {
                                selectedEmoji = emoji
                                dismiss()
                            } label: {
                                Text(emoji)
                                    .font(.system(size: 40))
                                    .frame(width: 60, height: 60)
                                    .background(selectedEmoji == emoji ? AppTheme.Colors.primary.opacity(0.2) : AppTheme.Colors.surface)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(selectedEmoji == emoji ? AppTheme.Colors.primary : Color.clear, lineWidth: 2)
                                    )
                            }
                        }
                    }
                    .padding(24)
                }
            }
            .navigationTitle("Select Icon")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium])
    }
}
