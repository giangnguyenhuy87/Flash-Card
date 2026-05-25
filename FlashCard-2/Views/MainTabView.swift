import SwiftUI
import SwiftData

struct MainTabView: View {
    @EnvironmentObject var navManager: NavigationManager
    @EnvironmentObject var settings: AppSettings
    @Environment(\.modelContext) var modelContext
    @State private var showingDeleteAlert = false
    @State private var showingEditView = false
    @State private var createType: CreateType? = nil
    @State private var deckAction: DeckActionSheet? = nil
    
    enum CreateType: Identifiable {
        case deck, folder, classRoom
        var id: Self { self }
    }
    
    enum DeckActionSheet: Identifiable {
        case edit, addToClass, addToFolder, info, share
        var id: Self { self }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Content
            Group {
                switch navManager.selectedMainTab {
                case 0:
                    HomeView()
                case 1:
                    LibraryView()
                case 2:
                    StatsView()
                case 3:
                     ProfileView()
                default:
                    HomeView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .transition(.asymmetric(
                insertion: .opacity.combined(with: .scale(scale: 0.98)),
                removal: .opacity
            ))
            .id(navManager.selectedMainTab) // Crucial for transition to trigger
            
            // Blur background when any menu is shown
            if navManager.showingCreateMenu || navManager.showingDeckOptions {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            navManager.showingCreateMenu = false
                            navManager.showingDeckOptions = false
                        }
                    }
                    .transition(.opacity)
                    .zIndex(90)
            }
            
            // Custom Tab Bar (Fixed to bottom)
            if !navManager.isTabBarHidden {
                VStack(spacing: 0) {
                    Spacer()
                    
                    HStack(spacing: 0) {
                        TabButton(icon: "house.fill", label: Localization.string("tab_home", lang: settings.appLanguage), isSelected: navManager.selectedMainTab == 0) { 
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) { navManager.selectedMainTab = 0 }
                        }
                        TabButton(icon: "books.vertical.fill", label: Localization.string("tab_library", lang: settings.appLanguage), isSelected: navManager.selectedMainTab == 1) { 
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) { navManager.selectedMainTab = 1 }
                        }
                        
                        // Central Create Button
                        Button(action: {
                            AppTheme.haptic(.medium)
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                navManager.showingCreateMenu.toggle()
                            }
                        }) {
                            Image(systemName: "plus")
                                .font(.title2.bold())
                                .foregroundStyle(.white)
                                .frame(width: 56, height: 56)
                                .background(AppTheme.Colors.primaryGradient)
                                .clipShape(Circle())
                                .shadow(color: AppTheme.Colors.primary.opacity(0.4), radius: 10, x: 0, y: 5)
                                .rotationEffect(.degrees((navManager.showingCreateMenu || navManager.showingDeckOptions) ? 45 : 0))
                        }
                        .offset(y: -20)
                        .zIndex(120) // Higher than menu and tab bar
                        
