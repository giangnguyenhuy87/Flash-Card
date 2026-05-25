import SwiftUI
import SwiftData

struct DeckListView: View {
    @Query(sort: \Deck.createdAt, order: .reverse) private var decks: [Deck]
    @Environment(\.modelContext) private var modelContext
    
    @State private var searchText = ""
    @State private var selectedFilter: DeckFilter = .all
    @State private var showingCreateDeck = false
    @State private var viewMode: ViewMode = .list
    @State private var editingDeck: Deck? = nil
    @State private var showingShareSheet = false
    @State private var shareText = ""
    
    enum ViewMode {
        case list, grid
    }
    
    enum DeckFilter: String, CaseIterable {
        case all = "All"
        case japanese = "Japanese"
        case english = "English"
        case korean = "Korean"
        case french = "French"
        
        var icon: String {
            switch self {
            case .all: return "square.stack.3d.up.fill"
            case .japanese: return "🇯🇵"
            case .english: return "🇬🇧"
            case .korean: return "🇰🇷"
            case .french: return "🇫🇷"
            }
        }
    }
    
    var filteredDecks: [Deck] {
        var result = decks
        
        // Apply search filter
        if !searchText.isEmpty {
            result = result.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
        
        // Apply language filter
        if selectedFilter != .all {
            result = result.filter { $0.language.lowercased() == selectedFilter.rawValue.lowercased() }
        }
        
        return result
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search Bar
                    searchBarView
                    
                    // Filter Chips
                    filterChipsView
                    
                    // Content
                    ScrollView(showsIndicators: false) {
                        if filteredDecks.isEmpty {
                            emptyStateView
                        } else {
                            if viewMode == .list {
                                listView
                            } else {
                                gridView
                            }
                        }
                    }
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("My Decks")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 12) {
                        // View Mode Toggle
                        Button(action: {
                            AppTheme.haptic(.light)
                            withAnimation(.spring(response: 0.3)) {
                                viewMode = viewMode == .list ? .grid : .list
                            }
                        }) {
                            Image(systemName: viewMode == .list ? "square.grid.2x2" : "list.bullet")
                                .font(.title3)
                                .foregroundStyle(AppTheme.Colors.textSecondary)
                        }
                        
                        // Add Button
                        Button(action: {
                            AppTheme.haptic(.medium)
                            showingCreateDeck = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundStyle(AppTheme.Colors.primaryGradient)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingCreateDeck) {
                CreateDeckView()
            }
            .sheet(item: $editingDeck) { deck in
                EditDeckView(deck: deck)
            }
            .sheet(isPresented: $showingShareSheet) {
                ShareActivityView(text: shareText)
            }
        }
    }
    
    // MARK: - Search Bar
    
    private var searchBarView: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(AppTheme.Colors.textSecondary)
            
            TextField("Search decks...", text: $searchText)
                .font(AppTheme.font(.body))
                .foregroundStyle(.white)
                .autocorrectionDisabled()
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
            }
        }
        .padding(16)
        .background(AppTheme.Colors.surface)
        .clipShape(Capsule())
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
    }
    
    // MARK: - Filter Chips
    
    private var filterChipsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(DeckFilter.allCases, id: \.self) { filter in
                    DeckFilterChip(
                        title: filter.rawValue,
                        icon: filter.icon,
                        isSelected: selectedFilter == filter
                    ) {
                        AppTheme.haptic(.light)
                        withAnimation(.spring(response: 0.3)) {
                            selectedFilter = filter
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
        }
        .padding(.bottom, 16)
    }
    
    // MARK: - List View
    
    private var listView: some View {
        LazyVStack(spacing: 16) {
            ForEach(filteredDecks) { deck in
                NavigationLink(destination: DeckDetailView(deck: deck)) {
                    DeckListCard(deck: deck)
                }
                .buttonStyle(PlainButtonStyle())
                .contextMenu {
                    Button(action: { editDeck(deck) }) {
                        Label("Edit", systemImage: "pencil")
                    }
                    Button(action: { shareDeck(deck) }) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                    Button(role: .destructive, action: { deleteDeck(deck) }) {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
    }
    
    // MARK: - Grid View
    
    private var gridView: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ], spacing: 16) {
            ForEach(filteredDecks) { deck in
                NavigationLink(destination: DeckDetailView(deck: deck)) {
                    DeckGridCard(deck: deck)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: searchText.isEmpty ? "tray" : "magnifyingglass")
                .font(.system(size: 48))
                .foregroundStyle(AppTheme.Colors.textSecondary.opacity(0.5))
            
            VStack(spacing: 8) {
                Text(searchText.isEmpty ? "No decks yet" : "No results found")
                    .font(AppTheme.font(.title3, weight: .bold))
                    .foregroundStyle(.white)
                
                Text(searchText.isEmpty ? "Create your first deck to get started" : "Try a different search term")
                    .font(AppTheme.font(.subheadline))
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
            
            if searchText.isEmpty {
                Button(action: { showingCreateDeck = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Create Deck")
                    }
                    .font(AppTheme.font(.headline, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .background(AppTheme.Colors.primaryGradient)
                    .clipShape(Capsule())
                    .shadow(color: AppTheme.Colors.primary.opacity(0.4), radius: 15, x: 0, y: 8)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 100)
    }
    
    // MARK: - Actions
    
    func editDeck(_ deck: Deck) {
        AppTheme.haptic(.light)
        editingDeck = deck
    }
    
    func shareDeck(_ deck: Deck) {
        AppTheme.haptic(.medium)
        shareText = "Check out my vocabulary deck '\(deck.title)' with \(deck.activeCardsCount) cards!"
        showingShareSheet = true
    }
    
    func deleteDeck(_ deck: Deck) {
        AppTheme.haptic(.medium)
        withAnimation {
            modelContext.delete(deck)
        }
    }
}

// MARK: - Supporting Views

struct DeckFilterChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if icon.count == 2 { // Emoji
                    Text(icon)
                        .font(.caption)
                } else {
                    Image(systemName: icon)
                        .font(.caption)
                }
                
                Text(title)
                    .font(AppTheme.font(.subheadline, weight: .semibold))
            }
            .foregroundStyle(isSelected ? .white : AppTheme.Colors.textSecondary)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                isSelected
                    ? AppTheme.Colors.primaryGradient
                    : LinearGradient(colors: [AppTheme.Colors.surface], startPoint: .leading, endPoint: .trailing)
            )
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.clear : AppTheme.Colors.surfaceHighlight, lineWidth: 1)
            )
            .shadow(color: isSelected ? AppTheme.Colors.primary.opacity(0.3) : Color.clear, radius: 8, x: 0, y: 4)
        }
    }
}

