import SwiftUI
import SwiftData
import Combine

struct BlastTarget: Identifiable {
    let id = UUID()
    let card: Card
    var position: CGPoint
    var velocity: CGSize
    var isDestroyed = false
    var color: Color
    var emoji: String
}

struct BlastGameView: View {
    @Bindable var deck: Deck
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var settings: AppSettings
    @EnvironmentObject var navManager: NavigationManager
    @Binding var shouldPopToRoot: Bool
    
    @State private var gameState: GameState = .intro
    @State private var currentQuestion: Card?
    @State private var targets: [BlastTarget] = []
    @State private var score = 0
    @State private var lives = 3
    @State private var combo = 0
    @State private var timer = Timer.publish(every: 0.03, on: .main, in: .common).autoconnect()
    @State private var isNewRecord = false
    
    // Countdown State
    @State private var countdownValue = 3
    @State private var isCountingDown = false
    
    enum GameState {
        case intro, playing, finished
    }
    
    private let monsterEmojis = ["👾", "🛸", "👻", "👹", "🤖", "🦟"]
    private let monsterColors: [Color] = [.purple, .blue, .green, .orange, .pink, .red]
    
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
            
            // Countdown Overlay
            if isCountingDown {
                ZStack {
                    Color.black.opacity(0.6).ignoresSafeArea()
                    Text(countdownValue > 0 ? "\(countdownValue)" : Localization.string("game_blast_countdown_ready", lang: settings.appLanguage))
                        .font(.system(size: 100, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .scaleEffect(isCountingDown ? 1.2 : 0.8)
                        .animation(.spring(), value: countdownValue)
                }
            }
        }
        .navigationBarHidden(true)
        .onReceive(timer) { _ in
            if gameState == .playing && !isCountingDown {
                updatePhysics()
            }
        }
    }
    
    // MARK: - Intro View
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
                                .fill(Color.purple.opacity(0.1))
                                .frame(width: 120, height: 120)
                            