                        TabButton(icon: "chart.bar.fill", label: Localization.string("tab_stats", lang: settings.appLanguage), isSelected: navManager.selectedMainTab == 2) { 
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) { navManager.selectedMainTab = 2 }
                        }
                        TabButton(icon: "person.fill", label: Localization.string("tab_profile", lang: settings.appLanguage), isSelected: navManager.selectedMainTab == 3) { 
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) { navManager.selectedMainTab = 3 }
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.top, 12)
                    .padding(.bottom, 8)
                    .background(
                        AppTheme.Colors.surface
                            .ignoresSafeArea(edges: .bottom)
                    )
                    .overlay(
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.1), Color.clear],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(height: 1),
                        alignment: .top
                    )
                }
                .transition(.move(edge: .bottom))
                .zIndex(100)
            }
            
            // Create Menu
            if navManager.showingCreateMenu {
                createMenuOverlay
            }
            
            // Deck Options Menu
            if navManager.showingDeckOptions, let deck = navManager.selectedDeckForOptions {
                deckOptionsOverlay(for: deck)
            }
        }
        .ignoresSafeArea(.keyboard)
        .sheet(item: $createType) { type in
            switch type {
            case .deck:
                CreateDeckView()
            case .folder:
                CreateFolderView()
            case .classRoom:
                CreateClassView()
            }
        }
        .sheet(item: $deckAction) { action in
            if let deck = navManager.selectedDeckForOptions {
                switch action {
                case .edit: EmptyView() // Handled by fullScreenCover
                case .addToClass: AddToClassView(deck: deck)
                case .addToFolder: AddToFolderView(deck: deck)
                case .info: DeckInfoView(deck: deck)
                case .share: ShareActivityView(text: String(format: Localization.string("deck_share_text", lang: settings.appLanguage), deck.title))
                }
            }
        }
        .fullScreenCover(isPresented: $showingEditView) {
            if let deck = navManager.selectedDeckForOptions {
                EditDeckView(deck: deck)
            }
        }
        .alert(Localization.string("deck_delete_title", lang: settings.appLanguage), isPresented: $showingDeleteAlert) {
            Button(Localization.string("common_cancel", lang: settings.appLanguage), role: .cancel) { }
            Button(Localization.string("common_delete", lang: settings.appLanguage), role: .destructive) {
                if let deck = navManager.selectedDeckForOptions {
                    modelContext.delete(deck)
                    navManager.selectedDeckForOptions = nil
                }
            }
        } message: {
            Text(Localization.string("deck_delete_msg", lang: settings.appLanguage))
        }
    }
    
    // MARK: - Overlays
    
    private var createMenuOverlay: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 0) {
                // Handle
                RoundedRectangle(cornerRadius: 3)
                    .fill(AppTheme.Colors.surfaceHighlight)
                    .frame(width: 40, height: 4)
                    .padding(.top, 12)
                    .padding(.bottom, 24)
                
                Text(Localization.string("common_create_new", lang: settings.appLanguage))
                    .font(AppTheme.font(.headline, weight: .bold))
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                    .padding(.bottom, 24)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        CreateOptionRow(title: Localization.string("lib_tab_decks", lang: settings.appLanguage), icon: "book.fill", color: AppTheme.Colors.primary) {
                            startCreation(.deck)
                        }
                        CreateOptionRow(title: Localization.string("lib_tab_folders", lang: settings.appLanguage), icon: "folder.fill", color: Color(hex: "3B82F6")) {
                            startCreation(.folder)
                        }
                        CreateOptionRow(title: Localization.string("lib_tab_classes", lang: settings.appLanguage), icon: "person.3.fill", color: Color(hex: "10B981")) {
                            startCreation(.classRoom)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 120) // Added more padding to ensure last item is scrollable above TabBar
                }
                .frame(maxHeight: 350) // Limit height so it doesn't take full screen
            }
            .background(AppTheme.Colors.surface)
            .clipShape(RoundedCorner(radius: 32, corners: [.topLeft, .topRight]))
            .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: -10)
        }
        .ignoresSafeArea(edges: .bottom)
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .zIndex(110) // Higher than Tab Bar background but lower than central button
    }
    
    private func deckOptionsOverlay(for deck: Deck) -> some View {
        VStack {
            Spacer()
            
            VStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(AppTheme.Colors.surfaceHighlight)
                    .frame(width: 40, height: 4)
                    .padding(.top, 12)
                    .padding(.bottom, 20)
                
                Text(Localization.string("deck_options_title", lang: settings.appLanguage))
                    .font(AppTheme.font(.headline, weight: .bold))
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                    .padding(.bottom, 20)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        OptionRow(title: Localization.string("deck_options_edit", lang: settings.appLanguage), icon: "pencil", color: .blue) {
                            startDeckAction(.edit)
}
                        OptionRow(title: Localization.string("deck_options_add_to_class", lang: settings.appLanguage), icon: "person.3.fill", color: Color(hex: "10B981")) {
                            startDeckAction(.addToClass)
                        }
                        OptionRow(title: Localization.string("deck_options_add_to_folder", lang: settings.appLanguage), icon: "folder.fill", color: Color(hex: "3B82F6")) {
                            startDeckAction(.addToFolder)
                        }
                        OptionRow(title: Localization.string("deck_options_duplicate", lang: settings.appLanguage), icon: "doc.on.doc.fill", color: .orange) {
                            duplicateDeck(deck)
                        }
                        OptionRow(title: Localization.string("deck_options_share", lang: settings.appLanguage), icon: "square.and.arrow.up.fill", color: .purple) {
                            startDeckAction(.share)
                        }
                        OptionRow(title: Localization.string("deck_options_info", lang: settings.appLanguage), icon: "info.circle.fill", color: .gray) {
                            startDeckAction(.info)
                        }
                        OptionRow(title: Localization.string("deck_options_delete", lang: settings.appLanguage), icon: "trash.fill", color: .red) {
                            withAnimation(.spring(response: 0.3)) {
                                navManager.showingDeckOptions = false
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                                showingDeleteAlert = true
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 120)
                }
                .frame(maxHeight: 520)
            }
            .background(AppTheme.Colors.surface)
            .clipShape(RoundedCorner(radius: 32, corners: [.topLeft, .topRight]))
            .shadow(color: .black.opacity(0.4), radius: 20, x: 0, y: -10)
        }
        .ignoresSafeArea(edges: .bottom)
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .zIndex(110)
    }
    
    // MARK: - Handlers
    
    private func startCreation(_ type: CreateType) {
        withAnimation(.spring(response: 0.3)) {
            navManager.showingCreateMenu = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            createType = type
        }
    }
    
    private func startDeckAction(_ action: DeckActionSheet) {
        withAnimation(.spring(response: 0.3)) {
            navManager.showingDeckOptions = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            if action == .edit {
                showingEditView = true
            } else {
                deckAction = action
            }
        }
    }
    
    private func duplicateDeck(_ deck: Deck) {
        AppTheme.haptic(.medium)
        let newDeck = Deck(
            title: "\(deck.title) (\(Localization.string("common_copy", lang: settings.appLanguage)))",
            emoji: deck.emoji,
            language: deck.language,
            colorHex: deck.colorHex
        )
        for card in deck.cards {
            let newCard = Card(front: card.front, back: card.back, pronunciation: card.pronunciation, example: card.example)
            newDeck.cards.append(newCard)
        }
        modelContext.insert(newDeck)
        withAnimation {
            navManager.showingDeckOptions = false
        }
    }
}

struct TabButton: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            AppTheme.haptic(.light)
            action()
        }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(label)
                    .font(AppTheme.font(.caption2, weight: .bold))
            }
            .foregroundStyle(isSelected ? AppTheme.Colors.primary : AppTheme.Colors.textSecondary)
            .frame(maxWidth: .infinity)
        }
    }
}
