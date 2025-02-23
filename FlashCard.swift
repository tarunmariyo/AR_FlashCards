import Foundation

struct FlashCard: Identifiable, Hashable {
    let id = UUID()
    let word: String
    let imageName: String
    let difficulty: Int
    let category: CardCategory
    
    enum CardCategory: String, CaseIterable, Hashable {
        case animals = "Animals"
        case fruits = "Fruits"
        case numbers = "Numbers"
        case colors = "Colors"
        case shapes = "Shapes"
        case actions = "Actions"
        
        var icon: String {
            switch self {
            case .animals: return "pawprint.fill"
            case .fruits: return "leaf.fill"
            case .numbers: return "number.circle.fill"
            case .colors: return "paintpalette.fill"
            case .shapes: return "square.on.circle.fill"
            case .actions: return "figure.walk"
            }
        }
    }
    
    static let cards = [
        FlashCard(word: "Apple", imageName: "apple", difficulty: 1, category: .fruits),
        FlashCard(word: "Banana", imageName: "banana", difficulty: 1, category: .fruits),
        FlashCard(word: "Cat", imageName: "cat", difficulty: 1, category: .animals),
        FlashCard(word: "Dog", imageName: "dog", difficulty: 1, category: .animals),
        FlashCard(word: "Elephant", imageName: "elephant", difficulty: 2, category: .animals),
        FlashCard(word: "Fish", imageName: "fish", difficulty: 1, category: .animals),
        FlashCard(word: "Giraffe", imageName: "giraffe", difficulty: 2, category: .animals),
        FlashCard(word: "Horse", imageName: "horse", difficulty: 1, category: .animals),
        // Numbers category
        FlashCard(word: "One", imageName: "number1", difficulty: 1, category: .numbers),
        FlashCard(word: "Two", imageName: "number2", difficulty: 1, category: .numbers),
        FlashCard(word: "Three", imageName: "number3", difficulty: 1, category: .numbers),
        // Colors category
        FlashCard(word: "Red", imageName: "red", difficulty: 1, category: .colors),
        FlashCard(word: "Blue", imageName: "blue", difficulty: 1, category: .colors),
        FlashCard(word: "Green", imageName: "green", difficulty: 1, category: .colors),
        // Shapes category
        FlashCard(word: "Circle", imageName: "circle", difficulty: 1, category: .shapes),
        FlashCard(word: "Square", imageName: "square", difficulty: 1, category: .shapes),
        FlashCard(word: "Triangle", imageName: "triangle", difficulty: 1, category: .shapes),
        // Actions category
        FlashCard(word: "Jump", imageName: "jump", difficulty: 1, category: .actions),
        FlashCard(word: "Run", imageName: "run", difficulty: 1, category: .actions),
        FlashCard(word: "Walk", imageName: "walk", difficulty: 1, category: .actions)
    ]
    
    static var randomCard: FlashCard {
        cards.randomElement() ?? cards[0]
    }
    
    static func cardsForCategory(_ category: CardCategory) -> [FlashCard] {
        cards.filter { $0.category == category }
    }
}