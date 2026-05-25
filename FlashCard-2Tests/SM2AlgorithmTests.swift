import XCTest
@testable import FlashCard_2

final class SM2AlgorithmTests: XCTestCase {
    
    var card: Card!
    
    override func setUpWithError() throws {
        super.setUp()
        // Initialize a clean card for testing
        card = Card(front: "Hello", back: "Xin chào", pronunciation: "/həˈloʊ/", example: "Hello, world!")
    }
    
    override func tearDownWithError() throws {
        card = nil
        super.tearDown()
    }
    
    func testInitialCardState() {
        XCTAssertEqual(card.front, "Hello")
        XCTAssertEqual(card.back, "Xin chào")
        XCTAssertEqual(card.streak, 0)
        XCTAssertEqual(card.interval, 0)
        XCTAssertEqual(card.easeFactor, 2.5)
        XCTAssertNil(card.lastDifficulty)
        XCTAssertTrue(card.isDue, "Initial card should be due for review immediately")
    }
    
    func testReviewAgain() {
        // Perform a review with 'Again' difficulty
        card.review(difficulty: .again)
        
        XCTAssertEqual(card.streak, 0, "Streak should reset to 0 on 'Again'")
        XCTAssertEqual(card.interval, 1, "Interval should reset to 1 day on 'Again'")
        XCTAssertEqual(card.lastDifficulty, "again")
        XCTAssertNotNil(card.lastReview)
        
        // Next review should be ~5 minutes in the future
        let difference = card.nextReview.timeIntervalSince(Date())
        XCTAssertTrue(difference > 0 && difference <= 300, "Next review should be scheduled ~5 minutes from now")
    }
    
    func testReviewEasyFirstTime() {
        // Perform an 'Easy' review for the first time
        card.review(difficulty: .easy)
        
        XCTAssertEqual(card.streak, 1)
        XCTAssertEqual(card.interval, 4, "First easy review should set interval to 4 days")
        XCTAssertEqual(card.easeFactor, 2.65, "Ease factor should increase by 0.15")
        XCTAssertEqual(card.lastDifficulty, "easy")
        
        // Next review should be scheduled ~4 days in the future
        let daysDifference = Calendar.current.dateComponents([.day], from: Date(), to: card.nextReview).day ?? 0
        XCTAssertEqual(daysDifference, 4)
    }
    
    func testReviewGoodMultipleTimes() {
        // Round 1: Good review
        card.review(difficulty: .good)
        XCTAssertEqual(card.streak, 1)
        XCTAssertEqual(card.interval, 1)
        
        // Round 2: Good review
        card.review(difficulty: .good)
        XCTAssertEqual(card.streak, 2)
        XCTAssertEqual(card.interval, 6)
        
        // Round 3: Good review
        // Interval should be current interval (6) * easeFactor (2.5) = 15
        card.review(difficulty: .good)
        XCTAssertEqual(card.streak, 3)
        XCTAssertEqual(card.interval, 15)
    }
    
    func testReviewHardReducesEaseFactor() {
        let initialEaseFactor = card.easeFactor
        
        // Review hard
        card.review(difficulty: .hard)
        
        XCTAssertEqual(card.streak, 1)
        XCTAssertEqual(card.easeFactor, initialEaseFactor - 0.15, "Hard difficulty should reduce ease factor by 0.15")
        XCTAssertEqual(card.lastDifficulty, "hard")
    }
}
