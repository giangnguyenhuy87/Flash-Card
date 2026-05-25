import SwiftUI
import SwiftData

struct FolderDetailView: View {
    @Bindable var folder: Folder
    @Query(sort: \Folder.createdAt, order: .reverse) private var allFolders: [Folder]
    @Query(sort: \Deck.createdAt, order: .reverse) private var allDecks: [Deck]
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var navManager: NavigationManager
    @EnvironmentObject var settings: AppSettings
    
    @State private var showingCreateAction = false
    @State private var createType: CreateType? = nil
    
    enum CreateType: Identifiable {
        case deck, folder
        var id: Self { self }
    }
    
    // Sub-folders and decks in this specific folder
    var subfolders: [Folder] {
        folder.subfolders.sorted { $0.createdAt > $1.createdAt }
    }
    
    var decks: [Deck] {
        folder.decks.sorted { $0.createdAt > $1.createdAt }
    }
    
    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Folder Header
                VStack(spacing: 12) {
                    Text(folder.emoji)
                        .font(.system(size: 80))
                    
                    Text(folder.name)
                        .font(AppTheme.font(.title, weight: .black))
                        .foregroundStyle(.white)
                }
                .padding(.vertical, 32)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        // Sub-folders Section
                        if !subfolders.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                Text(Localization.string("folder_subfolders_title", lang: settings.appLanguage))
                                    .font(AppTheme.font(.headline, weight: .bold))
                                    .foregroundStyle(.white)
                                
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                    ForEach(subfolders) { sub in
                                        NavigationLink(destination: FolderDetailView(folder: sub)) {
                                            FolderCard(folder: sub)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            }
                        }
                        
                        // Decks Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text(Localization.string("lib_tab_decks", lang: settings.appLanguage))
                                .font(AppTheme.font(.headline, weight: .bold))
                                .foregroundStyle(.white)
                            
                            if decks.isEmpty && subfolders.isEmpty {
                                emptyState
                            } else if decks.isEmpty {
                                Text(Localization.string("folder_empty_msg", lang: settings.appLanguage))
                                    .font(AppTheme.font(.caption))
                                    .foregroundStyle(AppTheme.Colors.textSecondary)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.vertical, 20)
                            } else {
                                LazyVStack(spacing: 16) {
                                    ForEach(decks) { deck in
                                        NavigationLink(destination: DeckDetailView(deck: deck)) {
                                            EnhancedDeckCard(deck: deck)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 100)
                }
            }
            
            // Add Button (Local to this folder)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        AppTheme.haptic(.medium)
                        showingCreateAction = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title2.bold())
                            .foregroundStyle(.white)
                            .frame(width: 60, height: 60)
                            .background(AppTheme.Colors.primaryGradient)
                            .clipShape(Circle())
                            .shadow(color: AppTheme.Colors.primary.opacity(0.4), radius: 15, x: 0, y: 8)
                    }
                    .padding(24)
                }
            }
            
            // Custom Create Menu Overlay
            if showingCreateAction {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation { showingCreateAction = false }
                    }
                
                VStack {
                    Spacer()
                    VStack(spacing: 0) {
                        RoundedRectangle(cornerRadius: 3).fill(AppTheme.Colors.surfaceHighlight).frame(width: 40, height: 4).padding(.vertical, 12)
                        let addToText = String(format: Localization.string("folder_add_to", lang: settings.appLanguage), folder.name)
                        Text(addToText).font(AppTheme.font(.headline, weight: .bold)).foregroundStyle(.white).padding(.bottom, 24)
                        
                        VStack(spacing: 12) {
                            CreateOptionRow(title: Localization.string("folder_new_deck", lang: settings.appLanguage), icon: "book.fill", color: AppTheme.Colors.primary) {
                                startCreation(.deck)
                            }
                            CreateOptionRow(title: Localization.string("folder_new_subfolder", lang: settings.appLanguage), icon: "folder.fill", color: Color(hex: "3B82F6")) {
                                startCreation(.folder)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                    }
                    .background(AppTheme.Colors.surface)
                    .clipShape(RoundedCorner(radius: 32, corners: [.topLeft, .topRight]))
                    .transition(.move(edge: .bottom))
                }
                .ignoresSafeArea(edges: .bottom)
                .zIndex(100)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $createType) { type in
            switch type {
            case .deck:
                CreateDeckView(targetFolder: folder)
            case .folder:
                CreateFolderView(parentFolder: folder)
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
    
    private func startCreation(_ type: CreateType) {
        withAnimation {
            showingCreateAction = false
            createType = type
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "folder.badge.questionmark")
                .font(.largeTitle)
                .foregroundStyle(AppTheme.Colors.textSecondary.opacity(0.2))
            Text(Localization.string("folder_empty_title", lang: settings.appLanguage))
                .font(AppTheme.font(.caption))
                .foregroundStyle(AppTheme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 32))
    }
}
