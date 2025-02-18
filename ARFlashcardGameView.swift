import SwiftUI
import ARKit
import RealityKit
import Speech

struct ARFlashcardGameView: View {
    @State private var card: FlashCard
    @State private var showCelebration = false
    @State private var score = 0
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @State private var isListening = false
    let synthesizer = AVSpeechSynthesizer()
    
    init(card: FlashCard) {
        _card = State(initialValue: card)
    }
    
    func speakWord() {
        let utterance = AVSpeechUtterance(string: card.word)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
        utterance.pitchMultiplier = 1.2
        synthesizer.speak(utterance)
    }
    
    func startListening() {
        isListening = true
        speechRecognizer.startRecording { spokenText in
            if spokenText.lowercased() == card.word.lowercased() {
                score += 1
                showCelebration = true
                // Show celebration and change card after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation {
                        showCelebration = false
                        // Get a new random card
                        card = FlashCard.randomCard
                    }
                }
            }
            isListening = false
        }
    }
    
    var body: some View {
        ZStack {
            // AR View
            ARViewContainer(card: card, onTapText: speakWord)
                .edgesIgnoringSafeArea(.all)
            
            // Overlay UI
            VStack {
                // Top score bar
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.system(size: 24))
                    Text("Score: \(score)")
                        .font(.custom("Arial Rounded MT Bold", size: 24))
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.blue.opacity(0.7))
                                .shadow(radius: 5)
                        )
                }
                .padding(.top, 20)
                
                Spacer()
                
                // Bottom controls - only speech recognition button
                Button(action: startListening) {
                    HStack {
                        Image(systemName: isListening ? "waveform" : "mic.fill")
                            .foregroundColor(isListening ? .green : .red)
                            .font(.system(size: 24))
                        Text(isListening ? "Listening..." : "Speak the Word!")
                            .fontWeight(.bold)
                            .font(.title3)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.9))
                            .shadow(radius: 5)
                    )
                }
                .padding(.bottom, 30)
            }
            
            // Celebration overlay
            if showCelebration {
                CelebrationView()
                    .transition(.opacity)
                    .zIndex(1) // Ensure celebration appears on top
            }
        }
    }
}

// Preview provider
struct ARFlashcardGameView_Previews: PreviewProvider {
    static var previews: some View {
        ARFlashcardGameView(card: FlashCard.randomCard)
    }
} 
