import SwiftUI
import SwiftData

struct BlockItem: Identifiable {
    let id = UUID()
    let card: Card
    var offset: CGFloat = 0
    var scale: CGFloat = 1.0
}

// New Block struct and BlockShape for gameplayView
struct Block: Identifiable {
    let id = UUID()
    let text: String
    let color: Color
}

struct BlockShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let cornerRadius: CGFloat = 8
        
        path.move(to: CGPoint(x: rect.minX + cornerRadius, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY))
        path.addArc(center: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY + cornerRadius), radius: cornerRadius, startAngle: .degrees(-90), endAngle: .degrees(0), clockwise: false)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - cornerRadius))
        path.addArc(center: CGPoint(x: rect.maxX - cornerRadius, y: rect.maxY - cornerRadius), radius: cornerRadius, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)
        path.addLine(to: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY))
        path.addArc(center: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY - cornerRadius), radius: cornerRadius, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + cornerRadius))
        path.addArc(center: CGPoint(x: rect.minX + cornerRadius, y: rect.minY + cornerRadius), radius: cornerRadius, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
        
        return path
    }
}


struct BlockGameView: View {
    @Bindable var deck: Deck
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var settings: AppSettings
    @EnvironmentObject var navManager: NavigationManager
    @Binding var shouldPopToRoot: Bool
    
    @State private var gameState: GameState = .intro
    @State private var tower: [Block] = []
    @State private var currentOptions: [Card] = []
    @State private var correctCard: Card?
    @State private var score = 0
    @State private var isNewRecord = false
    @State private var towerShake = false
    @State private var towerOffset: CGFloat = 0
    
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
                                .fill(Color.orange.opacity(0.1))
                                .frame(width: 120, height: 120)
                            
