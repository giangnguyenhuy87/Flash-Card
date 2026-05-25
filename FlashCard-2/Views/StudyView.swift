import SwiftUI
import SwiftData

struct StudyView: View {
    @Bindable var deck: Deck
    @State private var studyCards: [Card] = []
    @State private var currentIndex: Int = 0
    
    // View State
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var settings: AppSettings
    
    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()
            
            VStack {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundStyle(AppTheme.Colors.textSecondary)
                            .padding()
                            .background(Material.ultraThin)
                            .clipShape(Circle())
                    }
                    Spacer()
                    Text("\(currentIndex + 1) / \(studyCards.count)")
                        .font(AppTheme.font(.headline).monospacedDigit())
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
                .padding()
                
                Spacer()
                
                // Card Stack
                if studyCards.isEmpty {
                    Text(Localization.string("study_empty_msg", lang: settings.appLanguage))
                        .font(AppTheme.font(.title3))
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                } else if currentIndex < studyCards.count {
                    ZStack {
                        // Background cards (visual stack effect) - Show 2 cards behind
                        ForEach((currentIndex + 1...currentIndex + 2).reversed(), id: \.self) { index in
                            if index < studyCards.count {
                                let card = studyCards[index]
                                FlashcardView(card: card, isTopCard: false)
                                    .scaleEffect(1.0 - CGFloat(index - currentIndex) * 0.05)
                                    .offset(y: CGFloat(index - currentIndex) * 12)
                                    .opacity(1.0 - CGFloat(index - currentIndex) * 0.3)
                                    .zIndex(Double(-index))
                                    .id(card.id) // Ensure state is tied to the card object
                            }
                        }
                        
                        // Top Interactive Card
                        FlashcardView(
                            card: studyCards[currentIndex],
                            isTopCard: true,
                            onSwiped: { direction in
                                handleSwipe(direction)
                            }
                        )
                        .id(studyCards[currentIndex].id) // CRITICAL: Forces local state reset for each new card
                        .zIndex(1)
                    }
                    .frame(height: 420) // Reduced from 480 to fit all screens
                    .padding(.horizontal, 20)
                } else {
                    // Session Complete
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 60))
                                .foregroundStyle(AppTheme.Colors.primary)
                            
                            Text(Localization.string("study_session_complete", lang: settings.appLanguage))
                                .font(AppTheme.font(.title3, weight: .bold))
                                .foregroundStyle(.white)
                            
                            Text(Localization.string("study_complete_msg", lang: settings.appLanguage))
                                .font(AppTheme.font(.caption))
                                .foregroundStyle(AppTheme.Colors.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                            
                            VStack(spacing: 12) {
                                Button(action: {
                                    withAnimation {
                                        currentIndex = 0
                                        loadCards()
                                    }
                                }) {
                                    Text(Localization.string("study_restart", lang: settings.appLanguage))
                                        .font(AppTheme.font(.headline, weight: .bold))
                                        .foregroundStyle(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(AppTheme.Colors.primaryGradient)
                                        .clipShape(Capsule())
                                }
                                
                                Button {
                                    shareStudyChallenge()
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
                                
                                Button(action: { dismiss() }) {
                                    Text(Localization.string("study_back_home", lang: settings.appLanguage))
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
                            }
                            .padding(.horizontal, 40)
                            .padding(.bottom, 110)
                        }
                        .padding(.top, 40)
                    }
                }
                
                Spacer()
                
                // SRS Controls (Only show if card is not flipped? Or always? Usually after flip.)
                // For simplicity in this swipe-focused UI, we might hide these until flipped, 
                // but let's put them at the bottom.
                if currentIndex < studyCards.count {
                    HStack(spacing: 8) { // Reduced spacing
                        SRSButton(label: Localization.string("study_again", lang: settings.appLanguage), color: AppTheme.Colors.error) { recordResult(.again) }
                        SRSButton(label: Localization.string("study_hard", lang: settings.appLanguage), color: AppTheme.Colors.warning) { recordResult(.hard) }
                        SRSButton(label: Localization.string("study_good", lang: settings.appLanguage), color: AppTheme.Colors.secondary) { recordResult(.good) }
                        SRSButton(label: Localization.string("study_easy", lang: settings.appLanguage), color: AppTheme.Colors.success) { recordResult(.easy) }
                    }
                    .padding(.bottom, 90) // Increased from 20 to clear the custom TabBar
                    .padding(.horizontal, 12)
                }
            }
        }
        .onAppear {
            loadCards()
        }
        .navigationBarHidden(true)
    }
    
    // Logic to show next few cards for stack effect
    var stackIndices: [Int] {
        ((currentIndex + 1)...min(currentIndex + 3, studyCards.count - 1)).map { $0 }
    }
    
    func loadCards() {
        // In a real app, strict filtering for 'isDue' would happen here.
        // For demo, we just take all cards in the deck.
        studyCards = deck.cards.sorted(by: { $0.nextReview < $1.nextReview })
    }
    
    func handleSwipe(_ direction: SwipeDirection) {
        let difficulty: Card.Difficulty = (direction == .right) ? .good : .again
        recordResult(difficulty)
    }
    
    func recordResult(_ difficulty: Card.Difficulty) {
        guard currentIndex < studyCards.count else { return }
        
        // Notify the card view to "perform" the fly out animation visually
        NotificationCenter.default.post(name: NSNotification.Name("TriggerFlyOut"), object: nil, userInfo: ["difficulty": difficulty])
        
        // Impact Feedback immediately
        AppTheme.haptic(.medium)
        
        // Slight delay to allow fly out animation to finish
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                studyCards[currentIndex].review(difficulty: difficulty)
                currentIndex += 1
            }
        }
    }
    
    func shareStudyChallenge() {
        let template = Localization.string("study_share_msg", lang: settings.appLanguage)
        let message = String(format: template, deck.title)
        presentShareMessage(message)
    }
}