struct DeckListCard: View {
    let deck: Deck
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: deck.colorHex).opacity(0.3),
                                Color(hex: deck.colorHex).opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 64, height: 64)
                
                Text(deck.emoji)
                    .font(.system(size: 28))
            }
            
            // Content
            VStack(alignment: .leading, spacing: 6) {
                Text(deck.title)
                    .font(AppTheme.font(.headline, weight: .bold))
                    .foregroundStyle(.white)
                
                HStack(spacing: 12) {
                    Label("\(deck.activeCardsCount)", systemImage: "square.stack.3d.up.fill")
                    
                    if deck.dueCardsCount > 0 {
                        Label("\(deck.dueCardsCount) due", systemImage: "clock.fill")
                            .foregroundStyle(Color(hex: "F59E0B"))
                    }
                }
                .font(AppTheme.font(.caption, weight: .medium))
                .foregroundStyle(AppTheme.Colors.textSecondary)
            }
            
            Spacer()
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.subheadline.bold())
                .foregroundStyle(AppTheme.Colors.textSecondary.opacity(0.5))
        }
        .padding(20)
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
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}

struct DeckGridCard: View {
    let deck: Deck
    
    var body: some View {
        VStack(spacing: 12) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: deck.colorHex).opacity(0.3),
                                Color(hex: deck.colorHex).opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 100)
                
                Text(deck.emoji)
                    .font(.system(size: 40))
            }
            
            // Content
            VStack(alignment: .leading, spacing: 6) {
                Text(deck.title)
                    .font(AppTheme.font(.subheadline, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                
                HStack(spacing: 8) {
                    Label("\(deck.activeCardsCount)", systemImage: "square.stack.3d.up.fill")
                    
                    if deck.dueCardsCount > 0 {
                        Text("•")
                        Text("\(deck.dueCardsCount)")
                            .foregroundStyle(Color(hex: "F59E0B"))
                    }
                }
                .font(AppTheme.font(.caption2, weight: .medium))
                .foregroundStyle(AppTheme.Colors.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
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
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}
