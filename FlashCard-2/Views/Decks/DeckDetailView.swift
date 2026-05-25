import SwiftUI
import SwiftData

struct DeckDetailView: View {
    @Bindable var deck: Deck
    @EnvironmentObject var navManager: NavigationManager
    @State private var showingQuizOptions = false
    @State private var selectedQuizMode: QuizModeType? = nil
    @State private var carouselIndex = 0
    @State private var popToRoot = false
    @State private var showFloatingStudyButton = false
    @State private var showStudyModesMenu = false
    @EnvironmentObject var settings: AppSettings
    @Environment(\.dismiss) var dismiss
    @State private var showingImport = false
    @State private var showingEditDeck = false
    
    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 24, pinnedViews: [.sectionHeaders]) {
                    // 1. Horizontal Card Carousel
                    if !deck.cards.isEmpty {
                        cardCarouselSection
                    } else {
                        emptyCardPlaceholder
                    }
                    
                    // 2. Deck Info (Title, User, Terms)
                    deckInfoSection
                    
                    // 3. Flashcard Mode Entry
                    flashcardStudyEntry
                    
                    // 4. Learning Modes Section (Quiz)
                    learningModesSection
                    
                    // 5. Games Section
                    gamesSection
                    
                    // 6. Terms Section (Sticky)
                    termsSection
                    
                    Spacer(minLength: 120)
                }
                .padding(.top, 16)
            }
            .coordinateSpace(name: "DETAIL_SCROLL")
            
            // Floating Study Button
            if showFloatingStudyButton && !showStudyModesMenu {
                VStack {
                    Spacer()
                    Button {
                        AppTheme.haptic(.medium)
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            showStudyModesMenu = true
                        }
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "play.fill")
                            Text(Localization.string("deck_study_this", lang: settings.appLanguage))
                                .font(AppTheme.font(.headline, weight: .bold))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 16)
                        .background(
                            Capsule()
                                .fill(AppTheme.Colors.primaryGradient)
                        )
                        .shadow(color: AppTheme.Colors.primary.opacity(0.4), radius: 15, x: 0, y: 10)
                        .overlay(
                            Capsule()
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                    }
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .scale(scale: 0.8).combined(with: .opacity)
                    ))
                    .padding(.bottom, 24)
                }
                .zIndex(100)
            }
            
            // Study Modes Menu Overlay
            if showStudyModesMenu {
                ZStack {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation { showStudyModesMenu = false }
                        }
                    
                    VStack {
                        Spacer()
                        VStack(spacing: 0) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(AppTheme.Colors.surfaceHighlight)
                                .frame(width: 40, height: 4)
                                .padding(.vertical, 12)
                            
                            Text(Localization.string("deck_choose_mode", lang: settings.appLanguage))
                                .font(AppTheme.font(.headline, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(.bottom, 24)
                            
                            VStack(spacing: 12) {
                                NavigationLink(destination: StudyView(deck: deck)) {
                                    StudyModeOptionRow(title: Localization.string("deck_flashcards", lang: settings.appLanguage), icon: "rectangle.portrait.on.rectangle.portrait.fill", color: AppTheme.Colors.primary)
                                }
                                
                                Button {
                                    showStudyModesMenu = false
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        showingQuizOptions = true
                                    }
                                } label: {
                                    StudyModeOptionRow(title: Localization.string("deck_quiz_mode", lang: settings.appLanguage), icon: "checkmark.square.fill", color: .orange)
                                }
                                
                                NavigationLink(destination: MatchingGameView(deck: deck, shouldPopToRoot: $popToRoot)) {
                                    StudyModeOptionRow(title: Localization.string("deck_matching", lang: settings.appLanguage), icon: "square.grid.2x2.fill", color: .blue)
                                }
                                
                                NavigationLink(destination: BlastGameView(deck: deck, shouldPopToRoot: $popToRoot)) {
                                    StudyModeOptionRow(title: Localization.string("deck_blast", lang: settings.appLanguage), icon: "bolt.fill", color: .purple)
                                }
                                
                                NavigationLink(destination: BlockGameView(deck: deck, shouldPopToRoot: $popToRoot)) {
                                    StudyModeOptionRow(title: Localization.string("deck_block", lang: settings.appLanguage), icon: "building.2.fill", color: .pink)
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 50)
                        }
                        .background(AppTheme.Colors.surface)
                        .clipShape(RoundedCorner(radius: 32, corners: [.topLeft, .topRight]))
                        .transition(.move(edge: .bottom))
                    }
                    .ignoresSafeArea(edges: .bottom)
                }
                .zIndex(200)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    AppTheme.haptic(.medium)
                    navManager.selectedDeckForOptions = deck
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        navManager.showingDeckOptions = true
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Circle())
                }
            }
        }
        .sheet(isPresented: $showingQuizOptions) {
            QuizOptionsSheet(deck: deck) { mode in
                showingQuizOptions = false
                // Small delay to allow sheet to dismiss before presenting quiz
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    selectedQuizMode = mode
                }
            }
            .presentationDetents([.height(350)])
            .presentationDragIndicator(.visible)
        }
        .fullScreenCover(item: $selectedQuizMode) { mode in
            QuizView(deck: deck, mode: mode)
        }
        .sheet(isPresented: $showingImport) {
            VocabularyImportView(deck: deck)
        }
        .fullScreenCover(isPresented: $showingEditDeck) {
            EditDeckView(deck: deck)
        }
        .onChange(of: popToRoot) {
            if popToRoot {
                dismiss()
            }
        }
        .onChange(of: deck.cards.count) { _, newValue in
            if carouselIndex >= newValue {
                carouselIndex = max(0, newValue - 1)
            }
        }
        .onAppear {
            withAnimation(.spring()) {
                navManager.isTabBarHidden = true
            }
        }
        .onDisappear {
            withAnimation(.spring()) {
                navManager.isTabBarHidden = false
            }
        }
    }
    
    // ... existing cardCarouselSection, deckInfoSection, etc. ...
    
    // MARK: - 1. Carousel Section
    private var cardCarouselSection: some View {
        let cards = deck.cards
        return VStack(spacing: 12) {
            TabView(selection: $carouselIndex) {
                ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                    CarouselCardPreview(card: card)
                        .padding(.horizontal, 24)
                        .tag(index)
                }
            }
            .frame(height: 220)
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            // Progress dots or indicator
            HStack(spacing: 6) {
                ForEach(0..<min(cards.count, 10), id: \.self) { index in
                    Circle()
                        .fill(index == carouselIndex ? AppTheme.Colors.primary : Color.white.opacity(0.3))
                        .frame(width: index == carouselIndex ? 8 : 6, height: index == carouselIndex ? 8 : 6)
                }
            }
            .padding(.top, 4)
        }
    }
    
    private var emptyCardPlaceholder: some View {
        VStack(spacing: 20) {
            RoundedRectangle(cornerRadius: 24)
                .fill(AppTheme.Colors.surface)
                .frame(height: 220)
                .overlay(
                    VStack(spacing: 24) {
                        VStack(spacing: 8) {
                            Image(systemName: "square.stack.3d.up.slash.fill")
                                .font(.system(size: 48))
                                .foregroundStyle(AppTheme.Colors.textSecondary.opacity(0.5))
                            Text(Localization.string("deck_no_cards", lang: settings.appLanguage))
                                .font(AppTheme.font(.subheadline, weight: .bold))
                                .foregroundStyle(AppTheme.Colors.textSecondary)
                        }
                        
                        HStack(spacing: 16) {
                            // Manual Add
                            Button {
                                AppTheme.haptic(.medium)
                                showingEditDeck = true
                            } label: {
                                Label(Localization.string("deck_add_manual", lang: settings.appLanguage), systemImage: "plus.circle.fill")
                                    .font(AppTheme.font(.subheadline, weight: .bold))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(AppTheme.Colors.surfaceHighlight)
                                    .foregroundStyle(.white)
                                    .clipShape(Capsule())
                            }
                            
                            // Smart Import
                            Button {
                                AppTheme.haptic(.medium)
                                showingImport = true
                            } label: {
                                Label(Localization.string("deck_smart_import", lang: settings.appLanguage), systemImage: "sparkles")
                                    .font(AppTheme.font(.subheadline, weight: .bold))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(AppTheme.Colors.primaryGradient)
                                    .foregroundStyle(.white)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                )
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - 2. Deck Info Section
    private var deckInfoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(deck.title)
                .font(AppTheme.font(.title2, weight: .black))
                .foregroundStyle(.white)
            
            HStack(spacing: 8) {
                Label(deck.termLanguage, systemImage: "character.bubble.fill")
                Image(systemName: "arrow.right")
                    .font(.caption2.bold())
                Text(deck.definitionLanguage)
            }
            .font(AppTheme.font(.caption2, weight: .bold))
            .foregroundStyle(AppTheme.Colors.primary)
            .padding(.vertical, 4)
            .padding(.horizontal, 10)
            .background(AppTheme.Colors.primary.opacity(0.1))
            .clipShape(Capsule())
            
            HStack(spacing: 12) {
                HStack(spacing: 4) {
                    Image(systemName: "person.circle.fill")
                    Text(Localization.string("deck_author", lang: settings.appLanguage))
                }
                
                Text("•")
                
                Text("\(deck.cards.count) \(Localization.string("deck_terms", lang: settings.appLanguage))")
            }
            .font(AppTheme.font(.caption, weight: .medium))
            .foregroundStyle(AppTheme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
    }
    
    // MARK: - 3. Flashcard Study Entry
    private var flashcardStudyEntry: some View {
        NavigationLink(destination: StudyView(deck: deck)) {
            HStack(spacing: 20) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(AppTheme.Colors.primary.opacity(0.2))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: "rectangle.portrait.on.rectangle.portrait.fill")
                        .font(.title2)
                        .foregroundStyle(AppTheme.Colors.primary)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(Localization.string("deck_flashcards", lang: settings.appLanguage))
                        .font(AppTheme.font(.headline, weight: .bold))
                        .foregroundStyle(.white)
                    Text(Localization.string("deck_flashcard_desc", lang: settings.appLanguage))
                        .font(AppTheme.font(.caption))
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption.bold())
                    .foregroundStyle(AppTheme.Colors.textSecondary.opacity(0.5))
            }
            .padding(20)
            .background(AppTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(AppTheme.Colors.surfaceHighlight, lineWidth: 1)
            )
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - 4. Learning Modes Section
    private var learningModesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(Localization.string("deck_quiz_options", lang: settings.appLanguage))
                .font(AppTheme.font(.headline, weight: .bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
            
            Button {
                showingQuizOptions = true
            } label: {
                HStack(spacing: 20) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.orange.opacity(0.2))
                            .frame(width: 56, height: 56)
                        
                        Image(systemName: "checkmark.square.fill")
                            .font(.title2)
                            .foregroundStyle(.orange)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(Localization.string("deck_quiz_mode", lang: settings.appLanguage))
                            .font(AppTheme.font(.headline, weight: .bold))
                            .foregroundStyle(.white)
                        Text(Localization.string("deck_quiz_desc", lang: settings.appLanguage))
                            .font(AppTheme.font(.caption))
                            .foregroundStyle(AppTheme.Colors.textSecondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.caption.bold())
                        .foregroundStyle(AppTheme.Colors.textSecondary.opacity(0.5))
                }
                .padding(20)
                .background(AppTheme.Colors.surface)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(AppTheme.Colors.surfaceHighlight, lineWidth: 1)
                )
            }
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - 5. Games Section
    private var gamesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(Localization.string("deck_games_section", lang: settings.appLanguage))
                .font(AppTheme.font(.headline, weight: .bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
            
            VStack(spacing: 12) {
                NavigationLink(destination: MatchingGameView(deck: deck, shouldPopToRoot: $popToRoot)) {
                    GameOptionRow(
                        title: Localization.string("deck_matching_title", lang: settings.appLanguage),
                        subtitle: Localization.string("deck_matching_desc", lang: settings.appLanguage),
                        icon: "square.grid.2x2.fill",
                        color: Color.blue
                    )
                }
                
                NavigationLink(destination: BlastGameView(deck: deck, shouldPopToRoot: $popToRoot)) {
                    GameOptionRow(
                        title: Localization.string("deck_blast", lang: settings.appLanguage),
                        subtitle: Localization.string("deck_blast_desc", lang: settings.appLanguage),
                        icon: "bolt.fill",
                        color: Color.purple
                    )
                }
                
                NavigationLink(destination: BlockGameView(deck: deck, shouldPopToRoot: $popToRoot)) {
                    GameOptionRow(
                        title: Localization.string("deck_block", lang: settings.appLanguage),
                        subtitle: Localization.string("deck_block_desc", lang: settings.appLanguage),
                        icon: "building.2.fill",
                        color: Color.pink
                    )
                }
            }
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - 6. Terms Section
    private var termsSection: some View {
        Section(header: termsHeader) {
            VStack(spacing: 12) {
                ForEach(deck.cards) { card in
                    TermCardRow(card: card)
                        .visualEffect { content, geometry in
                            let minY = geometry.frame(in: .global).minY
                            // Control the fade zone (around the top navigation area)
                            let fadeStart: CGFloat = 200
                            let fadeEnd: CGFloat = 100
                            let progress = max(0, min(1, (minY - fadeEnd) / (fadeStart - fadeEnd)))
                            
                            return content
                                .opacity(progress)
                                .blur(radius: (1 - progress) * 10)
                                .scaleEffect(0.95 + (0.05 * progress))
                        }
                }
            }
            .padding(.horizontal, 24)
        }
    }
    
    private var termsHeader: some View {
        HStack {
            let termsInSet = String(format: Localization.string("deck_terms_in_set", lang: settings.appLanguage), deck.cards.count)
            Text(termsInSet)
                .font(AppTheme.font(.headline, weight: .bold))
                .foregroundStyle(.white)
            
            Spacer()
              
            Button {
                // Option to sort or filter
            } label: {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .foregroundStyle(AppTheme.Colors.primary)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(Color.clear)
        .background(
            GeometryReader { geo in
                Color.clear
                    .onChange(of: geo.frame(in: .named("DETAIL_SCROLL")).minY) { old, newValue in
                        // When the header's top reaches near the top of the scroll view (e.g., < 100)
                        let shouldShow = newValue < 100
                        if showFloatingStudyButton != shouldShow {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                showFloatingStudyButton = shouldShow
                            }
                        }
                    }
            }
        )
    }
}

// MARK: - Supporting Views

struct TermCardRow: View {
    let card: Card
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(card.front)
                        .font(AppTheme.font(.body, weight: .bold))
                        .foregroundStyle(.white)
                    
                    if let pronun = card.pronunciation {
                        Text(pronun)
                            .font(AppTheme.font(.caption))
                            .foregroundStyle(AppTheme.Colors.primary)
                    }
                }
                
                Spacer()
                
                if let data = card.imageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                Button {
                    // Audio pronunciation
                } label: {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.caption)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
            }
            
            Divider()
                .background(AppTheme.Colors.surfaceHighlight)
            
            Text(card.back)
                .font(AppTheme.font(.body))
                .foregroundStyle(AppTheme.Colors.textSecondary)
            
            if let example = card.example {
                Text(example)
                    .font(AppTheme.font(.caption))
                    .italic()
                    .foregroundStyle(AppTheme.Colors.textSecondary.opacity(0.7))
                    .padding(.top, 4)
            }
        }
        .padding(20)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppTheme.Colors.surfaceHighlight, lineWidth: 1)
        )
    }
}

