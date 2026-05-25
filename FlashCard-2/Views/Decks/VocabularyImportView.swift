import SwiftUI
import PhotosUI
import Vision

struct VocabularyImportView: View {
    var deck: Deck?
    var onImport: (([Card]) -> Void)? = nil
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var settings: AppSettings
    
    @State private var importSource: ImportSource = .text
    @State private var textInput: String = ""
    @State private var previewCards: [CardPrompt] = []
    @State private var isProcessing = false
    @State private var selectedSeparator: String = "-"
    
    let separators = ["-", ":", ";", ",", "Tab"]
    
    // For Photo Picking
    @State private var selectedItem: PhotosPickerItem? = nil
    
    // For File Picking
    @State private var showingFilePicker = false
    
    enum ImportSource: String, CaseIterable, Identifiable {
        case text, image, file
        var id: String { self.rawValue }
        
        var titleKey: String {
            switch self {
            case .text: return "deck_import_text"
            case .image: return "deck_import_image"
            case .file: return "deck_import_file"
            }
        }
        
        var icon: String {
            switch self {
            case .text: return "doc.text.fill"
            case .image: return "camera.fill"
            case .file: return "arrow.up.doc.fill"
            }
        }
    }
    
    struct CardPrompt: Identifiable {
        let id = UUID()
        var front: String
        var back: String
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.background.ignoresSafeArea()
                
                contentLayout
                
