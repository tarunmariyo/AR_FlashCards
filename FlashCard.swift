import Foundation

struct FlashCard: Identifiable {
    let id = UUID()
    let word: String
    let imageName: String
    let difficulty: Int
    
    static let cards = [
        FlashCard(word: "Apple", imageName: "apple", difficulty: 1),
        FlashCard(word: "Banana", imageName: "banana", difficulty: 1),
        FlashCard(word: "Cat", imageName: "cat", difficulty: 1),
        FlashCard(word: "Dog", imageName: "dog", difficulty: 1),
        FlashCard(word: "Elephant", imageName: "elephant", difficulty: 2),
        FlashCard(word: "Fish", imageName: "fish", difficulty: 1),
        FlashCard(word: "Giraffe", imageName: "giraffe", difficulty: 2),
        FlashCard(word: "Horse", imageName: "horse", difficulty: 1)
    ]
    
    static var randomCard: FlashCard {
        cards.randomElement() ?? cards[0]
    }
} 