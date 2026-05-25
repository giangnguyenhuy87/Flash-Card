import SwiftUI
import SwiftData

struct WordListView: View {
    @Bindable var deck: Deck
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var navManager: NavigationManager
    @EnvironmentObject var settings: AppSettings
    
    @State private var searchText = ""
    @State private var selectedFilter: CardFilter = .all
    @State private var showingAddWord = false
    @State private var sortOrder: SortOrder = .again
    @State private var showingSortPicker = false
    @State private var editingCard: Card? = nil
    
    enum CardFilter: String, CaseIterable {
        case all, new, learning, mastered
        
        func label(lang: String) -> String {
            switch self {
            case .all: return Localization.string("word_list_filter_all", lang: lang)
            case .new: return Localization.string("word_list_filter_new", lang: lang)
            case .learning: return Localization.string("word_list_filter_learning", lang: lang)
            case .mastered: return Localization.string("word_list_filter_mastered", lang: lang)
            }
        }
        
        var icon: String {
            switch self {
            case .all: return "square.stack.3d.up.fill"
            case .new: return "sparkles"
            case .learning: return "brain.head.profile"
            case .mastered: return "checkmark.seal.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .all: return Color(hex: "6366F1")
            case .new: return Color(hex: "3B82F6")
            case .learning: return Color(hex: "F59E0B")
            case .mastered: return Color(hex: "10B981")
            }
        }
    }
    
    enum SortOrder: String, CaseIterable {
        case again, hard, easy, alphabetical
        
        func label(lang: String) -> String {
            switch self {
            case .again: return Localization.string("word_list_sort_again", lang: lang)
            case .hard: return Localization.string("word_list_sort_hard", lang: lang)
            case .easy: return Localization.string("word_list_sort_easy", lang: lang)
            case .alphabetical: return Localization.string("word_list_sort_alphabetical", lang: lang)
            }
        }
        
        var icon: String {
            switch self {
            case .again: return "exclamationmark.circle"
            case .hard: return "bolt.trianglebadge.exclamationmark"
            case .easy: return "star.fill"
            case .alphabetical: return "textformat"
            }
        }
    }
    