// MARK: - Supporting Views for Detail

struct CarouselCardPreview: View {
    @EnvironmentObject var settings: AppSettings
    let card: Card
    @State private var isFlipped = false
    
    var body: some View {
        ZStack {
            // Back
            cardSide(text: card.back, isFront: false)
                .opacity(isFlipped ? 1 : 0)
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
            
            // Front
            cardSide(text: card.front, isFront: true)
                .opacity(isFlipped ? 0 : 1)
        }
        .onTapGesture {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                isFlipped.toggle()
            }
        }
        .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
    }
    
    private func cardSide(text: String, isFront: Bool) -> some View {
        VStack(spacing: 12) {
            Text(isFront ? Localization.string("deck_card_front", lang: settings.appLanguage) : Localization.string("deck_card_back", lang: settings.appLanguage))
                .font(AppTheme.font(.caption, weight: .bold))
                .foregroundStyle(isFront ? AppTheme.Colors.primary : Color.green)
                .padding(.bottom, 4)
            
            HStack(spacing: 16) {
                VStack(alignment: isFront ? .center : .leading, spacing: 8) {
                    Text(text)
                        .font(AppTheme.font(.title3, weight: .bold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(isFront ? .center : .leading)
                    
                    if isFront, let pronun = card.pronunciation {
                        Text(pronun)
                            .font(AppTheme.font(.caption))
                            .foregroundStyle(AppTheme.Colors.textSecondary)
                    }
                }
                
                if !isFront, let data = card.imageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(isFront ? AppTheme.Colors.primary.opacity(0.3) : Color.green.opacity(0.3), lineWidth: 2)
        )
        .shadow(color: Color.black.opacity(0.3), radius: 12, x: 0, y: 8)
    }
}

struct GameOptionRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppTheme.font(.body, weight: .bold))
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(AppTheme.font(.caption))
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption.bold())
                .foregroundStyle(AppTheme.Colors.textSecondary.opacity(0.5))
        }
        .padding(16)
        .background(AppTheme.Colors.surfaceHighlight.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

struct StudyModeOptionRow: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.1))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(color)
            }
            
            Text(title)
                .font(AppTheme.font(.body, weight: .bold))
                .foregroundStyle(.white)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption.bold())
                .foregroundStyle(AppTheme.Colors.textSecondary.opacity(0.3))
        }
        .padding(12)
        .background(AppTheme.Colors.surfaceHighlight.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// Ensure QuizModeType conforms to Identifiable for sheet/cover
extension QuizModeType: Identifiable {
    var id: String { "\(self)" }
}

struct QuizOptionsSheet: View {
    let deck: Deck
    var onSelect: (QuizModeType) -> Void
    @EnvironmentObject var settings: AppSettings
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            Text(Localization.string("deck_quiz_method", lang: settings.appLanguage))
                .font(AppTheme.font(.headline, weight: .bold))
                .padding(.top, 8)
            
            VStack(spacing: 16) {
                Button {
                    onSelect(.cram)
                } label: {
                    HStack {
                        Image(systemName: "bolt.fill")
                            .foregroundStyle(.yellow)
                        VStack(alignment: .leading) {
                            Text(Localization.string("deck_quiz_cram", lang: settings.appLanguage))
                                .font(AppTheme.font(.body, weight: .bold))
                            Text(Localization.string("deck_quiz_cram_desc", lang: settings.appLanguage))
                                .font(AppTheme.font(.caption))
                        }
                        Spacer()
                    }
                    .padding()
                    .background(AppTheme.Colors.surfaceHighlight)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                
                Button {
                    onSelect(.longTerm)
                } label: {
                    HStack {
                        Image(systemName: "brain.head.profile")
                            .foregroundStyle(.blue)
                        VStack(alignment: .leading) {
                            Text(Localization.string("deck_quiz_longterm", lang: settings.appLanguage))
                                .font(AppTheme.font(.body, weight: .bold))
                            Text(Localization.string("deck_quiz_longterm_desc", lang: settings.appLanguage))
                                .font(AppTheme.font(.caption))
                        }
                        Spacer()
                    }
                    .padding()
                    .background(AppTheme.Colors.surfaceHighlight)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
        .background(AppTheme.Colors.background)
        .foregroundStyle(.white)
    }
}
