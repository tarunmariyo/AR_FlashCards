import SwiftUI

struct Category: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let color: Color
    let cards: [FlashCard]
}

struct CircularProgressView: View {
    let progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(.blue.opacity(0.2), lineWidth: 4)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(.blue, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
    }
}

struct ScoreCardView: View {
    let totalScore: Int
    let totalPossibleScore: Int
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Score")
                    .font(.headline)
                
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(totalScore)")
                        .font(.system(size: 40, weight: .bold))
                    Text("/\(totalPossibleScore)")
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            CircularProgressView(progress: Double(totalScore) / Double(totalPossibleScore))
                .frame(width: 44, height: 44)
                .overlay {
                    Text("\(Int((Double(totalScore) / Double(totalPossibleScore)) * 100))%")
                        .font(.caption2.bold())
                        .foregroundColor(.blue)
                }
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct DashboardView: View {
    @State private var selectedCategory: FlashCard.CardCategory?
    @AppStorage("totalScore") private var totalScore = 0
    
    private var categories: [FlashCard.CardCategory] = [.animals, .fruits, .numbers, .colors, .shapes, .actions]
    
    private var totalPossibleScore: Int {
        FlashCard.cards.count
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Score card
                ScoreCardView(totalScore: totalScore, totalPossibleScore: totalPossibleScore)
                
                // Categories
                Text("Choose a Category")
                    .font(.title.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Category cards in a grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(categories, id: \.self) { category in
                        NavigationLink(destination: FlashCardGameView(card: FlashCard.cardsForCategory(category).randomElement()!)) {
                            CategoryCard(category: category)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Flashcards")
        .background(
            LinearGradient(colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                          startPoint: .topLeading,
                          endPoint: .bottomTrailing)
            .ignoresSafeArea()
        )
    }
}

struct CategoryCard: View {
    let category: FlashCard.CardCategory
    
    var backgroundGradient: LinearGradient {
        switch category {
        case .animals:
            return LinearGradient(
                colors: [
                    Color(red: 0.98, green: 0.5, blue: 0.2),  // Warm orange
                    Color(red: 1.0, green: 0.7, blue: 0.4)    // Light orange
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .fruits:
            return LinearGradient(
                colors: [
                    Color(red: 0.2, green: 0.8, blue: 0.5),   // Emerald green
                    Color(red: 0.4, green: 0.9, blue: 0.6)    // Light green
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .numbers:
            return LinearGradient(
                colors: [
                    Color(red: 0.4, green: 0.6, blue: 1.0),   // Blue
                    Color(red: 0.6, green: 0.8, blue: 1.0)    // Light blue
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .colors:
            return LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.4, blue: 0.7),   // Pink
                    Color(red: 1.0, green: 0.6, blue: 0.8)    // Light pink
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .shapes:
            return LinearGradient(
                colors: [
                    Color(red: 0.6, green: 0.4, blue: 0.8),   // Purple
                    Color(red: 0.8, green: 0.6, blue: 1.0)    // Light purple
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .actions:
            return LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.6, blue: 0.2),   // Orange
                    Color(red: 1.0, green: 0.8, blue: 0.4)    // Light orange
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Category icon and name
            VStack(spacing: 12) {
                Image(systemName: category.icon)
                    .font(.system(size: 60))
                    .foregroundColor(.white)
                
                Text(category.rawValue)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Text("\(FlashCard.cardsForCategory(category).count) words")
                .foregroundColor(.white.opacity(0.8))
        }
        .padding()
        .frame(width: 160, height: 200)
        .background(backgroundGradient)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
    }
}