    var filteredCards: [Card] {
        var result = deck.cards
        
        // Search filter
        if !searchText.isEmpty {
            result = result.filter {
                $0.front.localizedCaseInsensitiveContains(searchText) ||
                $0.back.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Status filter
        switch selectedFilter {
        case .all:
            break
        case .new:
            result = result.filter { $0.streak == 0 }
        case .learning:
            result = result.filter { $0.streak > 0 && $0.streak < 5 }
        case .mastered:
            result = result.filter { $0.streak >= 5 }
        }
        
        // Sort
        switch sortOrder {
        case .again:
            // Put 'again' cards first
            result = result.sorted {
                let firstIsAgain = $0.lastDifficulty == "again" ? 0 : 1
                let secondIsAgain = $1.lastDifficulty == "again" ? 0 : 1
                return firstIsAgain < secondIsAgain
            }
        case .hard:
            // Put 'hard' cards first
            result = result.sorted {
                let firstIsHard = $0.lastDifficulty == "hard" ? 0 : 1
                let secondIsHard = $1.lastDifficulty == "hard" ? 0 : 1
                return firstIsHard < secondIsHard
            }
        case .easy:
            // Put 'easy' or 'good' cards first (Mastered ones)
            result = result.sorted {
                let score1 = ($0.lastDifficulty == "easy" ? 0 : ($0.lastDifficulty == "good" ? 1 : 2))
                let score2 = ($1.lastDifficulty == "easy" ? 0 : ($1.lastDifficulty == "good" ? 1 : 2))
                return score1 < score2
            }
        case .alphabetical:
            result = result.sorted { $0.front < $1.front }
        }
        
        return result
    }
    
    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header Stats
                headerStatsView
                
                // Search Bar
                searchBarView
                
                // Filter & Sort
                HStack(spacing: 12) {
                    // Filter Chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(CardFilter.allCases, id: \.self) { filter in
                                FilterChip(
                                    title: filter.label(lang: settings.appLanguage),
                                    icon: filter.icon,
                                    color: filter.color,
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
                    
                    // Custom Premium Sort Button
                    Button(action: {
                        AppTheme.haptic(.medium)
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            showingSortPicker = true
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: sortOrder.icon)
                                .font(.system(size: 14))
                            Image(systemName: "chevron.down")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundStyle(AppTheme.Colors.primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(AppTheme.Colors.surface)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(AppTheme.Colors.surfaceHighlight, lineWidth: 1)
                        )
                    }
                    .padding(.trailing, 24)
                }
                .padding(.bottom, 16)
                
                // Word List
                ScrollView(showsIndicators: false) {
                    if filteredCards.isEmpty {
                        emptyStateView
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredCards) { card in
                                WordCard(card: card)
                                    .contextMenu {
                                        Button(action: { editCard(card) }) {
                                            Label(Localization.string("common_edit", lang: settings.appLanguage), systemImage: "pencil")
                                        }
                                        Button(role: .destructive, action: { deleteCard(card) }) {
                                            Label(Localization.string("common_delete", lang: settings.appLanguage), systemImage: "trash")
                                        }
                                    }
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                }
                .padding(.bottom, 100)
            }
            
            // Floating Add Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        AppTheme.haptic(.medium)
                        showingAddWord = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title2.bold())
                            .foregroundStyle(.white)
                            .frame(width: 64, height: 64)
                            .background(AppTheme.Colors.primaryGradient)
                            .clipShape(Circle())
                            .shadow(color: AppTheme.Colors.primary.opacity(0.5), radius: 20, x: 0, y: 10)
                    }
                    .padding(.trailing, 24)
                    .padding(.bottom, 120)
                }
            }
            
            // Custom Sort Picker Overlay
            if showingSortPicker {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            showingSortPicker = false
                        }
                    }
                
                VStack {
                    Spacer()
                    
                    VStack(spacing: 0) {
                        // Handle bar
                        RoundedRectangle(cornerRadius: 3)
                            .fill(AppTheme.Colors.surfaceHighlight)
                            .frame(width: 40, height: 6)
                            .padding(.top, 12)
                            .padding(.bottom, 20)
                        
                        Text(Localization.string("word_list_sort_title", lang: settings.appLanguage))
                            .font(AppTheme.font(.headline, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.bottom, 24)
                        
                        VStack(spacing: 12) {
                            ForEach(SortOrder.allCases, id: \.self) { order in
                                SortOptionRow(
                                    order: order,
                                    label: order.label(lang: settings.appLanguage),
                                    isSelected: sortOrder == order
                                ) {
                                    AppTheme.haptic(.light)
                                    withAnimation {
                                        sortOrder = order
                                        showingSortPicker = false
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                    }
                    .background(AppTheme.Colors.surface)
                    .clipShape(RoundedCorner(radius: 32, corners: [.topLeft, .topRight]))
                    .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: -10)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .ignoresSafeArea(edges: .bottom)
            }
        }
        .navigationTitle(deck.title)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingAddWord) {
            AddWordView(deck: deck)
        }
        .sheet(item: $editingCard) { card in
            EditWordView(card: card)
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
    
    // MARK: - Header Stats
    
    private var headerStatsView: some View {
        HStack(spacing: 16) {
            StatBadge(
                value: "\(deck.cards.count)",
                label: Localization.string("word_list_stat_total", lang: settings.appLanguage),
                color: Color(hex: "6366F1")
            )
            
            StatBadge(
                value: "\(deck.cards.filter { $0.streak == 0 }.count)",
                label: Localization.string("word_list_filter_new", lang: settings.appLanguage),
                color: Color(hex: "3B82F6")
            )
            
            StatBadge(
                value: "\(deck.cards.filter { $0.streak > 0 && $0.streak < 5 }.count)",
                label: Localization.string("word_list_filter_learning", lang: settings.appLanguage),
                color: Color(hex: "F59E0B")
            )
            
            StatBadge(
                value: "\(deck.cards.filter { $0.streak >= 5 }.count)",
                label: Localization.string("word_list_filter_mastered", lang: settings.appLanguage),
                color: Color(hex: "10B981")
            )
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
    }
    
    // MARK: - Search Bar
    
    private var searchBarView: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(AppTheme.Colors.textSecondary)
            
            TextField(Localization.string("word_list_search_placeholder", lang: settings.appLanguage), text: $searchText)
                .font(AppTheme.font(.body))
                .foregroundStyle(.white)
                .autocorrectionDisabled()
            
            if !searchText.isEmpty {
                Button(action: {
                    AppTheme.haptic(.light)
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
            }
        }
        .padding(16)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 24)
        .padding(.bottom, 16)
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: searchText.isEmpty ? "doc.text" : "magnifyingglass")
                .font(.system(size: 48))
                .foregroundStyle(AppTheme.Colors.textSecondary.opacity(0.5))
            
            VStack(spacing: 8) {
                Text(searchText.isEmpty ? Localization.string("word_list_empty_title", lang: settings.appLanguage) : Localization.string("word_list_not_found_title", lang: settings.appLanguage))
                    .font(AppTheme.font(.title3, weight: .bold))
                    .foregroundStyle(.white)
                
                Text(searchText.isEmpty ? Localization.string("word_list_empty_msg", lang: settings.appLanguage) : Localization.string("word_list_not_found_msg", lang: settings.appLanguage))
                    .font(AppTheme.font(.subheadline))
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 100)
    }
    
    // MARK: - Actions
    
    func editCard(_ card: Card) {
        AppTheme.haptic(.light)
        editingCard = card
    }
    
    func deleteCard(_ card: Card) {
        AppTheme.haptic(.medium)
        withAnimation {
            modelContext.delete(card)
        }
    }
}

// MARK: - Supporting Views

struct StatBadge: View {
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(AppTheme.font(.title3, weight: .black))
                .foregroundStyle(color)
            
            Text(label)
                .font(AppTheme.font(.caption2, weight: .medium))
                .foregroundStyle(AppTheme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct FilterChip: View {
    let title: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(AppTheme.font(.subheadline, weight: .semibold))
            }
            .foregroundStyle(isSelected ? .white : AppTheme.Colors.textSecondary)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                isSelected
                    ? LinearGradient(colors: [color, color.opacity(0.8)], startPoint: .leading, endPoint: .trailing)
                    : LinearGradient(colors: [AppTheme.Colors.surface], startPoint: .leading, endPoint: .trailing)
            )
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.clear : AppTheme.Colors.surfaceHighlight, lineWidth: 1)
            )
            .shadow(color: isSelected ? color.opacity(0.3) : Color.clear, radius: 8, x: 0, y: 4)
        }
    }
}

