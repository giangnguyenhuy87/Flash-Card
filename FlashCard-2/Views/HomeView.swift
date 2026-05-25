import SwiftUI
import SwiftData

struct HomeView: View {
    @Query(sort: \Deck.createdAt, order: .reverse) private var decks: [Deck]
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddDeck = false
    @State private var streakPulse = false
    @Query(sort: \ClassRoom.createdAt, order: .reverse) private var classes: [ClassRoom]
    @EnvironmentObject var navManager: NavigationManager
    @EnvironmentObject var settings: AppSettings
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.background.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 30) {
                        // Header
                        headerView
                        
                        // Hero Streak Section
                        streakHeroView
                        
                        // Quick Actions
                        quickActionsView
                        
                        // Continue Learning Section
                        continueLearningSection
                        
                        // Recent Section
                        recentSection
                        
                        // My Classes Section
                        myClassesSection
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 100) // Space for TabBar
                }
            }
        }
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text(greetingText())
                    .font(AppTheme.font(.caption, weight: .medium))
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                
                Text("LuminaCards")
                    .font(AppTheme.font(.title3, weight: .black))
                    .foregroundStyle(AppTheme.Colors.textPrimary)
            }
            
            Spacer()
            
            // Avatar with Progress Ring - Click to Profile
            Button(action: {
                AppTheme.haptic(.medium)
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    navManager.selectedMainTab = 3 // Switch to Profile Tab
                }
            }) {
                ZStack {
                    Circle()
                        .stroke(AppTheme.Colors.surfaceHighlight, lineWidth: 3)
                        .frame(width: 56, height: 56)
                    
                    Circle()
                        .trim(from: 0, to: 0.7) // 70% progress
                        .stroke(
                            LinearGradient(
                                colors: [Color(hex: "8B5CF6"), Color(hex: "EC4899")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 3, lineCap: .round)
                        )
                        .frame(width: 56, height: 56)
                        .rotationEffect(.degrees(-90))
                    
                    Circle()
                        .fill(AppTheme.Colors.surfaceHighlight)
                        .frame(width: 48, height: 48)
                        .overlay(
                            Text("GN")
                                .font(AppTheme.font(.callout, weight: .bold))
                                .foregroundStyle(AppTheme.Colors.primary)
                        )
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - Combined Stats Section
    
    private var streakHeroView: some View {
        HStack(spacing: 16) {
            // Compact Streak Card
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .center, spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "F59E0B").opacity(0.1))
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: "flame.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(hex: "FBBF24"), Color(hex: "EF4444")],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    }
                    
                    Text(Localization.string("home_streak", lang: settings.appLanguage))
                        .font(AppTheme.font(.caption, weight: .bold))
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
                
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("7")
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                    
                    Text(Localization.string("home_day", lang: settings.appLanguage))
                        .font(AppTheme.font(.caption, weight: .bold))
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(AppTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(AppTheme.Colors.surfaceHighlight, lineWidth: 1)
            )
            
            // Cards Mastered / Progress Card
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .center, spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.Colors.primary.opacity(0.1))
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(AppTheme.Colors.primary)
                    }
                    
                    Text(Localization.string("home_mastered", lang: settings.appLanguage))
                        .font(AppTheme.font(.caption, weight: .bold))
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
                
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(totalCardsLearned())")
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                    
                    Text(Localization.string("home_card", lang: settings.appLanguage))
                        .font(AppTheme.font(.caption, weight: .bold))
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(AppTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(AppTheme.Colors.surfaceHighlight, lineWidth: 1)
            )
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - Quick Actions
    
    private var quickActionsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(Localization.string("home_quick_actions", lang: settings.appLanguage))
                .font(AppTheme.font(.subheadline, weight: .bold))
                .foregroundStyle(AppTheme.Colors.textPrimary)
                .padding(.horizontal, 24)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    // Review - Show all due cards
                    NavigationLink(destination: ReviewAllView(decks: decks)) {
                        QuickActionCardSmall(
                            icon: "arrow.clockwise",
                            title: Localization.string("home_review", lang: settings.appLanguage),
                            count: totalDueCards,
                            color: Color(hex: "EF4444")
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Learn New - Show new cards
                    NavigationLink(destination: LearnNewView(decks: decks)) {
                        QuickActionCardSmall(
                            icon: "plus.circle.fill",
                            title: Localization.string("home_learn", lang: settings.appLanguage),
                            count: totalNewCards,
                            color: Color(hex: "3B82F6")
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Quick Quiz
                    NavigationLink(destination: QuickQuizView(decks: decks)) {
                        QuickActionCardSmall(
                            icon: "bolt.fill",
                            title: Localization.string("home_quiz", lang: settings.appLanguage),
                            count: nil,
                            color: Color(hex: "8B5CF6")
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 24)
            }
        }
    }
    
    // Computed properties for counts
    var totalDueCards: Int {
        decks.reduce(0) { $0 + $1.dueCardsCount }
    }
    
    var totalNewCards: Int {
        decks.reduce(0) { count, deck in
            count + deck.cards.filter { $0.streak == 0 }.count
        }
    }
    
    // MARK: - Continue Learning Section
    
    private var continueLearningSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(Localization.string("home_continue", lang: settings.appLanguage))
                    .font(AppTheme.font(.subheadline, weight: .bold))
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                
                Spacer()
                
                Button(Localization.string("common_see_all", lang: settings.appLanguage)) {
                    // Navigate to all in-progress decks
                }
                .font(AppTheme.font(.caption, weight: .semibold))
                .foregroundStyle(AppTheme.Colors.primary)
                .linkButtonStyle()
            }
            .padding(.horizontal, 24)
            
            let inProgressDecks = decks.filter { $0.dueCardsCount > 0 }.prefix(5)
            
            if inProgressDecks.isEmpty {
                Text(Localization.string("home_empty_in_progress", lang: settings.appLanguage))
                    .font(AppTheme.font(.subheadline))
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 40)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(Array(inProgressDecks)) { deck in
                            NavigationLink(destination: DeckDetailView(deck: deck)) {
                                CompactDeckCard(deck: deck)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 24)
                }
            }
        }
    }
    
    // MARK: - Recent Section
    
    private var recentSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(Localization.string("home_recent", lang: settings.appLanguage))
                    .font(AppTheme.font(.subheadline, weight: .bold))
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                
                Spacer()
                
                Button(action: {
                    AppTheme.haptic(.medium)
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        navManager.selectedMainTab = 1
                        navManager.libraryInitialTab = 0 // Học phần tab
                    }
                }) {
                    Text(Localization.string("common_see_all", lang: settings.appLanguage))
                        .font(AppTheme.font(.caption, weight: .semibold))
                        .foregroundStyle(AppTheme.Colors.primary)
                }
                .linkButtonStyle()
            }
            .padding(.horizontal, 24)
            
            if decks.isEmpty {
                VStack(spacing: 16) {
                    Text(Localization.string("home_empty_decks", lang: settings.appLanguage))
                        .font(AppTheme.font(.subheadline))
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                    
                    Button(action: { addSampleDeck() }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text(Localization.string("home_create_first_deck", lang: settings.appLanguage))
                        }
                        .font(AppTheme.font(.subheadline, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(AppTheme.Colors.primaryGradient)
                        .clipShape(Capsule())
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(decks.prefix(5)) { deck in
                            NavigationLink(destination: DeckDetailView(deck: deck)) {
                                CompactDeckCard(deck: deck)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 24)
                }
            }
        }
    }
    
    // MARK: - My Classes Section
    
    private var myClassesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(Localization.string("home_classes", lang: settings.appLanguage))
                    .font(AppTheme.font(.subheadline, weight: .bold))
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                
                Spacer()
                
                Button(action: {
                    AppTheme.haptic(.medium)
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        navManager.selectedMainTab = 1
                        navManager.libraryInitialTab = 2 // Classes tab
                    }
                }) {
                    Text(Localization.string("common_see_all", lang: settings.appLanguage))
                        .font(AppTheme.font(.caption, weight: .semibold))
                        .foregroundStyle(AppTheme.Colors.primary)
                }
                .linkButtonStyle()
            }
            .padding(.horizontal, 24)
            
            if classes.isEmpty {
                // Empty State
                VStack(spacing: 12) {
                    HStack(spacing: 16) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(LinearGradient(colors: [Color(hex: "8B5CF6").opacity(0.3), Color(hex: "8B5CF6").opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 60, height: 60)
                            Image(systemName: "person.3.fill")
                                .font(.title2)
                                .foregroundStyle(Color(hex: "8B5CF6"))
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text(Localization.string("home_empty_classes", lang: settings.appLanguage))
                                .font(AppTheme.font(.subheadline, weight: .bold))
                                .foregroundStyle(AppTheme.Colors.textPrimary)
                            Text(Localization.string("home_join_class_msg", lang: settings.appLanguage))
                                .font(AppTheme.font(.caption))
                                .foregroundStyle(AppTheme.Colors.textSecondary)
                        }
                        Spacer()
                    }
                    .padding(20)
                    .background(RoundedRectangle(cornerRadius: 20).fill(AppTheme.Colors.surface))
                }
                .padding(.horizontal, 24)
            } else {
                ForEach(classes.prefix(3)) { classRoom in
                    NavigationLink(destination: ClassDetailView(classRoom: classRoom)) {
                        HStack(spacing: 16) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(AppTheme.Colors.primary.opacity(0.1))
                                    .frame(width: 60, height: 60)
                                Text(classRoom.name.prefix(1).uppercased())
                                    .font(AppTheme.font(.headline, weight: .bold))
                                    .foregroundStyle(AppTheme.Colors.primary)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(classRoom.name)
                                    .font(AppTheme.font(.subheadline, weight: .bold))
                                    .foregroundStyle(AppTheme.Colors.textPrimary)
                                Text(classRoom.teacherName)
                                    .font(AppTheme.font(.caption))
                                    .foregroundStyle(AppTheme.Colors.textSecondary)
                            }
                            Spacer()
                            
                            Text(String(format: Localization.string("home_class_code_prefix", lang: settings.appLanguage), classRoom.code))
                                .font(AppTheme.font(.caption2, weight: .bold))
                                .foregroundStyle(AppTheme.Colors.textSecondary)
                        }
                        .padding(16)
                        .background(AppTheme.Colors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(AppTheme.Colors.surfaceHighlight, lineWidth: 1)
                        )
                        .padding(.horizontal, 24)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    func greetingText() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        let lang = settings.appLanguage
        
        if hour < 12 {
            return Localization.string("home_greeting_morning", lang: lang)
        } else if hour < 17 {
            return Localization.string("home_greeting_afternoon", lang: lang)
        } else {
            return Localization.string("home_greeting_evening", lang: lang)
        }
    }
    
    func addSampleDeck() {
        AppTheme.haptic(.medium)
        let deck = Deck(title: "Japanese - N5", emoji: "🇯🇵", language: "Japanese")
        deck.cards = [
            Card(front: "猫", back: "Cat (Neko)", pronunciation: "Neko"),
            Card(front: "犬", back: "Dog (Inu)", pronunciation: "Inu"),
            Card(front: "こんにちは", back: "Hello", pronunciation: "Konnichiwa"),
        ]
        modelContext.insert(deck)
    }
    
    func totalCardsLearned() -> Int {
        decks.reduce(0) { count, deck in
            count + deck.cards.filter { !$0.isDue }.count
        }
    }
}

// MARK: - New Components for HomeView

struct QuickActionCardSmall: View {
    @EnvironmentObject var settings: AppSettings
    let icon: String
    let title: String
    let count: Int?
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppTheme.font(.subheadline, weight: .bold))
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                
                if let count = count {
                    Text("\(count) \(Localization.string("home_items_unit", lang: settings.appLanguage))")
                        .font(AppTheme.font(.caption2, weight: .medium))
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
            }
        }
        .padding(.leading, 12)
        .padding(.trailing, 20)
        .padding(.vertical, 12)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppTheme.Colors.surfaceHighlight, lineWidth: 1)
        )
    }
}
