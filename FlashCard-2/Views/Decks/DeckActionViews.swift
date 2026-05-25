import SwiftUI
import SwiftData
import PhotosUI

struct EditDeckView: View {
    @Bindable var deck: Deck
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var settings: AppSettings
    @State private var showingSettings = false
    @State private var showingImport = false
    @State private var showingTermLangPicker = false
    @State private var showingDefLangPicker = false
    @FocusState private var focusedField: FocusField?
    
    enum FocusField: Hashable {
        case title
        case cardFront(UUID)
        case cardBack(UUID)
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                AppTheme.Colors.background.ignoresSafeArea()
                
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 24) {
                            // Title Section
                            VStack(alignment: .leading, spacing: 8) {
                                Text(Localization.string("deck_edit_title_label", lang: settings.appLanguage))
                                    .font(AppTheme.font(.caption, weight: .bold))
                                    .foregroundStyle(.white.opacity(0.7))
                                    .padding(.leading, 4)
                                
                                TextField("", text: $deck.title, prompt: Text(Localization.string("deck_edit_title_ph", lang: settings.appLanguage)).foregroundColor(.white.opacity(0.3)))
                                    .font(AppTheme.font(.title3, weight: .bold))
                                    .foregroundStyle(.white)
                                    .focused($focusedField, equals: .title)
                                    .padding(16)
                                    .background(AppTheme.Colors.surfaceHighlight)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                            .padding(.horizontal)
                            .padding(.top, 16)
                            .id("title")
                            
                            // Language Selection Section
                            VStack(alignment: .leading, spacing: 12) {
                                Text(Localization.string("deck_create_language_label", lang: settings.appLanguage))
                                    .font(AppTheme.font(.caption, weight: .bold))
                                    .foregroundStyle(.white.opacity(0.7))
                                    .padding(.leading, 4)
                                
                                HStack(spacing: 12) {
                                    // Term Language Button
                                    Button {
                                        showingTermLangPicker = true
                                    } label: {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(Localization.string("deck_create_term_lang", lang: settings.appLanguage))
                                                .font(AppTheme.font(.caption2, weight: .semibold))
                                                .foregroundStyle(AppTheme.Colors.textSecondary)
                                            Text(deck.termLanguage)
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
                                    
                                    // Def Language Button
                                    Button {
                                        showingDefLangPicker = true
                                    } label: {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(Localization.string("deck_create_def_lang", lang: settings.appLanguage))
                                                .font(AppTheme.font(.caption2, weight: .semibold))
                                                .foregroundStyle(AppTheme.Colors.textSecondary)
                                            Text(deck.definitionLanguage)
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
                            .padding(.horizontal)
                            
                            // Cards Section
                            VStack(alignment: .leading, spacing: 16) {
                                Text(String(format: Localization.string("deck_edit_cards_label", lang: settings.appLanguage), deck.cards.count))
                                    .font(AppTheme.font(.caption, weight: .bold))
                                    .foregroundStyle(.white.opacity(0.7))
                                    .padding(.horizontal, 20)
                                
                                LazyVStack(spacing: 16) {
                                    ForEach(Array(deck.cards.enumerated()), id: \.element.id) { index, card in
                                        EditCardRow(
                                            card: card,
                                            index: index + 1,
                                            total: deck.cards.count,
                                            focusedField: $focusedField
                                        ) {
                                            if let idx = deck.cards.firstIndex(where: { $0.id == card.id }) {
                                                deck.cards.remove(at: idx)
                                            }
                                        }
                                        .id(card.id)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.bottom, 160)
                    }
                }
                
                VStack(spacing: 0) {
                    if focusedField != nil {
                        keyboardToolbar
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(AppTheme.Colors.surface.opacity(0.95))
                            .background(.ultraThinMaterial)
                            .overlay(
                                Rectangle()
                                    .fill(Color.white.opacity(0.1))
                                    .frame(height: 1),
                                alignment: .top
                            )
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    
                    if focusedField == nil {
                        floatingAddButton
                            .padding(.bottom, 20)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
            .navigationTitle(Localization.string("deck_edit_title", lang: settings.appLanguage))
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingSettings) {
                DeckSettingsSheet(deck: deck)
            }
            .sheet(isPresented: $showingImport) {
                VocabularyImportView(deck: deck)
            }
            .sheet(isPresented: $showingTermLangPicker) {
                SearchableLanguagePicker(selectedLanguage: $deck.termLanguage, languages: ["Tiếng Việt", "Tiếng Anh", "Tiếng Nhật", "Tiếng Hàn", "Tiếng Trung", "Tiếng Pháp", "Tiếng Đức", "Tiếng Tây Ban Nha", "Tiếng Ý", "Tiếng Nga"])
            }
            .sheet(isPresented: $showingDefLangPicker) {
                SearchableLanguagePicker(selectedLanguage: $deck.definitionLanguage, languages: ["Tiếng Việt", "Tiếng Anh", "Tiếng Nhật", "Tiếng Hàn", "Tiếng Trung", "Tiếng Pháp", "Tiếng Đức", "Tiếng Tây Ban Nha", "Tiếng Ý", "Tiếng Nga"])
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        AppTheme.haptic(.light)
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        AppTheme.notificationHaptic(.success)
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(AppTheme.Colors.primary)
                    }
                }
            }
        }
    }
    
    private var floatingAddButton: some View {
        VStack(spacing: 12) {
            Button {
                AppTheme.haptic(.medium)
                withAnimation(.spring()) {
                    let newCard = Card(front: "", back: "")
                    deck.cards.append(newCard)
                    focusedField = .cardFront(newCard.id)
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .bold))
                    Text(Localization.string("deck_edit_add_card", lang: settings.appLanguage))
                        .font(AppTheme.font(.headline, weight: .bold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(AppTheme.Colors.primaryGradient)
                .clipShape(Capsule())
                .shadow(color: AppTheme.Colors.primary.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            
            Button {
                AppTheme.haptic(.medium)
                showingImport = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "square.and.arrow.down.on.square.fill")
                        .font(.system(size: 16))
                    Text(Localization.string("deck_import_title", lang: settings.appLanguage))
                        .font(AppTheme.font(.subheadline, weight: .bold))
                }
                .foregroundStyle(AppTheme.Colors.primary)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(AppTheme.Colors.primary.opacity(0.1))
                .clipShape(Capsule())
            }
        }
    }
    
    private var currentFocusedCard: Card? {
        switch focusedField {
        case .cardFront(let id), .cardBack(let id):
            return deck.cards.first(where: { $0.id == id })
        default:
            return nil
        }
    }
    
    private var isFrontFocused: Bool {
        if case .cardFront = focusedField { return true }
        return false
    }
    
    private var keyboardToolbar: some View {
        HStack(spacing: 0) {
            HStack(spacing: 12) {
                Button {
                    AppTheme.haptic(.medium)
                    withAnimation(.spring()) {
                        let newCard = Card(front: "", back: "")
                        deck.cards.append(newCard)
                        focusedField = .cardFront(newCard.id)
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(AppTheme.Colors.primary)
                }
                
                if let card = currentFocusedCard {
                    Divider()
                        .frame(height: 20)
                        .background(Color.white.opacity(0.2))
                    
                    HStack(spacing: 12) {
                        Button(action: {
                            AppTheme.haptic(.light)
                            if isFrontFocused { card.isFrontBold.toggle() }
                            else { card.isBackBold.toggle() }
                        }) {
                            Image(systemName: "bold")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle((isFrontFocused ? card.isFrontBold : card.isBackBold) == true ? AppTheme.Colors.primary : .white)
                                .frame(width: 32, height: 32)
                                .background(Color.white.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                        
                        Button(action: {
                            AppTheme.haptic(.light)
                            if isFrontFocused { card.isFrontItalic.toggle() }
                            else { card.isBackItalic.toggle() }
                        }) {
                            Image(systemName: "italic")
                                .font(.system(size: 16))
                                .foregroundStyle((isFrontFocused ? card.isFrontItalic : card.isBackItalic) == true ? AppTheme.Colors.primary : .white)
                                .frame(width: 32, height: 32)
                                .background(Color.white.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                        
                        Button(action: {
                            AppTheme.haptic(.light)
                            if isFrontFocused { card.isFrontUnderline.toggle() }
                            else { card.isBackUnderline.toggle() }
                        }) {
                            Image(systemName: "underline")
                                .font(.system(size: 16))
                                .foregroundStyle((isFrontFocused ? card.isFrontUnderline : card.isBackUnderline) == true ? AppTheme.Colors.primary : .white)
                                .frame(width: 32, height: 32)
                                .background(Color.white.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                        
                        ColorPicker("", selection: Binding(
                            get: {
                                Color(hex: isFrontFocused ? card.frontColor : card.backColor)
                            },
                            set: { newColor in
                                if isFrontFocused { card.frontColor = newColor.toHex() ?? "#FFFFFF" }
                                else { card.backColor = newColor.toHex() ?? "#FFFFFF" }
                            }
                        ))
                        .labelsHidden()
                        .scaleEffect(0.9)
                        .frame(width: 32)
                    }
                }
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                if let card = currentFocusedCard, let index = deck.cards.firstIndex(where: { $0.id == card.id }) {
                    Text("\(index + 1) / \(deck.cards.count)")
                        .font(AppTheme.font(.caption, weight: .bold))
                        .foregroundStyle(AppTheme.Colors.primary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AppTheme.Colors.primary.opacity(0.1))
                        .clipShape(Capsule())
                }
                
                Button(Localization.string("common_done", lang: settings.appLanguage)) { focusedField = nil }
                    .font(AppTheme.font(.body, weight: .bold))
                    .foregroundStyle(AppTheme.Colors.primary)
            }
        }
    }
}

struct EditCardRow: View {
    @Bindable var card: Card
    let index: Int
    let total: Int
    var focusedField: FocusState<EditDeckView.FocusField?>.Binding
    @EnvironmentObject var settings: AppSettings
    var onDelete: () -> Void
    
    @State private var selectedItem: PhotosPickerItem? = nil
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("\(index)")
                    .font(AppTheme.font(.caption, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 24, height: 24)
                    .background(AppTheme.Colors.primary)
                    .clipShape(Circle())
                
                Spacer()
                
                Button(action: onDelete) {
                    Image(systemName: "trash.fill")
                        .font(.caption)
                        .foregroundStyle(.red.opacity(0.9))
                }
            }
            
            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(Localization.string("add_word_front_label", lang: settings.appLanguage).uppercased())
                            .font(AppTheme.font(.caption2, weight: .bold))
                            .foregroundStyle(.white.opacity(0.6))
                        
                        TextField("", text: $card.front, axis: .vertical)
                            .font(AppTheme.font(.body, weight: card.isFrontBold ? .bold : .semibold, italic: card.isFrontItalic))
                            .italic(card.isFrontItalic)
                            .underline(card.isFrontUnderline)
                            .foregroundStyle(Color(hex: card.frontColor))
                            .focused(focusedField, equals: .cardFront(card.id))
                    }
                    
                    Divider().background(Color.white.opacity(0.1))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(Localization.string("add_word_back_label", lang: settings.appLanguage).uppercased())
                            .font(AppTheme.font(.caption2, weight: .bold))
                            .foregroundStyle(.white.opacity(0.6))
                        
                        TextField("", text: $card.back, axis: .vertical)
                            .font(AppTheme.font(.body, weight: card.isBackBold ? .bold : .regular, italic: card.isBackItalic))
                            .italic(card.isBackItalic)
                            .underline(card.isBackUnderline)
                            .foregroundStyle(Color(hex: card.backColor))
                            .focused(focusedField, equals: .cardBack(card.id))
                    }
                }
                
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    if let data = card.imageData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    } else {
                        VStack(spacing: 4) {
                            Image(systemName: "photo.badge.plus")
                                .font(.system(size: 20))
                            Text(Localization.string("deck_edit_image", lang: settings.appLanguage))
                                .font(AppTheme.font(.caption2))
                        }
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                        .frame(width: 80, height: 80)
                        .background(Color.white.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .onChange(of: selectedItem) {
                    Task {
                        if let data = try? await selectedItem?.loadTransferable(type: Data.self) {
                            card.imageData = data
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(AppTheme.Colors.surfaceHighlight)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

struct DeckSettingsSheet: View {
    @Bindable var deck: Deck
    @EnvironmentObject var settings: AppSettings
    @Environment(\.dismiss) var dismiss
    
    @State private var showingTermLangPicker = false
    @State private var showingDefLangPicker = false
    
    let languages = ["Tiếng Việt", "Tiếng Anh", "Tiếng Nhật", "Tiếng Hàn", "Tiếng Trung", "Tiếng Pháp", "Tiếng Đức", "Tiếng Tây Ban Nha", "Tiếng Ý", "Tiếng Nga"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        VStack(alignment: .leading, spacing: 16) {
                            Text(Localization.string("deck_settings_lang_section", lang: settings.appLanguage))
                                .font(AppTheme.font(.caption, weight: .bold))
                                .foregroundStyle(AppTheme.Colors.textSecondary)
                                .padding(.leading, 4)
                            
                            VStack(spacing: 0) {
                                languageSelectionRow(title: Localization.string("deck_settings_term_lang", lang: settings.appLanguage), selection: $deck.termLanguage) {
                                    showingTermLangPicker = true
                                }
                                Divider().background(AppTheme.Colors.surfaceHighlight).padding(.leading, 16)
                                languageSelectionRow(title: Localization.string("deck_settings_def_lang", lang: settings.appLanguage), selection: $deck.definitionLanguage) {
                                    showingDefLangPicker = true
                                }
                            }
                            .background(AppTheme.Colors.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text(Localization.string("deck_settings_privacy_section", lang: settings.appLanguage))
                                .font(AppTheme.font(.caption, weight: .bold))
                                .foregroundStyle(AppTheme.Colors.textSecondary)
                                .padding(.leading, 4)
                            
                            VStack(spacing: 0) {
                                Toggle(isOn: $deck.isPublic) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(Localization.string("deck_settings_who_can_view", lang: settings.appLanguage))
                                            .font(AppTheme.font(.body, weight: .semibold))
                                            .foregroundStyle(.white)
                                        Text(deck.isPublic ? Localization.string("deck_settings_public", lang: settings.appLanguage) : Localization.string("deck_settings_private", lang: settings.appLanguage))
                                            .font(AppTheme.font(.caption))
                                            .foregroundStyle(AppTheme.Colors.textSecondary)
                                    }
                                }
                                .padding(16)
                                .tint(AppTheme.Colors.primary)
                                
                                Divider().background(AppTheme.Colors.surfaceHighlight).padding(.leading, 16)
                                
                                Toggle(isOn: $deck.canEditByOthers) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(Localization.string("deck_settings_who_can_edit", lang: settings.appLanguage))
                                            .font(AppTheme.font(.body, weight: .semibold))
                                            .foregroundStyle(.white)
                                        Text(deck.canEditByOthers ? Localization.string("deck_settings_public", lang: settings.appLanguage) : Localization.string("deck_settings_private", lang: settings.appLanguage))
                                            .font(AppTheme.font(.caption))
                                            .foregroundStyle(AppTheme.Colors.textSecondary)
                                    }
                                }
                                .padding(16)
                                .tint(AppTheme.Colors.primary)
                            }
                            .background(AppTheme.Colors.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle(Localization.string("deck_settings_title", lang: settings.appLanguage))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(Localization.string("common_done", lang: settings.appLanguage)) { dismiss() }
                        .font(AppTheme.font(.body, weight: .bold))
                        .foregroundStyle(AppTheme.Colors.primary)
                }
            }
            .sheet(isPresented: $showingTermLangPicker) {
                SearchableLanguagePicker(selectedLanguage: $deck.termLanguage, languages: languages)
            }
            .sheet(isPresented: $showingDefLangPicker) {
                SearchableLanguagePicker(selectedLanguage: $deck.definitionLanguage, languages: languages)
            }
        }
    }
    
    private func languageSelectionRow(title: String, selection: Binding<String>, action: @escaping () -> Void) -> some View {
        HStack {
            Text(title)
                .font(AppTheme.font(.body, weight: .semibold))
                .foregroundStyle(.white)
            Spacer()
            
            Button(action: action) {
                HStack(spacing: 4) {
                    Text(selection.wrappedValue)
                        .font(AppTheme.font(.body))
                        .foregroundStyle(AppTheme.Colors.primary)
                    Image(systemName: "chevron.right")
                        .font(.caption2.bold())
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(AppTheme.Colors.surfaceHighlight.opacity(0.5))
                .clipShape(Capsule())
            }
        }
        .padding(16)
    }
}

struct AddToClassView: View {
    let deck: Deck
    @Query private var classes: [ClassRoom]
    @EnvironmentObject var settings: AppSettings
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.background.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 16) {
                        if classes.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "person.3.fill")
                                    .font(.system(size: 48))
                                    .foregroundStyle(AppTheme.Colors.textSecondary.opacity(0.3))
                                Text(Localization.string("deck_add_to_class_empty", lang: settings.appLanguage))
                                    .font(AppTheme.font(.body, weight: .bold))
                                    .foregroundStyle(AppTheme.Colors.textSecondary)
                            }
                            .padding(.top, 60)
                        } else {
                            ForEach(classes) { classRoom in
                                Button {
                                    if !classRoom.assignedDecks.contains(where: { $0.id == deck.id }) {
                                        classRoom.assignedDecks.append(deck)
                                    }
                                    dismiss()
                                } label: {
                                    ClassCard(classRoom: classRoom)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle(Localization.string("deck_add_to_class_title", lang: settings.appLanguage))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(Localization.string("common_cancel", lang: settings.appLanguage)) { dismiss() }
                }
            }
        }
    }
}

struct AddToFolderView: View {
    let deck: Deck
    @Query private var folders: [Folder]
    @EnvironmentObject var settings: AppSettings
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.background.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 16) {
                        if folders.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "folder.fill")
                                    .font(.system(size: 48))
                                    .foregroundStyle(AppTheme.Colors.textSecondary.opacity(0.3))
                                Text(Localization.string("deck_add_to_folder_empty", lang: settings.appLanguage))
                                    .font(AppTheme.font(.body, weight: .bold))
                                    .foregroundStyle(AppTheme.Colors.textSecondary)
                            }
                            .padding(.top, 60)
                        } else {
                            ForEach(folders) { folder in
                                Button {
                                    deck.folder = folder
                                    dismiss()
                                } label: {
                                    FolderCard(folder: folder)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle(Localization.string("deck_add_to_folder_title", lang: settings.appLanguage))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(Localization.string("common_cancel", lang: settings.appLanguage)) { dismiss() }
                }
            }
        }
    }
}

struct DeckInfoView: View {
    let deck: Deck
    @EnvironmentObject var settings: AppSettings
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.background.ignoresSafeArea()
                VStack(spacing: 24) {
                    InfoRow(label: Localization.string("deck_info_created_at", lang: settings.appLanguage), value: deck.createdAt.formatted(date: .long, time: .shortened))
                    InfoRow(label: Localization.string("deck_info_card_count", lang: settings.appLanguage), value: "\(deck.cards.count) \(Localization.string("deck_info_cards_unit", lang: settings.appLanguage))")
                    InfoRow(label: Localization.string("deck_info_language", lang: settings.appLanguage), value: deck.language)
                    InfoRow(label: Localization.string("deck_info_id", lang: settings.appLanguage), value: deck.id.uuidString.prefix(8).uppercased())
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle(Localization.string("deck_info_title", lang: settings.appLanguage))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(Localization.string("common_done", lang: settings.appLanguage)) { dismiss() }
                }
            }
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    var body: some View {
        HStack {
            Text(label)
                .font(AppTheme.font(.body))
                .foregroundStyle(AppTheme.Colors.textSecondary)
            Spacer()
            Text(value)
                .font(AppTheme.font(.body, weight: .bold))
                .foregroundStyle(.white)
        }
        .padding(20)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppTheme.Colors.surfaceHighlight, lineWidth: 1)
        )
    }
}

#if canImport(UIKit)
struct ShareActivityView: UIViewControllerRepresentable {
    let text: String

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [text], applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
#else
struct ShareActivityView: View {
    let text: String

    var body: some View {
        Text(text)
            .multilineTextAlignment(.center)
            .padding()
    }
}
#endif
