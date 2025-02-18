import SwiftUI
import UIKit

struct CelebrationView: View {
    @State private var particles: [(CGPoint, Color)] = []
    
    var body: some View {
        ZStack {
            // Celebration particles
            ForEach(0..<particles.count, id: \.self) { index in
                Circle()
                    .fill(particles[index].1)
                    .frame(width: 10, height: 10)
                    .position(particles[index].0)
            }
            
            // Success message
            Text("Correct! 🎉")
                .font(.largeTitle.bold())
                .foregroundColor(.white)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.green.opacity(0.8))
                        .shadow(radius: 5)
                )
        }
        .onAppear {
            createParticles()
        }
    }
    
    private func createParticles() {
        let colors: [Color] = [.red, .blue, .green, .yellow, .purple, .orange]
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        for _ in 0..<50 {
            let position = CGPoint(
                x: CGFloat.random(in: 0...screenWidth),
                y: CGFloat.random(in: 0...screenHeight)
            )
            let color = colors.randomElement() ?? .yellow
            particles.append((position, color))
        }
    }
} 