                            Image(systemName: "scope")
                                .font(.system(size: 60))
                                .foregroundStyle(AppTheme.Colors.primaryGradient)
                        }
                        
                        Text(Localization.string("game_blast_title", lang: settings.appLanguage))
                            .font(AppTheme.font(.largeTitle, weight: .black))
                            .foregroundStyle(.white)
                    }
                    .padding(.top, 20)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        InstructionRow(icon: "target", text: Localization.string("game_blast_intro1", lang: settings.appLanguage))
                        InstructionRow(icon: "bolt.fill", text: Localization.string("game_blast_intro2", lang: settings.appLanguage))
                        InstructionRow(icon: "shield.fill", text: Localization.string("game_blast_intro3", lang: settings.appLanguage))
                    }
                    .padding(.horizontal, 32)
                    
                    VStack(spacing: 24) {
                        Button {
                            startCountdown()
                        } label: {
                            Text(Localization.string("game_blast_start", lang: settings.appLanguage))
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
        GeometryReader { geo in
            ZStack {
                // Background Stars/Grid
                spaceBackground
                
                // Monsters
                ForEach(targets) { target in
                    if !target.isDestroyed {
                        MonsterView(target: target)
                            .position(target.position)
                            .onTapGesture {
                                handleTap(target)
                            }
                    }
                }
                
                // HUD & Laser Gun
                VStack {
                    HUD(lives: lives, score: score, onExit: { dismiss() })
                    
                    Spacer()
                    
                    // Laser Gun / Question Section
                    if let card = currentQuestion {
                        VStack(spacing: 12) {
                            // Crosshair
                            Image(systemName: "plus")
                                .font(.system(size: 30, weight: .light))
                                .foregroundStyle(AppTheme.Colors.primary.opacity(0.5))
                                .offset(y: -40)
                            
                            VStack(spacing: 4) {
                                Text(Localization.string("game_blast_current_target", lang: settings.appLanguage))
                                    .font(AppTheme.font(.caption2, weight: .black))
                                    .foregroundStyle(AppTheme.Colors.primary)
                                
                                Text(card.front)
                                    .font(.system(size: 32, weight: .black, design: .rounded))
                                    .foregroundStyle(.white)
                            }
                            .padding(.vertical, 15)
                            .padding(.horizontal, 40)
                            .background(
                                AppTheme.Colors.surface.opacity(0.9)
                                    .blur(radius: 1)
                            )
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(AppTheme.Colors.primaryGradient, lineWidth: 2)
                                    .shadow(color: AppTheme.Colors.primary.opacity(0.5), radius: 10)
                            )
                        }
                        .padding(.bottom, 100)
                    }
                }
            }
        }
    }
    
    private var spaceBackground: some View {
        ZStack {
            // Subtle Grid
            Path { path in
                for i in 0...10 {
                    let x = CGFloat(i) * UIScreen.main.bounds.width / 10
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: UIScreen.main.bounds.height))
                    
                    let y = CGFloat(i) * UIScreen.main.bounds.height / 10
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: UIScreen.main.bounds.width, y: y))
                }
            }
            .stroke(Color.white.opacity(0.05), lineWidth: 1)
        }
    }
    
    // MARK: - Result View
    private var resultView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 32) {
                VStack(spacing: 16) {
                    if isNewRecord {
                        Text(Localization.string("game_blast_warrior_record", lang: settings.appLanguage))
                            .font(AppTheme.font(.headline, weight: .black))
                            .foregroundStyle(.orange)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(Color.orange.opacity(0.2))
                            .clipShape(Capsule())
                    }
                    
                    Image(systemName: lives > 0 ? "checkmark.seal.fill" : "skull.fill")
                        .font(.system(size: 70))
                        .foregroundStyle(lives > 0 ? .green : .red)
                    
                    Text(lives > 0 ? Localization.string("game_blast_mission_complete", lang: settings.appLanguage) : Localization.string("game_blast_failed", lang: settings.appLanguage))
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
                        
                        Text(Localization.string("game_blast_current_score", lang: settings.appLanguage))
                            .font(AppTheme.font(.caption, weight: .black))
                            .foregroundStyle(AppTheme.Colors.textSecondary)
                    }
                    
                    Divider().background(Color.white.opacity(0.1)).padding(.horizontal, 40)
                    
                    // Best Score
                    HStack(spacing: 30) {
                        VStack(spacing: 2) {
                            Text(isNewRecord ? "\(score)" : "\(deck.bestBlastScore ?? score)")
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
                        startCountdown()
                    } label: {
                        Text(Localization.string("game_blast_retry", lang: settings.appLanguage))
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
                        shareBlastChallenge()
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
    private func startCountdown() {
        score = 0
        lives = 3
        combo = 0
        targets = []
        isNewRecord = false
        countdownValue = 3
        isCountingDown = true
        gameState = .playing
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if countdownValue > 1 {
                countdownValue -= 1
                AppTheme.haptic(.medium)
            } else {
                timer.invalidate()
                countdownValue = 0
                AppTheme.notificationHaptic(.success)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation {
                        isCountingDown = false
                        nextQuestion()
                    }
                }
            }
        }
    }
    
    private func nextQuestion() {
        guard gameState == .playing else { return }
        currentQuestion = deck.cards.shuffled().first
        spawnTargets()
    }
    
    private func spawnTargets() {
        guard let current = currentQuestion else { return }
        targets = []
        
        // Add correct target
        targets.append(createTarget(card: current))
        
        // Add distractors
        let distractors = deck.cards.filter { $0.id != current.id }.shuffled().prefix(4)
        for card in distractors {
            targets.append(createTarget(card: card))
        }
        
        targets.shuffle()
    }
    
    private func createTarget(card: Card) -> BlastTarget {
        let screen = UIScreen.main.bounds
        let size: CGFloat = 80
        
        let x = CGFloat.random(in: size...screen.width - size)
        let y = CGFloat.random(in: 150...screen.height - 300)
        
        let speed: CGFloat = 3.0 + CGFloat(score / 100)
        let vx = CGFloat.random(in: -speed...speed)
        let vy = CGFloat.random(in: -speed...speed)
        
        return BlastTarget(
            card: card,
            position: CGPoint(x: x, y: y),
            velocity: CGSize(width: vx == 0 ? 2 : vx, height: vy == 0 ? 2 : vy),
            color: monsterColors.randomElement() ?? .purple,
            emoji: monsterEmojis.randomElement() ?? "👻"
        )
    }
    
    private func updatePhysics() {
        let screen = UIScreen.main.bounds
        let size: CGFloat = 40 // collision margin
        
        for i in 0..<targets.count {
            if !targets[i].isDestroyed {
                // Update position
                targets[i].position.x += targets[i].velocity.width
                targets[i].position.y += targets[i].velocity.height
                
                // Bounce X
                if targets[i].position.x <= size || targets[i].position.x >= screen.width - size {
                    targets[i].velocity.width *= -1
                    // Keep inside
                    targets[i].position.x = max(size, min(screen.width - size, targets[i].position.x))
                }
                
                // Bounce Y
                if targets[i].position.y <= 120 || targets[i].position.y >= screen.height - 250 {
                    targets[i].velocity.height *= -1
                    // Keep inside
                    targets[i].position.y = max(120, min(screen.height - 250, targets[i].position.y))
                }
            }
        }
    }
    
    private func handleTap(_ target: BlastTarget) {
        if target.card.id == currentQuestion?.id {
            // Correct - Monster EXPLODES
            AppTheme.notificationHaptic(.success)
            score += 10 + (combo * 2)
            combo += 1
            if let idx = targets.firstIndex(where: { $0.id == target.id }) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    targets[idx].isDestroyed = true
                }
            }
            
            // Check if all monsters of this question are gone (this shouldn't happen with bouncing unless we hit the correct one)
            // In our new logic, hitting the correct one moves to next question
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                nextQuestion()
            }
        } else {
            // Wrong
            AppTheme.notificationHaptic(.error)
            lives -= 1
            combo = 0
            if lives <= 0 {
                finishGame()
            }
            // Optional: destroy the wrong one too or keep it bouncing
            if let idx = targets.firstIndex(where: { $0.id == target.id }) {
                withAnimation {
                    targets[idx].isDestroyed = true
                }
            }
        }
    }
    
    private func finishGame() {
        if let best = deck.bestBlastScore {
            if score > best {
                isNewRecord = true
                deck.bestBlastScore = score
            }
        } else {
            isNewRecord = true
            deck.bestBlastScore = score
        }
        
        withAnimation {
            gameState = .finished
        }
    }
    
    private func shareBlastChallenge() {
        let template = Localization.string("game_blast_share_msg", lang: settings.appLanguage)
        let message = String(format: template, score, deck.title)
        presentShareMessage(message)
    }
}

