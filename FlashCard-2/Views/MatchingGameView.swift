import SwiftUI
import SwiftData
import Combine

struct MatchingTile: Identifiable {
    let id = UUID()
    let cardId: UUID
    let text: String
    let isFront: Bool
    var isSelected = false
    var isMatched = false
}

struct MatchingGameView: View {
    @Bindable var deck: Deck
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var settings: AppSettings
    @EnvironmentObject var navManager: NavigationManager
    @Binding var shouldPopToRoot: Bool
    
    @State private var gameState: GameState = .intro
    @State private var tiles: [MatchingTile] = []
    @State private var selectedTiles: [MatchingTile] = []
    @State private var startTime: Date?
    @State private var timeElapsed: TimeInterval = 0
    @State private var timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    @State private var matchesFound = 0
    @State private var isNewRecord = false
    
    enum GameState {
        case intro, playing, finished
    }
    
    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()
            
            switch gameState {
            case .intro:
                introView
            case .playing:
                gameplayView
            case .finished:
                resultView
            }
        }
        .navigationBarHidden(true)
        .onReceive(timer) { _ in
            if gameState == .playing {
                if let start = startTime {
                    timeElapsed = Date().timeIntervalSince(start)
                }
            }
        }
    }
    
    private var introView: some View {
        VStack(spacing: 0) {
            // Top Bar
            HStack {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text(Localization.string("common_back", lang: settings.appLanguage))
                    }
                    .font(AppTheme.font(.body, weight: .bold))
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                }
                Spacer()
            }
            .padding()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 40) {
                    VStack(spacing: 24) {
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.1))
                                .frame(width: 120, height: 120)
                            
                            Image(systemName: "square.grid.2x2.fill")
                                .font(.system(size: 50))
                                .foregroundStyle(.blue)
                        }
                        
                        Text(Localization.string("game_match_title", lang: settings.appLanguage))
                            .font(AppTheme.font(.largeTitle, weight: .black))
                            .foregroundStyle(.white)
                    }
                    .padding(.top, 20)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        InstructionRow(icon: "touchid", text: Localization.string("game_match_intro1", lang: settings.appLanguage))
                        InstructionRow(icon: "timer", text: Localization.string("game_match_intro2", lang: settings.appLanguage))
                        InstructionRow(icon: "bolt.fill", text: Localization.string("game_match_intro3", lang: settings.appLanguage))
                    }
                    .padding(.horizontal, 32)
                    
                    VStack(spacing: 24) {
                        Button {
                            startGame()
                        } label: {
                            Text(Localization.string("game_match_start", lang: settings.appLanguage))
                                .font(AppTheme.font(.headline, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(AppTheme.Colors.primaryGradient)
                                .clipShape(Capsule())
                                .shadow(color: AppTheme.Colors.primary.opacity(0.4), radius: 10, x: 0, y: 5)
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 110)
                }
            }
        }
    }
    
    // MARK: - Gameplay View
    private var gameplayView: some View {
        VStack(spacing: 20) {
            // Stats Header
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.title3.bold())
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
                
                Spacer()
                
                VStack {
                    Text(Localization.string("game_match_time", lang: settings.appLanguage))
                        .font(AppTheme.font(.caption, weight: .black))
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                    Text(formatTime(timeElapsed))
                        .font(AppTheme.font(.title3, weight: .black).monospacedDigit())
                        .foregroundStyle(AppTheme.Colors.primary)
                }
                
                Spacer()
                
                VStack {
                    Text(Localization.string("game_progress", lang: settings.appLanguage))
                        .font(AppTheme.font(.caption))
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                    Text("\(matchesFound)/\(tiles.count/2)")
                        .font(AppTheme.font(.title3).monospacedDigit())
                        .foregroundStyle(.white)
                }
            }
            .padding()
            
            // Grid
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(tiles) { tile in
                        TileView(tile: tile)
                            .onTapGesture {
                                handleTileSelection(tile)
                            }
                    }
                }
                .padding(16)
            }
        }
    }
    
    // MARK: - Result View
    private var resultView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 32) {
                VStack(spacing: 16) {
                    if isNewRecord {
                        Text(Localization.string("game_new_record_title", lang: settings.appLanguage))
                            .font(AppTheme.font(.headline, weight: .black))
                            .foregroundStyle(.yellow)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(Color.yellow.opacity(0.2))
                            .clipShape(Capsule())
                            .shadow(color: .yellow.opacity(0.5), radius: 10)
                    }
                    
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 70))
                        .foregroundStyle(.yellow)
                        .shadow(color: .yellow.opacity(0.5), radius: 20)
                    
                    Text(isNewRecord ? Localization.string("game_excellent", lang: settings.appLanguage) : Localization.string("game_wonderful", lang: settings.appLanguage))
                        .font(AppTheme.font(.title, weight: .black))
                        .foregroundStyle(.white)
                }
                .padding(.top, 40)
                
                VStack(spacing: 16) {
                    // Current Time
                    VStack(spacing: 4) {
                        Text(formatTime(timeElapsed))
                            .font(.system(size: 80, weight: .black, design: .rounded))
                            .foregroundStyle(AppTheme.Colors.primaryGradient)
                            .shadow(color: AppTheme.Colors.primary.opacity(0.3), radius: 15)
                        
                        Text(Localization.string("game_match_time", lang: settings.appLanguage))
                            .font(AppTheme.font(.caption, weight: .black))
                            .foregroundStyle(AppTheme.Colors.textSecondary)
                    }
                    
                    Divider().background(Color.white.opacity(0.1)).padding(.horizontal, 40)
                    
                    // Best Time
                    HStack(spacing: 30) {
                        VStack(spacing: 2) {
                            Text(isNewRecord ? formatTime(timeElapsed) : (deck.bestMatchingTime != nil ? formatTime(deck.bestMatchingTime!) : formatTime(timeElapsed)))
                                .font(AppTheme.font(.title3, weight: .bold))
                                .foregroundStyle(.white)
                            Text(Localization.string("game_match_best", lang: settings.appLanguage))
                                .font(AppTheme.font(.caption2, weight: .bold))
                                .foregroundStyle(AppTheme.Colors.textSecondary)
                        }
                        
                        if isNewRecord {
                            Text(Localization.string("common_new", lang: settings.appLanguage))
                                .font(AppTheme.font(.caption2, weight: .black))
                                .foregroundStyle(.black)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.yellow)
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(.vertical, 24)
                .frame(maxWidth: .infinity)
                .background(AppTheme.Colors.surface)
                .cornerRadius(32)
                .overlay(
                    RoundedRectangle(cornerRadius: 32)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
                
                VStack(spacing: 12) {
                    Button {
                        startGame()
                    } label: {
                        Text(Localization.string("game_match_play_again", lang: settings.appLanguage))
                            .font(AppTheme.font(.headline, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.Colors.primaryGradient)
                            .clipShape(Capsule())
                    }
                    
                    Button {
                        navManager.selectedMainTab = 1
                        dismiss()
                    } label: {
                        Text(Localization.string("nav_choose_other", lang: settings.appLanguage))
                            .font(AppTheme.font(.headline, weight: .bold))
                            .foregroundStyle(AppTheme.Colors.textSecondary)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.Colors.surfaceHighlight.opacity(0.3))
                            .clipShape(Capsule())
                            .overlay(
                                Capsule().stroke(AppTheme.Colors.surfaceHighlight, lineWidth: 1)
                            )
                    }
                    
                    Button {
                        shareMatchChallenge()
                    } label: {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text(Localization.string("study_challenge", lang: settings.appLanguage))
                        }
                        .font(AppTheme.font(.headline, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.Colors.secondaryGradient)
                        .clipShape(Capsule())
                        .shadow(color: AppTheme.Colors.secondary.opacity(0.3), radius: 8)
                    }
                }
                .padding(.bottom, 110)
            }
            .padding(.horizontal, 24)
        }
    }
    
    // MARK: - Logic
    private func startGame() {
        // Take up to 6 cards (12 tiles total)
        let gameCards = deck.cards.shuffled().prefix(6)
        var newTiles: [MatchingTile] = []
        
        for card in gameCards {
            newTiles.append(MatchingTile(cardId: card.id, text: card.front, isFront: true))
            newTiles.append(MatchingTile(cardId: card.id, text: card.back, isFront: false))
        }
        
        tiles = newTiles.shuffled()
        selectedTiles = []
        matchesFound = 0
        timeElapsed = 0
        isNewRecord = false
        startTime = Date()
        
        withAnimation {
            gameState = .playing
        }
    }
    
    private func handleTileSelection(_ tile: MatchingTile) {
        guard !tile.isMatched, !tile.isSelected, selectedTiles.count < 2 else { return }
        
        AppTheme.haptic(.light)
        
        // Mark tile as selected in state
        if let index = tiles.firstIndex(where: { $0.id == tile.id }) {
            tiles[index].isSelected = true
            selectedTiles.append(tiles[index])
        }
        
        if selectedTiles.count == 2 {
            let first = selectedTiles[0]
            let second = selectedTiles[1]
            
            if first.cardId == second.cardId && first.isFront != second.isFront {
                // Match!
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.spring()) {
                        for tile in selectedTiles {
                            if let idx = tiles.firstIndex(where: { $0.id == tile.id }) {
                                tiles[idx].isMatched = true
                            }
                        }
                        matchesFound += 1
                        selectedTiles = []
                        AppTheme.notificationHaptic(.success)
                        
                        if matchesFound == tiles.count / 2 {
                            finishGame()
                        }
                    }
                }
            } else {
                // No match
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    withAnimation {
                        for tile in selectedTiles {
                            if let idx = tiles.firstIndex(where: { $0.id == tile.id }) {
                                tiles[idx].isSelected = false
                            }
                        }
                        selectedTiles = []
                        AppTheme.notificationHaptic(.error)
                    }
                }
            }
        }
    }
    
    private func finishGame() {
        // Check for new record
        if let best = deck.bestMatchingTime {
            if timeElapsed < best {
                isNewRecord = true
                deck.bestMatchingTime = timeElapsed
            }
        } else {
            isNewRecord = true
            deck.bestMatchingTime = timeElapsed
        }
        
        gameState = .finished
    }
    
    private func shareMatchChallenge() {
        let template = Localization.string("game_match_share_msg", lang: settings.appLanguage)
        let message = String(format: template, deck.title, formatTime(timeElapsed))
        presentShareMessage(message)
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let tenths = Int((time * 10).truncatingRemainder(dividingBy: 10))
        return String(format: "%02d:%02d.%d", minutes, seconds, tenths)
    }
}

// MARK: - Components

struct TileView: View {
    let tile: MatchingTile
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(tile.isSelected ? AppTheme.Colors.primary.opacity(0.1) : AppTheme.Colors.surface)
                .shadow(color: .black.opacity(0.1), radius: 4)
            
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    tile.isSelected ? AppTheme.Colors.primary : AppTheme.Colors.surfaceHighlight,
                    lineWidth: 2
                )
            
            Text(tile.text)
                .font(AppTheme.font(.subheadline, weight: .bold))
                .foregroundStyle(tile.isSelected ? AppTheme.Colors.primary : .white)
                .multilineTextAlignment(.center)
                .padding(8)
                .minimumScaleFactor(0.5)
        }
        .frame(height: 100)
        .opacity(tile.isMatched ? 0 : 1)
        .scaleEffect(tile.isMatched ? 0.8 : 1.0)
    }
}