enum SwipeDirection {
    case left, right
}

struct FlashcardView: View {
    @EnvironmentObject var settings: AppSettings
    let card: Card
    let isTopCard: Bool
    var onSwiped: ((SwipeDirection) -> Void)?
    
    @State private var isFlipped = false
    @State private var showHint = false
    @State private var offset: CGSize = .zero
    @State private var triggeredDifficulty: Card.Difficulty? = nil
    
    // Stickers for each level
    private var stickerLabel: String? {
        if let triggered = triggeredDifficulty {
            switch triggered {
            case .again: return Localization.string("study_again", lang: settings.appLanguage).uppercased()
            case .hard: return Localization.string("study_hard", lang: settings.appLanguage).uppercased()
            case .good: return Localization.string("study_good", lang: settings.appLanguage).uppercased()
            case .easy: return Localization.string("study_easy", lang: settings.appLanguage).uppercased()
            }
        }
        if offset.width > 50 { return Localization.string("study_good", lang: settings.appLanguage).uppercased() }
        if offset.width < -50 { return Localization.string("study_again", lang: settings.appLanguage).uppercased() }
        return nil
    }
    
    private var stickerColor: Color {
        if let triggered = triggeredDifficulty {
            switch triggered {
            case .again: return .red
            case .hard: return .orange
            case .good: return .blue
            case .easy: return .green
            }
        }
        if offset.width > 0 { return .blue }
        if offset.width < 0 { return .red }
        return .clear
    }
    