// MARK: - Components

struct HUD: View {
    let lives: Int
    let score: Int
    let onExit: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onExit) {
                Image(systemName: "power")
                    .font(.title3.bold())
                    .foregroundStyle(.red)
                    .frame(width: 44, height: 44)
                    .background(Color.red.opacity(0.1))
                    .clipShape(Circle())
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                Image(systemName: "bolt.fill")
                    .foregroundStyle(.yellow)
                Text("\(score)")
                    .font(.system(.title3, design: .rounded).bold())
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(AppTheme.Colors.surface)
            .clipShape(Capsule())
            
            Spacer()
            
            HStack(spacing: 4) {
                ForEach(0..<3) { i in
                    Image(systemName: i < lives ? "shield.fill" : "shield")
                        .font(.system(size: 20))
                        .foregroundStyle(i < lives ? .blue : .gray)
                }
            }
        }
        .padding()
    }
}

struct MonsterView: View {
    let target: BlastTarget
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(target.color.opacity(0.2))
                    .frame(width: 80, height: 80)
                    .blur(radius: 10)
                
                Text(target.emoji)
                    .font(.system(size: 40))
                
                Circle()
                    .stroke(target.color, lineWidth: 2)
                    .frame(width: 60, height: 60)
            }
            
            Text(target.card.back)
                .font(AppTheme.font(.caption, weight: .black))
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(target.color.opacity(0.8))
                .clipShape(Capsule())
        }
    }
}
