import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var isAnimating = false
    @State private var shouldNavigate = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Animated background gradient
                LinearGradient(
                    colors: [.blue, .purple, .pink],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                .hueRotation(.degrees(isAnimating ? 45 : 0))
                .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: isAnimating)
                
                VStack(spacing: 30) {
                    Spacer()
                    
                    // Title with glow effect
                    Text("AR Flashcards!")
                        .font(.system(size: 50, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .white.opacity(0.5), radius: 10, x: 0, y: 0)
                        .scaleEffect(isAnimating ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isAnimating)
                    
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
                                    .easeInOut(duration: 1)
                                        .repeatForever(autoreverses: true)
                                        .delay(Double(index) * 0.1),
                                    value: isAnimating
                                )
                        }
                    }
                    
                    Spacer()
                }
            }
            .navigationDestination(isPresented: $shouldNavigate) {
                DashboardView()
            }
            .onAppear {
                isAnimating = true
                // Automatically navigate to DashboardView after 2 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    shouldNavigate = true
                }
            }
        }
    }

}