                            Image(systemName: "building.2.fill")
                                .font(.system(size: 50))
                                .foregroundStyle(.orange)
                        }
                        
                        Text(Localization.string("game_block_title", lang: settings.appLanguage))
                            .font(AppTheme.font(.largeTitle, weight: .black))
                            .foregroundStyle(.white)
                    }
                    .padding(.top, 20)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        InstructionRow(icon: "text.justify.left", text: Localization.string("game_block_intro1", lang: settings.appLanguage))
                        InstructionRow(icon: "waveform.path.ecg", text: Localization.string("game_block_intro2", lang: settings.appLanguage))
                        InstructionRow(icon: "trophy.fill", text: Localization.string("game_block_intro3", lang: settings.appLanguage))
                    }
                    .padding(.horizontal, 32)
                    
                    VStack(spacing: 24) {
                        Button {
                            startGame()
                        } label: {
                            Text(Localization.string("game_block_start", lang: settings.appLanguage))
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
            // Header
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.title3.bold())
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
                
                Spacer()
                
                VStack {
                    Text(Localization.string("game_height", lang: settings.appLanguage))
                        .font(AppTheme.font(.caption, weight: .black))
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                    Text(String(format: Localization.string("game_floors", lang: settings.appLanguage), score))
                        .font(AppTheme.font(.title3, weight: .black).monospacedDigit())
                        .foregroundStyle(AppTheme.Colors.primary)
                }
                
                Spacer()
                
                if let best = deck.bestBlockScore {
                    VStack {
                        Text(Localization.string("game_record", lang: settings.appLanguage))
                            .font(AppTheme.font(.caption, weight: .black))
                            .foregroundStyle(AppTheme.Colors.textSecondary)
                        Text("\(best)")
                            .font(AppTheme.font(.title3, weight: .black).monospacedDigit())
                            .foregroundStyle(.orange)
                    }
                }
            }
            .padding()
            
            // Tower Area
            GeometryReader { geometry in
                ZStack(alignment: .bottom) {
                    // Base
                    Rectangle()
                        .fill(AppTheme.Colors.surfaceHighlight)
                        .frame(width: 200, height: 10)
                        .padding(.bottom, 20)
                    
                    // Blocks
                    VStack(spacing: 2) {
                        ForEach(tower.suffix(8)) { block in
                            BlockShape()
                                .fill(block.color)
                                .frame(width: 160, height: 40)
                                .overlay(
                                    Text(block.text)
                                        .font(AppTheme.font(.caption, weight: .bold))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 8)
                                        .lineLimit(1)
                                )
                                .transition(.move(edge: .top).combined(with: .opacity))
                        }
                    }
                    .padding(.bottom, 30)
                    .offset(x: towerShake ? towerOffset : 0)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            // Options
            if let target = correctCard {
                VStack(spacing: 12) {
                    Text(target.front)
                        .font(AppTheme.font(.title2, weight: .black))
                        .foregroundStyle(.white)
                        .padding(.bottom, 8)
                    
                    ForEach(currentOptions) { option in
                        Button {
                            handleAnswer(option)
                        } label: {
                            Text(option.back)
                                .font(AppTheme.font(.body, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppTheme.Colors.surface)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(AppTheme.Colors.surfaceHighlight, lineWidth: 1)
                                )
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 80)
            }
        }
    }
    
    // MARK: - Result View
    private var resultView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 32) {
                VStack(spacing: 16) {
                    if isNewRecord {
                        Text(Localization.string("game_new_record", lang: settings.appLanguage))
                            .font(AppTheme.font(.headline, weight: .black))
                            .foregroundStyle(.orange)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(Color.orange.opacity(0.2))
                            .clipShape(Capsule())
                    }
                    
                    Image(systemName: "building.2.fill")
                        .font(.system(size: 70))
                        .foregroundStyle(.orange)
                    
                    Text(Localization.string("game_block_collapsed", lang: settings.appLanguage))
                        .font(AppTheme.font(.title, weight: .black))
                        .foregroundStyle(.white)
                }
                .padding(.top, 40)
                
                VStack(spacing: 16) {
                    // Current Score
                    VStack(spacing: 4) {
                        Text("\(score)")
                            .font(.system(size: 80, weight: .black, design: .rounded))
                            .foregroundStyle(AppTheme.Colors.primaryGradient)
                            .shadow(color: AppTheme.Colors.primary.opacity(0.3), radius: 15)
                        
                        Text(Localization.string("game_floors_achieved", lang: settings.appLanguage))
                            .font(AppTheme.font(.caption, weight: .black))
                            .foregroundStyle(AppTheme.Colors.textSecondary)
                    }
                    
                    Divider().background(Color.white.opacity(0.1)).padding(.horizontal, 40)
                    
                    // Best Score
                    HStack(spacing: 30) {
                        VStack(spacing: 2) {
                            Text(isNewRecord ? "\(score)" : "\(deck.bestBlockScore ?? score)")
                                .font(AppTheme.font(.title3, weight: .bold))
                                .foregroundStyle(.white)
                            Text(Localization.string("game_record", lang: settings.appLanguage))
                                .font(AppTheme.font(.caption2, weight: .bold))
                                .foregroundStyle(AppTheme.Colors.textSecondary)
                        }
                        
                        if isNewRecord {
                            Text(Localization.string("common_new", lang: settings.appLanguage))
                                .font(AppTheme.font(.caption2, weight: .black))
                                .foregroundStyle(.black)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.orange)
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
                        Text(Localization.string("game_block_restart", lang: settings.appLanguage))
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
                        shareBlockChallenge()
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
                .padding(.bottom, 140)
            }
            .padding(.horizontal, 24)
        }
    }
    
    // MARK: - Logic
    private func startGame() {
        score = 0
        tower = []
        isNewRecord = false
        nextRound()
        withAnimation {
            gameState = .playing
        }
    }
    
    private func nextRound() {
        guard !deck.cards.isEmpty else { return }
        let correct = deck.cards.shuffled().first!
        correctCard = correct
        
        var newOptions = [correct]
        let distractors = deck.cards.filter { $0.id != correct.id }.shuffled().prefix(2)
        newOptions.append(contentsOf: distractors)
        
        currentOptions = newOptions.shuffled()
    }
    
    private func handleAnswer(_ choice: Card) {
        if choice.id == correctCard?.id {
            // Correct
            AppTheme.notificationHaptic(.success)
            score += 1
            
            withAnimation(.spring()) {
                let colors: [Color] = [.blue, .purple, .pink, .orange, .cyan]
                tower.append(Block(text: choice.back, color: colors.randomElement() ?? .blue))
            }
            nextRound()
        } else {
            // Wrong - Tower falls
            AppTheme.notificationHaptic(.error)
            withAnimation(.default.repeatCount(5, autoreverses: true)) {
                towerShake = true
                towerOffset = 10
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                towerShake = false
                towerOffset = 0
                finishGame()
            }
        }
    }
    
    private func finishGame() {
        if let best = deck.bestBlockScore {
            if score > best {
                isNewRecord = true
                deck.bestBlockScore = score
            }
        } else {
            isNewRecord = true
            deck.bestBlockScore = score
        }
        
        withAnimation {
            gameState = .finished
        }
    }
    
    private func shareBlockChallenge() {
        let template = Localization.string("game_block_share_msg", lang: settings.appLanguage)
        let message = String(format: template, score, deck.title)
        presentShareMessage(message)
    }
}