    var body: some View {
        ZStack {
            // Main Card Content
            ZStack {
                // BACK (Answer)
                CardFace(
                    content: card.back,
                    subtext: card.pronunciation ?? "",
                    isFlipped: true,
                    isBold: card.isBackBold,
                    isItalic: card.isBackItalic,
                    isUnderline: card.isBackUnderline,
                    textColor: card.backColor,
                    imageData: card.imageData
                )
                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                    .opacity(isFlipped ? 1 : 0)
                
                // FRONT (Question)
                CardFace(
                    content: card.front,
                    subtext: Localization.string("study_tap_to_flip", lang: settings.appLanguage),
                    isFlipped: false,
                    isBold: card.isFrontBold,
                    isItalic: card.isFrontItalic,
                    isUnderline: card.isFrontUnderline,
                    textColor: card.frontColor,
                    imageData: nil,
                    hint: showHint ? card.maskedExample : nil
                )
                    .opacity(isFlipped ? 0 : 1)
                    .overlay(alignment: .topTrailing) {
                        if isTopCard && !isFlipped && card.example != nil {
                            Button {
                                withAnimation(.spring()) {
                                    showHint.toggle()
                                    AppTheme.haptic(.light)
                                }
                            } label: {
                                Image(systemName: showHint ? "lightbulb.fill" : "lightbulb")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundStyle(showHint ? .yellow : AppTheme.Colors.textSecondary)
                                    .padding(12)
                                    .background(Material.ultraThin)
                                    .clipShape(Circle())
                                    .shadow(color: showHint ? .yellow.opacity(0.3) : .clear, radius: 10)
                            }
                            .padding(16)
                        }
                    }
            }
            .rotation3DEffect(
                .degrees(isFlipped ? 180 : 0),
                axis: (x: 0, y: 1, z: 0),
                perspective: 0.8
            )
            
            // Swipe Overlay Stickers
            if isTopCard, let label = stickerLabel {
                VStack {
                    HStack {
                        if (triggeredDifficulty != nil && triggeredDifficulty != .again) || offset.width > 0 {
                            stickerView(label: label, color: stickerColor, rotate: -15)
                            Spacer()
                        } else if triggeredDifficulty == .again || offset.width < 0 {
                            Spacer()
                            stickerView(label: label, color: stickerColor, rotate: 15)
                        }
                    }
                    .padding(30)
                    Spacer()
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("TriggerFlyOut"))) { notification in
            guard isTopCard, let diff = notification.userInfo?["difficulty"] as? Card.Difficulty else { return }
            
            withAnimation(.easeIn(duration: 0.3)) {
                triggeredDifficulty = diff
                if diff == .again {
                    offset.width = -1000
                } else {
                    offset.width = 1000
                }
            }
        }
        // Swipe Physics
        .rotationEffect(.degrees(Double(offset.width / 15)))
        .offset(x: offset.width, y: offset.height * 0.4)
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    guard isTopCard else { return }
                    offset = gesture.translation
                }
                .onEnded { gesture in
                    guard isTopCard else { return }
                    
                    let velocity = gesture.predictedEndTranslation.width
                    if offset.width > 120 || velocity > 250 {
                        // Swipe Right (Good implicitly)
                        withAnimation(.spring()) {
                            triggeredDifficulty = .good
                            offset.width = 1000
                            onSwiped?(.right)
                        }
                    } else if offset.width < -120 || velocity < -250 {
                        // Swipe Left (Again implicitly)
                        withAnimation(.spring()) {
                            triggeredDifficulty = .again
                            offset.width = -1000
                            onSwiped?(.left)
                        }
                    } else {
                        // Return to center
                        withAnimation(.interpolatingSpring(stiffness: 150, damping: 15)) {
                            offset = .zero
                            triggeredDifficulty = nil
                        }
                    }
                }
        )
        .onTapGesture {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                isFlipped.toggle()
                AppTheme.haptic(.light)
            }
        }
    }
    
    private func stickerView(label: String, color: Color, rotate: Double) -> some View {
        Text(label)
            .font(AppTheme.font(.title3, weight: .black))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(color.opacity(0.8))
            .foregroundStyle(.white)
            .cornerRadius(8)
            .rotationEffect(.degrees(rotate))
            .opacity(triggeredDifficulty != nil ? 1 : Double(min(abs(offset.width) / 50, 1.0)))
    }
}

struct SRSButton: View {
    let label: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            AppTheme.haptic(.medium)
            action()
        }) {
            Text(label)
                .font(AppTheme.font(.caption, weight: .bold)) // Smaller font
                .foregroundStyle(.white)
                .padding(.vertical, 14)
                .padding(.horizontal, 12) // Smaller horizontal padding
                .frame(maxWidth: .infinity) // Make buttons equal width
                .background(color)
                .clipShape(Capsule())
                .shadow(color: color.opacity(0.3), radius: 6, x: 0, y: 3)
        }
    }
}

struct CardFace: View {
    let content: String
    let subtext: String
    let isFlipped: Bool
    let isBold: Bool
    let isItalic: Bool
    let isUnderline: Bool
    let textColor: String
    let imageData: Data?
    var hint: String? = nil
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                if let data = imageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 180)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .black.opacity(0.2), radius: 10)
                }
                
                VStack(spacing: 12) {
                    Text(content)
                        .font(AppTheme.font(.largeTitle, weight: isBold ? .black : .bold, italic: isItalic))
                        .underline(isUnderline)
                        .foregroundStyle(isFlipped ? LinearGradient(colors: [Color(hex: textColor)], startPoint: .top, endPoint: .bottom) : LinearGradient(colors: [Color(hex: textColor == "#FFFFFF" ? "FFFFFF" : textColor)], startPoint: .top, endPoint: .bottom))
                        .multilineTextAlignment(.center)
                    
                    if !subtext.isEmpty {
                        Text(subtext)
                            .font(AppTheme.font(.title3, weight: .medium))
                            .foregroundStyle(AppTheme.Colors.textSecondary)
                    }
                    
                    if let hint = hint {
                        Text(hint)
                            .font(AppTheme.font(.body, weight: .medium, italic: true))
                            .foregroundStyle(AppTheme.Colors.primary.opacity(0.8))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(AppTheme.Colors.primary.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .genZCardStyle()
    }
}
