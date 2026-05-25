import SwiftUI
import SwiftData

// Review All Due Cards
struct ReviewAllView: View {
    let decks: [Deck]
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var navManager: NavigationManager
    @EnvironmentObject var settings: AppSettings
    
    var allDueCards: [(deck: Deck, cards: [Card])] {
        decks.compactMap { deck in
            let dueCards = deck.cards.filter { $0.isDue }
            return dueCards.isEmpty ? nil : (deck, dueCards)
        }
    }
    
    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    if allDueCards.isEmpty {
                        emptyStateView
                    } else {
                        ForEach(allDueCards, id: \.deck.id) { item in
                            DeckReviewSection(deck: item.deck, dueCards: item.cards)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 100)
            }
        }
        .navigationTitle(Localization.string("home_review", lang: settings.appLanguage))
        .navigationBarTitleDisplayMode(.large)
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
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(Color(hex: "10B981"))
            
            VStack(spacing: 8) {
                Text(Localization.string("quick_review_empty_title", lang: settings.appLanguage))
                    .font(AppTheme.font(.title3, weight: .bold))
                    .foregroundStyle(.white)
                
                Text(Localization.string("quick_review_empty_msg", lang: settings.appLanguage))
                    .font(AppTheme.font(.subheadline))
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 100)
    }
}

struct DeckReviewSection: View {
    @EnvironmentObject var settings: AppSettings
    let deck: Deck
    let dueCards: [Card]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(deck.emoji)
                    .font(.system(size: 24))
                
                Text(deck.title)
                    .font(AppTheme.font(.headline, weight: .bold))
                    .foregroundStyle(.white)
                
                Spacer()
                
                Text("\(dueCards.count) \(Localization.string("home_card", lang: settings.appLanguage))")
                    .font(AppTheme.font(.caption, weight: .semibold))
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
            
            NavigationLink(destination: StudyView(deck: deck)) {
                HStack {
                    Image(systemName: "play.fill")
                    Text(Localization.string("quick_review_start", lang: settings.appLanguage))
                }
                .font(AppTheme.font(.subheadline, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color(hex: "EF4444"))
                .clipShape(Capsule())
            }
        }
        .padding(20)
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
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}

// Learn New Cards
struct LearnNewView: View {
    let decks: [Deck]
    @EnvironmentObject var navManager: NavigationManager
    @EnvironmentObject var settings: AppSettings
    
    var newCardDecks: [(deck: Deck, cards: [Card])] {
        decks.compactMap { deck in
            let newCards = deck.cards.filter { $0.streak == 0 }
            return newCards.isEmpty ? nil : (deck, newCards)
        }
    }
    
    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    if newCardDecks.isEmpty {
                        emptyStateView
                    } else {
                        ForEach(newCardDecks, id: \.deck.id) { item in
                            DeckLearnSection(deck: item.deck, newCards: item.cards)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 100)
            }
        }
        .navigationTitle(Localization.string("home_learn", lang: settings.appLanguage))
        .navigationBarTitleDisplayMode(.large)
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
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "sparkles")
                .font(.system(size: 60))
                .foregroundStyle(Color(hex: "3B82F6"))
            
            VStack(spacing: 8) {
                Text(Localization.string("quick_learn_empty_title", lang: settings.appLanguage))
                    .font(AppTheme.font(.title3, weight: .bold))
                    .foregroundStyle(.white)
                
                Text(Localization.string("quick_learn_empty_msg", lang: settings.appLanguage))
                    .font(AppTheme.font(.subheadline))
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 100)
    }
}

struct DeckLearnSection: View {
    @EnvironmentObject var settings: AppSettings
    let deck: Deck
    let newCards: [Card]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(deck.emoji)
                    .font(.system(size: 24))
                
                Text(deck.title)
                    .font(AppTheme.font(.headline, weight: .bold))
                    .foregroundStyle(.white)
                
                Spacer()
                
                Text("\(newCards.count) \(Localization.string("home_card", lang: settings.appLanguage))")
                    .font(AppTheme.font(.caption, weight: .semibold))
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
            
            NavigationLink(destination: StudyView(deck: deck)) {
                HStack {
                    Image(systemName: "play.fill")
                    Text(Localization.string("quick_learn_start", lang: settings.appLanguage))
                }
                .font(AppTheme.font(.subheadline, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color(hex: "3B82F6"))
                .clipShape(Capsule())
            }
        }
        .padding(20)
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
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}

// Quick Quiz View
struct QuickQuizView: View {
    let decks: [Deck]
    @EnvironmentObject var navManager: NavigationManager
    @EnvironmentObject var settings: AppSettings
    @State private var selectedDeck: Deck?
    
    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Info Card
                    VStack(spacing: 12) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(Color(hex: "8B5CF6"))
                        
                        Text(Localization.string("home_quiz", lang: settings.appLanguage))
                            .font(AppTheme.font(.title3, weight: .bold))
                            .foregroundStyle(.white)
                        
                        Text(Localization.string("quick_quiz_desc", lang: settings.appLanguage))
                            .font(AppTheme.font(.subheadline))
                            .foregroundStyle(AppTheme.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.vertical, 32)
                    
                    // Deck Selection
                    ForEach(decks.filter { $0.activeCardsCount > 0 }) { deck in
                        Button(action: {
                            selectedDeck = deck
                        }) {
                            HStack(spacing: 16) {
                                Text(deck.emoji)
                                    .font(.system(size: 32))
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(deck.title)
                                        .font(AppTheme.font(.headline, weight: .bold))
                                        .foregroundStyle(.white)
                                    
                                    Text("\(deck.activeCardsCount) \(Localization.string("home_card", lang: settings.appLanguage))")
                                        .font(AppTheme.font(.caption))
                                        .foregroundStyle(AppTheme.Colors.textSecondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.subheadline.bold())
                                    .foregroundStyle(AppTheme.Colors.textSecondary)
                            }
                            .padding(20)
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
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 100)
            }
        }
        .navigationTitle(Localization.string("home_quiz", lang: settings.appLanguage))
        .navigationBarTitleDisplayMode(.large)
        .sheet(item: $selectedDeck) { deck in
            QuizView(deck: deck, mode: .cram)
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
}
