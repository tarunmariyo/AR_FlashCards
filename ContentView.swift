import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var isGameStarted = false
    @State private var isAnimating = false
    
    var body: some View {
        NavigationStack {
            if isGameStarted {
                FlashCardGameView(card: FlashCard.randomCard)
                    .navigationBarBackButtonHidden()
            } else {
                // Welcome Screen
                ZStack {
                    // Animated background gradient
                    LinearGradient(
                        colors: [.blue, .purple, .pink],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    .hueRotation(.degrees(isAnimating ? 45 : 0))
                    .animation(Animation.easeInOut(duration: 3).repeatForever(autoreverses: true), value: isAnimating)
                    
                    VStack(spacing: 30) {
                        Spacer()
                        
                        // Title with glow effect
                        Text("AR Flashcards!")
                            .font(.system(size: 50, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .white.opacity(0.5), radius: 10, x: 0, y: 0)
                            .scaleEffect(isAnimating ? 1.1 : 1.0)
                            .animation(Animation.easeInOut(duration: 1).repeatForever(), value: isAnimating)
                        
                        // Animated cards icon
                        ZStack {
                            ForEach(0..<3) { index in
                                Image(systemName: "rectangle.on.rectangle.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 180, height: 180)
                                    .foregroundColor(.white.opacity(0.8))
                                    .rotationEffect(.degrees(Double(index) * 30))
                                    .offset(y: isAnimating ? -10 : 0)
                                    .animation(
                                        Animation.easeInOut(duration: 1)
                                            .repeatForever()
                                            .delay(Double(index) * 0.2),
                                        value: isAnimating
                                    )
                            }
                        }
                        
                        Spacer()
                        
                        // Start button
                        Button(action: {
                            withAnimation(.spring()) {
                                isGameStarted = true
                            }
                        }) {
                            Text("Start Learning!")
                                .font(.title.bold())
                                .foregroundColor(.white)
                                .padding(.horizontal, 40)
                                .padding(.vertical, 20)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(
                                            LinearGradient(
                                                colors: [.green, .blue],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .shadow(radius: 10))
                        }
                        .scaleEffect(isAnimating ? 1.05 : 1.0)
                        .animation(Animation.easeInOut(duration: 1).repeatForever(), value: isAnimating)
                        .padding(.bottom, 50)
                    }
                }
                .navigationBarHidden(true)
                .onAppear {
                    isAnimating = true
                }
            }
        }
    }
}