struct WordCard: View {
    @EnvironmentObject var settings: AppSettings
    let card: Card
    
    var statusColor: Color {
        if card.streak == 0 {
            return Color(hex: "3B82F6") // New
        } else if card.streak < 5 {
            return Color(hex: "F59E0B") // Learning
        } else {
            return Color(hex: "10B981") // Mastered
        }
    }
    
    var statusLabel: String {
        if card.streak == 0 {
            return Localization.string("word_list_filter_new", lang: settings.appLanguage)
        } else if card.streak < 5 {
            return Localization.string("word_list_filter_learning", lang: settings.appLanguage)
        } else {
            return Localization.string("word_list_filter_mastered", lang: settings.appLanguage)
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Status Indicator
            VStack(spacing: 4) {
                Circle()
                    .fill(statusColor)
                    .frame(width: 12, height: 12)
                
                Text("\(card.streak)")
                    .font(AppTheme.font(.caption2, weight: .bold))
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                Text(card.front)
                    .font(AppTheme.font(.headline, weight: .bold))
                    .foregroundStyle(.white)
                
                Text(card.back)
                    .font(AppTheme.font(.subheadline))
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                
                if let pronunciation = card.pronunciation {
                    HStack(spacing: 6) {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.caption2)
                        Text(pronunciation)
                            .font(AppTheme.font(.caption, weight: .medium))
                    }
                    .foregroundStyle(AppTheme.Colors.primary)
                }
                
                if let example = card.example {
                    Text(example)
                        .font(AppTheme.font(.caption))
                        .foregroundStyle(AppTheme.Colors.textSecondary.opacity(0.7))
                        .italic()
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            // Status Badge
            VStack(alignment: .trailing, spacing: 4) {
                // Main Status Badge (New, Learning, Mastered)
                HStack(spacing: 4) {
                    Image(systemName: card.streak >= 5 ? "checkmark.seal.fill" : "brain.head.profile")
                    Text(statusLabel)
                }
                .font(AppTheme.font(.caption2, weight: .semibold))
                .foregroundStyle(statusColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(statusColor.opacity(0.1))
                .clipShape(Capsule())
                
                // Last Choice Badge (Again, Hard, Good, Easy)
                if let lastDiff = card.lastDifficulty {
                    Group {
                        switch lastDiff {
                        case "again":
                            Text(Localization.string("study_again", lang: settings.appLanguage))
                                .foregroundStyle(AppTheme.Colors.error)
                                .background(AppTheme.Colors.error.opacity(0.1))
                        case "hard":
                            Text(Localization.string("study_hard", lang: settings.appLanguage))
                                .foregroundStyle(AppTheme.Colors.warning)
                                .background(AppTheme.Colors.warning.opacity(0.1))
                        case "good":
                            Text(Localization.string("study_good", lang: settings.appLanguage))
                                .foregroundStyle(AppTheme.Colors.secondary)
                                .background(AppTheme.Colors.secondary.opacity(0.1))
                        case "easy":
                            Text(Localization.string("study_easy", lang: settings.appLanguage))
                                .foregroundStyle(AppTheme.Colors.success)
                                .background(AppTheme.Colors.success.opacity(0.1))
                        default:
                            EmptyView()
                        }
                    }
                    .font(AppTheme.font(.caption2, weight: .bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .clipShape(Capsule())
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppTheme.Colors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
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
        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
    }
}

struct SortOptionRow: View {
    let order: WordListView.SortOrder
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(isSelected ? AppTheme.Colors.primary.opacity(0.1) : AppTheme.Colors.surfaceHighlight.opacity(0.5))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: order.icon)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(isSelected ? AppTheme.Colors.primary : AppTheme.Colors.textSecondary)
                }
                
                Text(label)
                    .font(AppTheme.font(.body, weight: isSelected ? .bold : .medium))
                    .foregroundStyle(isSelected ? .white : AppTheme.Colors.textSecondary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(AppTheme.Colors.primary)
                        .font(.system(size: 20))
                }
            }
            .padding(12)
            .background(isSelected ? AppTheme.Colors.primary.opacity(0.05) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? AppTheme.Colors.primary.opacity(0.3) : Color.clear, lineWidth: 1)
            )
        }
    }
}


