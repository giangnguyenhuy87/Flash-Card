import SwiftUI
import SwiftData

// MARK: - Folder (Thư mục)
@Model
class Folder {
    var id: UUID
    var name: String
    var emoji: String
    var colorHex: String
    var createdAt: Date
    
    var parentFolder: Folder?
    @Relationship(deleteRule: .cascade) var subfolders: [Folder] = []
    @Relationship(deleteRule: .nullify) var decks: [Deck] = []
    
    init(name: String, emoji: String = "📁", colorHex: String = "6366F1") {
        self.id = UUID()
        self.name = name
        self.emoji = emoji
        self.colorHex = colorHex
        self.createdAt = Date()
    }
}

// MARK: - ClassRoom (Lớp học)
@Model
class ClassRoom {
    var id: UUID
    var name: String
    var code: String // Unique class code for students to join
    var teacherName: String
    var createdAt: Date
    
    @Relationship(deleteRule: .cascade) var students: [Student] = []
    @Relationship(deleteRule: .nullify) var assignedDecks: [Deck] = []
    
    init(name: String, teacherName: String) {
        self.id = UUID()
        self.name = name
        self.code = String(format: "%06d", Int.random(in: 0...999999))
        self.teacherName = teacherName
        self.createdAt = Date()
    }
    
    var studentsCount: Int {
        students.count
    }
}

// MARK: - Student
@Model
class Student {
    var id: UUID
    var name: String
    var email: String?
    var joinedAt: Date
    
    var classRoom: ClassRoom?
    
    init(name: String, email: String? = nil) {
        self.id = UUID()
        self.name = name
        self.email = email
        self.joinedAt = Date()
    }
}

// MARK: - Deck (Updated)
@Model
class Deck {
    var id: UUID
    var title: String
    var emoji: String
    var language: String
    var colorHex: String
    var createdAt: Date
    var termLanguage: String
    var definitionLanguage: String
    var isPublic: Bool
    var canEditByOthers: Bool
    
    var folder: Folder?
    var bestMatchingTime: TimeInterval?
    var bestBlastScore: Int?
    var bestBlockScore: Int?
    @Relationship(deleteRule: .cascade) var cards: [Card] = []
    
    init(title: String, emoji: String = "📚", language: String = "English", colorHex: String = "6366F1") {
        self.id = UUID()
        self.title = title
        self.emoji = emoji
        self.language = language
        self.termLanguage = "Tiếng Anh"
        self.definitionLanguage = "Tiếng Việt"
        self.isPublic = true
        self.canEditByOthers = false
        self.colorHex = colorHex
        self.createdAt = Date()
    }
    
    var activeCardsCount: Int {
        cards.count
    }
    
    var dueCardsCount: Int {
        cards.filter { $0.isDue }.count
    }
}

// MARK: - Card (Unchanged)
@Model
class Card {
    var id: UUID
    var front: String
    var back: String
    var pronunciation: String?
    var example: String?
    var notes: String?
    @Attribute(.externalStorage) var imageData: Data?
    
    // Styling Properties
    var isFrontBold: Bool = false
    var isFrontItalic: Bool = false
    var isFrontUnderline: Bool = false
    var frontColor: String = "#FFFFFF"
    
    var isBackBold: Bool = false
    var isBackItalic: Bool = false
    var isBackUnderline: Bool = false
    var backColor: String = "#FFFFFF"
    // SRS Properties
    var lastReview: Date?
    var nextReview: Date
    var interval: Int // In days
    var easeFactor: Double
    var streak: Int
    var lastDifficulty: String? // e.g., "again", "hard", "good", "easy"
    
    var deck: Deck?
    
    init(front: String, back: String, pronunciation: String? = nil, example: String? = nil) {
        self.id = UUID()
        self.front = front
        self.back = back
        self.pronunciation = pronunciation
        self.example = example
        
        // Initial SRS state
        self.nextReview = Date()
        self.interval = 0
        self.easeFactor = 2.5
        self.streak = 0
        self.lastDifficulty = nil
    }
    
    var isDue: Bool {
        nextReview <= Date()
    }
    
    /// Returns the example with the target word masked, e.g., "The [___] is red"
    var maskedExample: String? {
        guard let example = example, !example.isEmpty else { return nil }
        
        // Simple case-insensitive replacement
        let term = front.trimmingCharacters(in: .whitespaces)
        guard !term.isEmpty else { return example }
        
        let pattern = "(?i)" + NSRegularExpression.escapedPattern(for: term)
        if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            let range = NSRange(location: 0, length: example.utf16.count)
            return regex.stringByReplacingMatches(in: example, options: [], range: range, withTemplate: "[___]")
        }
        
        return example
    }
}

// MARK: - SRS Logic (SM-2 Inspired)
extension Card {
    enum Difficulty {
        case again, hard, good, easy
    }
    
    func review(difficulty: Difficulty) {
        let now = Date()
        lastReview = now
        
        switch difficulty {
        case .again:
            streak = 0
            interval = 1
            lastDifficulty = "again"
            
        case .hard:
            streak += 1
            interval = max(1, Int(Double(interval) * 1.2))
            easeFactor = max(1.3, easeFactor - 0.15)
            lastDifficulty = "hard"
            
        case .good:
            streak += 1
            if streak == 1 {
                interval = 1
            } else if streak == 2 {
                interval = 6
            } else {
                interval = Int(Double(interval) * easeFactor)
            }
            lastDifficulty = "good"
            
        case .easy:
            streak += 1
            if streak == 1 {
                interval = 4
            } else if streak == 2 {
                interval = 10
            } else {
                interval = Int(Double(interval) * easeFactor * 1.3)
            }
            easeFactor += 0.15
            lastDifficulty = "easy"
        }
        
        if difficulty == .again {
            nextReview = Calendar.current.date(byAdding: .minute, value: 5, to: now) ?? now
        } else {
            nextReview = Calendar.current.date(byAdding: .day, value: interval, to: now) ?? now
        }
    }
}
