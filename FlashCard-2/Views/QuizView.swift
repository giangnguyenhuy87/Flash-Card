import SwiftUI
import SwiftData

enum QuizModeType {
    case cram // Trắc nghiệm, chuẩn bị thi
    case longTerm // Tự luận + Ghi nhớ sâu (SRS)
}

struct QuizView: View {
    @Bindable var deck: Deck
    var mode: QuizModeType
    
    @Environment(\.dismiss) var dismiss
    @State private var quizCards: [Card] = []
    @State private var currentIndex = 0
    @State private var score = 0
    @State private var showResult = false
    @State private var showHint = false
    
    // MCQ State (Cram)
    @State private var options: [String] = []
    @State private var selectedOption: String? = nil
    @State private var isCorrect: Bool? = nil
    
    // Written State (Long-term)
    @State private var userInput = ""
    @State private var isAnswerShowing = false
    
    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()
            
            VStack {
                // Header & Progress
                quizHeader
                
                if showResult {
                    quizResultView
                } else if !quizCards.isEmpty {
                    VStack(spacing: 32) {
                        // Current Question
                        questionSection
                        
                        // Answer Methods
                        if mode == .cram {
                            multipleChoiceSection
                        } else {
                            writtenAnswerSection
                        }
                    }
                    .padding(.horizontal, 24)
                }
                
                Spacer()
                
                // Navigation / Footer
                if let _ = selectedOption, mode == .cram {
                    nextButton
                } else if isAnswerShowing, mode == .longTerm {
                    nextButton
                }
            }
        }
        .onAppear {
            setupQuiz()
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Subviews
    
    private var quizHeader: some View {
        VStack(spacing: 12) {
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.title3.bold())
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
                
                Spacer()
                
                Text(mode == .cram ? "Nhồi nhét (Thi)" : "Ghi nhớ lâu dài")
                    .font(AppTheme.font(.headline, weight: .bold))
                    .foregroundStyle(.white)
                
                Spacer()
                
                Button {
                    withAnimation {
                        quizCards.shuffle()
                        currentIndex = 0
                        score = 0
                        generateOptions()
                    }
                } label: {
                    Image(systemName: "shuffle")
                        .font(.body.bold())
                        .foregroundStyle(AppTheme.Colors.primary)
                }
            }
            .padding(.horizontal)
            
            // Progress Bar
            if !quizCards.isEmpty {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.white.opacity(0.1))
                        Capsule()
                            .fill(AppTheme.Colors.primaryGradient)
                            .frame(width: geo.size.width * CGFloat(currentIndex + 1) / CGFloat(quizCards.count))
                    }
                }
                .frame(height: 6)
                .padding(.horizontal, 24)
            }
        }
        .padding(.vertical)
    }
    
    private var questionSection: some View {
        VStack(spacing: 24) {
            Text("Nghĩa của từ này là gì?")
                .font(AppTheme.font(.subheadline))
                .foregroundStyle(AppTheme.Colors.textSecondary)
            
            if let data = quizCards[currentIndex].imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.2), radius: 8)
            }
            
            VStack(spacing: 8) {
                Text(quizCards[currentIndex].front)
                    .font(.system(size: 40, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                
                if let hint = quizCards[currentIndex].maskedExample, showHint {
                    Text(hint)
                        .font(AppTheme.font(.body, weight: .medium, italic: true))
                        .foregroundStyle(AppTheme.Colors.primary.opacity(0.8))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(AppTheme.Colors.primary.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .transition(.asymmetric(insertion: .move(edge: .top).combined(with: .opacity), removal: .opacity))
                        .padding(.top, 8)
                }
            }
            .overlay(alignment: .topTrailing) {
                if quizCards[currentIndex].example != nil {
                    Button {
                        withAnimation(.spring()) {
                            showHint.toggle()
                            AppTheme.haptic(.light)
                        }
                    } label: {
                        Image(systemName: showHint ? "lightbulb.fill" : "lightbulb")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(showHint ? .yellow : AppTheme.Colors.textSecondary)
                            .padding(10)
                            .background(Material.ultraThin)
                            .clipShape(Circle())
                    }
                    .offset(x: 40, y: -40)
                }
            }
        }
        .padding(.vertical, 20)
    }
    
    private var multipleChoiceSection: some View {
        VStack(spacing: 12) {
            ForEach(options, id: \.self) { option in
                Button {
                    handleOptionSelected(option)
                } label: {
                    HStack {
                        Text(option)
                            .font(AppTheme.font(.body, weight: .semibold))
                        Spacer()
                        if selectedOption == option {
                            Image(systemName: isCorrect == true ? "checkmark.circle.fill" : "xmark.circle.fill")
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(buttonBackgroundColor(for: option))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(buttonBorderColor(for: option), lineWidth: 2)
                    )
                    .foregroundStyle(.white)
                }
                .disabled(selectedOption != nil)
            }
        }
    }
    
    private var writtenAnswerSection: some View {
        VStack(spacing: 24) {
            if isAnswerShowing {
                VStack(spacing: 12) {
                    Text("Đáp án đúng:")
                        .font(AppTheme.font(.caption))
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                    
                    Text(quizCards[currentIndex].back)
                        .font(AppTheme.font(.title3, weight: .bold))
                        .foregroundStyle(.green)
                    
                    if let example = quizCards[currentIndex].example {
                        Text("\"\(example)\"")
                            .font(AppTheme.font(.callout, weight: .medium))
                            .foregroundStyle(AppTheme.Colors.textSecondary)
                            .italic()
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.green.opacity(0.1))
                .cornerRadius(20)
            } else {
                TextField("Nhập định nghĩa...", text: $userInput)
                    .padding(20)
                    .background(AppTheme.Colors.surface)
                    .cornerRadius(20)
                    .foregroundStyle(.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(AppTheme.Colors.surfaceHighlight, lineWidth: 1)
                    )
                    .onSubmit {
                        checkWrittenAnswer()
                    }
                
                Button {
                    checkWrittenAnswer()
                } label: {
                    Text("Kiểm tra")
                        .font(AppTheme.font(.headline, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.Colors.primaryGradient)
                        .clipShape(Capsule())
                }
            }
        }
    }
    
    private var nextButton: some View {
        Button {
            moveToNext()
        } label: {
            HStack {
                Text(currentIndex == quizCards.count - 1 ? "Xem kết quả" : "Tiếp theo")
                Image(systemName: "arrow.right")
            }
            .font(AppTheme.font(.headline, weight: .bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 32)
            .padding(.vertical, 16)
            .background(AppTheme.Colors.primaryGradient)
            .clipShape(Capsule())
            .shadow(color: AppTheme.Colors.primary.opacity(0.4), radius: 10, x: 0, y: 5)
        }
        .padding(.bottom, 40)
    }
    
    private var quizResultView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 32) {
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.1), lineWidth: 20)
                        .frame(width: 200, height: 200)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(score) / CGFloat(quizCards.count))
                        .stroke(
                            AppTheme.Colors.primaryGradient,
                            style: StrokeStyle(lineWidth: 20, lineCap: .round)
                        )
                        .frame(width: 200, height: 200)
                        .rotationEffect(.degrees(-90))
                    
                    VStack {
                        Text("\(Int(Double(score) / Double(quizCards.count) * 100))%")
                            .font(.system(size: 40, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                        Text("Hoàn thành")
                            .font(AppTheme.font(.caption))
                            .foregroundStyle(AppTheme.Colors.textSecondary)
                    }
                }
                .padding(.top, 40)
                
                VStack(spacing: 8) {
                    Text("Kết quả của bạn")
                        .font(AppTheme.font(.title2, weight: .bold))
                        .foregroundStyle(.white)
                    
                    Text("Bạn đã trả lời đúng \(score) / \(quizCards.count) câu hỏi.")
                        .font(AppTheme.font(.body))
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
                
                VStack(spacing: 12) {
                    Button {
                        withAnimation {
                            currentIndex = 0
                            score = 0
                            showResult = false
                            setupQuiz()
                        }
                    } label: {
                        Text("Làm lại bài kiểm tra")
                            .font(AppTheme.font(.headline, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.Colors.primaryGradient)
                            .clipShape(Capsule())
                    }
                    
                    Button {
                        shareQuizChallenge()
                    } label: {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Thách đấu bạn bè")
                        }
                        .font(AppTheme.font(.headline, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.Colors.secondaryGradient)
                        .clipShape(Capsule())
                        .shadow(color: AppTheme.Colors.secondary.opacity(0.3), radius: 8)
                    }

                    Button {
                        dismiss()
                    } label: {
                        Text("Quay lại")
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
                .padding(.bottom, 110)
            }
            .padding(.horizontal, 40)
        }
    }
    
    // MARK: - Logic
    
    private func setupQuiz() {
        quizCards = deck.cards.shuffled()
        if mode == .cram {
            generateOptions()
        }
    }
    
    private func generateOptions() {
        guard !quizCards.isEmpty else { return }
        let correct = quizCards[currentIndex].back
        var allOptions = [correct]
        
        // Pick 3 random distractors from other cards in the deck
        let otherCards = deck.cards.filter { $0.back != correct }
        let distractors = otherCards.shuffled().prefix(3).map { $0.back }
        allOptions.append(contentsOf: distractors)
        
        // Fill with placeholders if not enough cards
        while allOptions.count < 4 {
            allOptions.append("Đáp án giả \(allOptions.count)")
        }
        
        options = allOptions.shuffled()
    }
    
    private func handleOptionSelected(_ option: String) {
        selectedOption = option
        isCorrect = (option == quizCards[currentIndex].back)
        if isCorrect == true {
            score += 1
            AppTheme.notificationHaptic(.success)
        } else {
            AppTheme.notificationHaptic(.error)
        }
    }
    
    private func checkWrittenAnswer() {
        let correct = quizCards[currentIndex].back.lowercased().trimmingCharacters(in: .whitespaces)
        let user = userInput.lowercased().trimmingCharacters(in: .whitespaces)
        
        if user == correct {
            score += 1
            AppTheme.notificationHaptic(.success)
        } else {
            AppTheme.notificationHaptic(.error)
        }
        
        withAnimation {
            isAnswerShowing = true
        }
    }
    
    private func moveToNext() {
        if currentIndex < quizCards.count - 1 {
            withAnimation {
                currentIndex += 1
                selectedOption = nil
                isCorrect = nil
                userInput = ""
                isAnswerShowing = false
                showHint = false
                if mode == .cram {
                    generateOptions()
                }
            }
        } else {
            withAnimation {
                showResult = true
            }
        }
    }
    
    private func buttonBackgroundColor(for option: String) -> Color {
        guard let selected = selectedOption else { return AppTheme.Colors.surface }
        
        if option == quizCards[currentIndex].back {
            return Color.green.opacity(0.2)
        }
        
        if selected == option {
            return Color.red.opacity(0.2)
        }
        
        return AppTheme.Colors.surface
    }
    
    private func buttonBorderColor(for option: String) -> Color {
        guard let selected = selectedOption else { return AppTheme.Colors.surfaceHighlight }
        
        if option == quizCards[currentIndex].back {
            return Color.green
        }
        
        if selected == option {
            return Color.red
        }
        
        return AppTheme.Colors.surfaceHighlight
    }
    
    private func shareQuizChallenge() {
        let percentage = Int(Double(score) / Double(quizCards.count) * 100)
        let message = "Tôi vừa hoàn thành bài kiểm tra '\(deck.title)' với kết quả \(score)/\(quizCards.count) (\(percentage)%)! Bạn có tự tin đạt điểm cao hơn không? 📝🔥\nTải LuminaCards ngay!"
        presentShareMessage(message)
    }
}
