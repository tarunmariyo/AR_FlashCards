import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var isGameStarted = false
    @State private var isAnimating = false
    
    var body: some View {
        if isGameStarted {
            ARFlashcardGameView(card: FlashCard.randomCard)
        } else {
            // Welcome Screen
            ZStack {
                // Colorful background
                LinearGradient(
                    colors: [.blue, .purple],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Text("AR Flashcards!")
                        .font(.custom("Arial Rounded MT Bold", size: 40))
                        .foregroundColor(.white)
                        .scaleEffect(isAnimating ? 1.1 : 1.0)
                        .animation(Animation.easeInOut(duration: 1).repeatForever(), value: isAnimating)
                    
                    Image(systemName: "sparkles.rectangle.stack.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .foregroundColor(.yellow)
                        .rotationEffect(.degrees(isAnimating ? 360 : 0))
                        .animation(Animation.linear(duration: 3).repeatForever(autoreverses: false), value: isAnimating)
                    
                    Button(action: {
                        withAnimation {
                            isGameStarted = true
                        }
                    }) {
                        Text("Start Learning!")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.green)
                                    .shadow(radius: 10)
                            )
                    }
                    .scaleEffect(isAnimating ? 1.05 : 1.0)
                    .animation(Animation.easeInOut(duration: 1).repeatForever(), value: isAnimating)
                }
            }
            .onAppear {
                isAnimating = true
            }
        }
    }
}
