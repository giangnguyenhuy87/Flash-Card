import SwiftUI
import SwiftData

struct LibraryView: View {
    @Query(sort: \Deck.createdAt, order: .reverse) private var decks: [Deck]
    @Query(sort: \ClassRoom.createdAt, order: .reverse) private var classes: [ClassRoom]
    @Query(sort: \Folder.createdAt, order: .reverse) private var folders: [Folder]
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var navManager: NavigationManager
    @EnvironmentObject var settings: AppSettings
    
    @State private var createType: CreateType? = nil
    
    enum LibraryTab: Int, CaseIterable {
        case courses = 0
        case mockTests = 1
        case classes = 2
        case folders = 3
        
        var icon: String {
            switch self {
            case .courses: return "book.fill"
            case .mockTests: return "doc.text.fill"
            case .classes: return "person.3.fill"
            case .folders: return "folder.fill"
            }
        }
    }
    
    enum CreateType: Identifiable {
        case deck, folder, classRoom
        var id: Self { self }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Standardized Header
                    AppTheme.Header(title: Localization.string("tab_library", lang: settings.appLanguage)) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            navManager.showingCreateMenu.toggle()
                        }
                    }
                    
                    // Custom Category Picker
                    categoryPicker
                        .padding(.top, -8)
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {
                            switch LibraryTab.allCases[navManager.libraryInitialTab] {
                            case .courses:
                                courseListView
                            case .mockTests:
                                mockTestListView
                            case .classes:
                                classListView
                            case .folders:
                                folderListView
                            }
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationBarHidden(true)
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
        }
    }
    
    private func startCreation(_ type: CreateType) {
        AppTheme.haptic(.light)
        withAnimation(.spring(response: 0.3)) {
            navManager.showingCreateMenu = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            createType = type
        }
    }
    
    // MARK: - Category Picker
    
    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(LibraryTab.allCases, id: \.self) { tab in
                    Button(action: {
                        AppTheme.haptic(.light)
                        withAnimation(.spring(response: 0.3)) {
                            navManager.libraryInitialTab = LibraryTab.allCases.firstIndex(of: tab) ?? 0
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: tab.icon)
                                .font(.system(size: 14))
                            
                            let tabLabel: String = {
                                switch tab {
                                case .courses: return Localization.string("lib_tab_decks", lang: settings.appLanguage)
                                case .mockTests: return Localization.string("lib_tab_tests", lang: settings.appLanguage)
                                case .classes: return Localization.string("lib_tab_classes", lang: settings.appLanguage)
                                case .folders: return Localization.string("lib_tab_folders", lang: settings.appLanguage)
                                }
                            }()
                            
                            Text(tabLabel)
                                .font(AppTheme.font(.subheadline, weight: .semibold))
                        }
                        .foregroundStyle(LibraryTab.allCases[navManager.libraryInitialTab] == tab ? .white : AppTheme.Colors.textPrimary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            LibraryTab.allCases[navManager.libraryInitialTab] == tab
                            ? AppTheme.Colors.primaryGradient
                            : LinearGradient(colors: [AppTheme.Colors.surface], startPoint: .leading, endPoint: .trailing)
                        )
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(LibraryTab.allCases[navManager.libraryInitialTab] == tab ? Color.clear : AppTheme.Colors.surfaceHighlight, lineWidth: 1)
                        )
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
        }
    }
    
    // MARK: - Sub-views
    
    private var courseListView: some View {
        Group {
            // Only show decks that NOT in any folder at the top level
            let topLevelDecks = decks.filter { $0.folder == nil }
            
            if topLevelDecks.isEmpty {
                VStack(spacing: 16) {
                    emptyStateView(icon: "book.closed.fill", title: Localization.string("lib_empty_decks", lang: settings.appLanguage))
                    
                    VStack(spacing: 12) {
                        Button(action: { startCreation(.deck) }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text(Localization.string("deck_create_new_title", lang: settings.appLanguage))
                            }
                            .font(AppTheme.font(.headline, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: 280)
                            .padding(.vertical, 16)
                            .background(AppTheme.Colors.primaryGradient)
                            .clipShape(Capsule())
                        }
                        
                        Button(action: { startCreation(.folder) }) {
                            HStack {
                                Image(systemName: "folder.badge.plus")
                                Text(Localization.string("lib_tab_folders", lang: settings.appLanguage))
                            }
                            .font(AppTheme.font(.subheadline, weight: .semibold))
                            .foregroundStyle(AppTheme.Colors.textPrimary)
                            .frame(maxWidth: 280)
                            .padding(.vertical, 14)
                            .background(AppTheme.Colors.surface)
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(AppTheme.Colors.surfaceHighlight, lineWidth: 1))
                        }
                        
                        Button(action: { startCreation(.classRoom) }) {
                            HStack {
                                Image(systemName: "person.3.fill")
                                Text(Localization.string("lib_create_class", lang: settings.appLanguage))
                            }
                            .font(AppTheme.font(.subheadline, weight: .semibold))
                            .foregroundStyle(AppTheme.Colors.textPrimary)
                            .frame(maxWidth: 280)
                            .padding(.vertical, 14)
                            .background(AppTheme.Colors.surface)
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(AppTheme.Colors.surfaceHighlight, lineWidth: 1))
                        }
                    }
                }
                .padding(.top, 40)
            } else {
                LazyVStack(spacing: 16) {
                    ForEach(topLevelDecks) { deck in
                        NavigationLink(destination: DeckDetailView(deck: deck)) {
                            EnhancedDeckCard(deck: deck)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    // Add Button at the end of the list
                    Button(action: { startCreation(.deck) }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text(Localization.string("deck_create_new_title", lang: settings.appLanguage))
                        }
                        .font(AppTheme.font(.headline, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppTheme.Colors.primaryGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal, 24)
            }
        }
    }
    
    private var mockTestListView: some View {
        VStack(spacing: 24) {
            Image(systemName: "safari.fill")
                .font(.system(size: 60))
                .foregroundStyle(AppTheme.Colors.primaryGradient)
            
            VStack(spacing: 12) {
                Text(Localization.string("lib_tab_tests", lang: settings.appLanguage))
                    .font(AppTheme.font(.title3, weight: .bold))
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                
                Text(Localization.string("lib_browser_access", lang: settings.appLanguage))
                    .font(AppTheme.font(.subheadline))
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: {
                if let url = URL(string: "https://www.google.com") {
                    UIApplication.shared.open(url)
                }
            }) {
                HStack {
                    Image(systemName: "globe")
                    Text(Localization.string("lib_open_browser", lang: settings.appLanguage))
                }
                .font(AppTheme.font(.headline, weight: .bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .background(AppTheme.Colors.primaryGradient)
                .clipShape(Capsule())
            }
        }
        .padding(.top, 60)
    }
    
    private var classListView: some View {
        Group {
            if classes.isEmpty {
                VStack(spacing: 24) {
                    emptyStateView(icon: "person.3.fill", title: Localization.string("home_classes", lang: settings.appLanguage))
                    
                    Button(action: { startCreation(.classRoom) }) {
                        Text(Localization.string("lib_create_class", lang: settings.appLanguage))
                            .font(AppTheme.font(.headline, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 16)
                            .background(AppTheme.Colors.primaryGradient)
                            .clipShape(Capsule())
                    }
                    
                    Button(action: { 
                        // logic for joining a class via code could go here
                    }) {
                        Text(Localization.string("lib_join_with_code", lang: settings.appLanguage))
                            .font(AppTheme.font(.subheadline, weight: .semibold))
                            .foregroundStyle(AppTheme.Colors.textSecondary)
                    }
                }
            } else {
                LazyVStack(spacing: 16) {
                    ForEach(classes) { classRoom in
                        NavigationLink(destination: ClassDetailView(classRoom: classRoom)) {
                            ClassCard(classRoom: classRoom)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 24)
            }
        }
    }
    
    private var folderListView: some View {
        Group {
            // ONLY show Root folders (those without a parent)
            let rootFolders = folders.filter { $0.parentFolder == nil }
            
            if rootFolders.isEmpty {
                VStack(spacing: 16) {
                    emptyStateView(icon: "folder.fill", title: Localization.string("lib_tab_folders", lang: settings.appLanguage))
                    
                    VStack(spacing: 12) {
                        Button(action: { startCreation(.folder) }) {
                            HStack {
                                Image(systemName: "folder.badge.plus")
                                Text(Localization.string("folder_create_new_title", lang: settings.appLanguage))
                            }
                            .font(AppTheme.font(.headline, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: 280)
                            .padding(.vertical, 16)
                            .background(AppTheme.Colors.primaryGradient)
                            .clipShape(Capsule())
                        }
                    }
                }
                .padding(.top, 40)
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(rootFolders) { folder in
                        NavigationLink(destination: FolderDetailView(folder: folder)) {
                            FolderCard(folder: folder)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 24)
            }
        }
    }
    
    private func emptyStateView(icon: String, title: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundStyle(AppTheme.Colors.textSecondary.opacity(0.3))
            
            Text(title)
                .font(AppTheme.font(.subheadline, weight: .medium))
                .foregroundStyle(AppTheme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 100)
    }
}