                bottomActionButton
            }
            .navigationTitle(Localization.string("deck_import_title", lang: settings.appLanguage))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(Localization.string("common_cancel", lang: settings.appLanguage)) {
                        dismiss()
                    }
                }
            }
            .onChange(of: textInput) { _, _ in parseTextInput() }
            .onChange(of: selectedItem) { _, _ in handleImageSelection() }
            .sheet(isPresented: $showingFilePicker) {
                DocumentPicker(cards: $previewCards)
            }
        }
    }
    
    @ViewBuilder
    private var contentLayout: some View {
        VStack(spacing: 0) {
            sourceSelector
            
            ScrollView {
                VStack(spacing: 24) {
                    languageDirectionHeader
                    sourceInputContent
                    
                    if !previewCards.isEmpty {
                        previewSection
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 120)
            }
        }
    }
    
    @ViewBuilder
    private var sourceSelector: some View {
        HStack(spacing: 12) {
            ForEach(ImportSource.allCases) { source in
                sourceChip(for: source)
            }
        }
        .padding(20)
    }
    
    @ViewBuilder
    private func sourceChip(for source: ImportSource) -> some View {
        let isSelected = importSource == source
        
        Button {
            withAnimation(.spring(response: 0.3)) {
                importSource = source
            }
        } label: {
            VStack(spacing: 8) {
                Image(systemName: source.icon)
                    .font(.title3)
                Text(Localization.string(source.titleKey, lang: settings.appLanguage))
                    .font(AppTheme.font(.caption, weight: .bold))
            }
            .foregroundStyle(isSelected ? .white : AppTheme.Colors.textSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isSelected ? AnyShapeStyle(AppTheme.Colors.primaryGradient) : AnyShapeStyle(AppTheme.Colors.surface.opacity(0.5)))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.clear : AppTheme.Colors.surfaceHighlight, lineWidth: 1)
            )
        }
    }
    
    @ViewBuilder
    private var bottomActionButton: some View {
        VStack {
            Spacer()
            if !previewCards.isEmpty {
                Button(action: importCards) {
                    Text(String(format: Localization.string("deck_import_confirm", lang: settings.appLanguage), previewCards.count))
                        .font(AppTheme.font(.headline, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(AppTheme.Colors.primaryGradient)
                        .clipShape(Capsule())
                        .shadow(color: AppTheme.Colors.primary.opacity(0.3), radius: 10, y: 5)
                }
                .padding(24)
            }
        }
    }
    @ViewBuilder
    private var languageDirectionHeader: some View {
        HStack {
            HStack(spacing: 8) {
                Text(deck?.termLanguage ?? Localization.string("deck_card_front", lang: settings.appLanguage))
                    .font(AppTheme.font(.headline, weight: .bold))
                    .foregroundStyle(AppTheme.Colors.primary)
                
                Image(systemName: "arrow.right")
                    .font(.caption.bold())
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                
                Text(deck?.definitionLanguage ?? Localization.string("deck_card_back", lang: settings.appLanguage))
                    .font(AppTheme.font(.headline, weight: .bold))
                    .foregroundStyle(AppTheme.Colors.success)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(AppTheme.Colors.surfaceHighlight.opacity(0.3))
            .clipShape(Capsule())
            
            Spacer()
        }
        .padding(.top, 8)
    }

    @ViewBuilder
    private var sourceInputContent: some View {
        switch importSource {
        case .text:
            VStack(alignment: .leading, spacing: 20) {
                // Format Guide
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundStyle(AppTheme.Colors.primary)
                        Text(Localization.string("deck_import_format_guide", lang: settings.appLanguage))
                            .font(AppTheme.font(.caption, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    
                    Text(Localization.string("deck_import_format_desc", lang: settings.appLanguage))
                        .font(AppTheme.font(.caption2))
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                        .lineLimit(2)
                }
                .padding()
                .background(AppTheme.Colors.surfaceHighlight.opacity(0.3))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                
                // Separator Selector
                VStack(alignment: .leading, spacing: 12) {
                    Text(Localization.string("deck_import_separator_label", lang: settings.appLanguage))
                        .font(AppTheme.font(.caption, weight: .bold))
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                    
                    HStack(spacing: 8) {
                        ForEach(separators, id: \.self) { sep in
                            Button {
                                AppTheme.haptic(.light)
                                selectedSeparator = sep
                                parseTextInput()
                            } label: {
                                Text(sep)
                                    .font(AppTheme.font(.caption, weight: .bold))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(selectedSeparator == sep ? AppTheme.Colors.primary : AppTheme.Colors.surface)
                                    .foregroundStyle(selectedSeparator == sep ? .white : AppTheme.Colors.textSecondary)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                }
                
                TextEditor(text: $textInput)
                    .font(AppTheme.font(.body))
                    .foregroundStyle(.white)
                    .scrollContentBackground(.hidden)
                    .padding(12)
                    .frame(minHeight: 200)
                    .background(AppTheme.Colors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        ZStack(alignment: .topLeading) {
                            if textInput.isEmpty {
                                Text("\(deck?.termLanguage ?? Localization.string("deck_card_front", lang: settings.appLanguage)) \(selectedSeparator) \(deck?.definitionLanguage ?? Localization.string("deck_card_back", lang: settings.appLanguage))")
                                    .font(AppTheme.font(.body))
                                    .foregroundStyle(.white.opacity(0.3))
                                    .padding(.top, 20)
                                    .padding(.leading, 16)
                            }
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(AppTheme.Colors.surfaceHighlight, lineWidth: 1)
                        }
                    )
            }
            
        case .image:
            VStack(spacing: 20) {
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    VStack(spacing: 16) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 40))
                        Text(Localization.string("deck_import_image_desc", lang: settings.appLanguage))
                            .font(AppTheme.font(.body, weight: .medium))
                            .multilineTextAlignment(.center)
                    }
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                    .background(AppTheme.Colors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(AppTheme.Colors.surfaceHighlight, style: StrokeStyle(lineWidth: 1, dash: [5]))
                    )
                }
                
                if isProcessing {
                    ProgressView()
                        .tint(AppTheme.Colors.primary)
                }
            }
            
        case .file:
            VStack(spacing: 20) {
                Button {
                    showingFilePicker = true
                } label: {
                    VStack(spacing: 16) {
                        Image(systemName: "doc.badge.plus")
                            .font(.system(size: 40))
                        Text(Localization.string("deck_import_file_desc", lang: settings.appLanguage))
                            .font(AppTheme.font(.body, weight: .medium))
                    }
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                    .background(AppTheme.Colors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(AppTheme.Colors.surfaceHighlight, style: StrokeStyle(lineWidth: 1, dash: [5]))
                    )
                }
            }
        }
    }
    
    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(String(format: Localization.string("deck_import_preview_label", lang: settings.appLanguage), previewCards.count))
                .font(AppTheme.font(.subheadline, weight: .bold))
                .foregroundStyle(AppTheme.Colors.textSecondary)
            
            VStack(spacing: 12) {
                ForEach(previewCards.prefix(50)) { card in
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(card.front)
                                .font(AppTheme.font(.body, weight: .bold))
                                .lineLimit(1)
                            Text(card.back)
                                .font(AppTheme.font(.caption))
                                .foregroundStyle(AppTheme.Colors.textSecondary)
                                .lineLimit(1)
                        }
                        Spacer()
                        Button {
                            previewCards.removeAll(where: { $0.id == card.id })
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.red.opacity(0.8))
                        }
                    }
                    .padding(12)
                    .background(AppTheme.Colors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }
    
    // MARK: - Handlers
    
    private func parseTextInput() {
        let lines = textInput.components(separatedBy: .newlines)
        var newCards: [CardPrompt] = []
        
        let splitChar = selectedSeparator == "Tab" ? "\t" : selectedSeparator
        
        for line in lines {
            let parts = line.components(separatedBy: splitChar).map { $0.trimmingCharacters(in: .whitespaces) }
            if parts.count >= 2 {
                newCards.append(CardPrompt(front: parts[0], back: parts[1]))
            }
        }
        
        previewCards = newCards
    }
    
    private func handleImageSelection() {
        guard let selectedItem else { return }
        isProcessing = true
        
        Task {
            if let data = try? await selectedItem.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                recognizeText(from: uiImage)
            }
            isProcessing = false
        }
    }
    
    private func recognizeText(from image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        
        let request = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            
            var fullText = ""
            for observation in observations {
                if let topCandidate = observation.topCandidates(1).first {
                    fullText += topCandidate.string + "\n"
                }
            }
            
            DispatchQueue.main.async {
                self.textInput = fullText
                self.importSource = .text
            }
        }
        
        request.recognitionLevel = .accurate
        let handler = VNImageRequestHandler(cgImage: cgImage)
        
        DispatchQueue.global(qos: .userInitiated).async {
            try? handler.perform([request])
        }
    }
    
    private func importCards() {
        AppTheme.haptic(.medium)
        let newCards = previewCards.map { Card(front: $0.front, back: $0.back) }
        
        if let onImport = onImport {
            onImport(newCards)
        } else if let deck = deck {
            for card in newCards {
                deck.cards.append(card)
            }
        }
        dismiss()
    }
}

#if canImport(UIKit)
// MARK: - Document Picker Mock/Shell
struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var cards: [VocabularyImportView.CardPrompt]
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.text, .commaSeparatedText])
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: DocumentPicker
        init(_ parent: DocumentPicker) { self.parent = parent }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            if let content = try? String(contentsOf: url) {
                let lines = content.components(separatedBy: .newlines)
                var newCards: [VocabularyImportView.CardPrompt] = []
                for line in lines {
                    let parts = line.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                    if parts.count >= 2 {
                        newCards.append(VocabularyImportView.CardPrompt(front: parts[0], back: parts[1]))
                    }
                }
                parent.cards = newCards
            }
        }
    }
}
#else
struct DocumentPicker: View {
    @Binding var cards: [VocabularyImportView.CardPrompt]

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "doc.text.fill")
                .font(.system(size: 40))
            Text("Document import is not available on this platform.")
                .multilineTextAlignment(.center)
                .foregroundStyle(AppTheme.Colors.textSecondary)
        }
        .padding(24)
    }
}
#endif
