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
    @State private var currentCard: FlashCard
    @State private var nextCard: FlashCard?
    @Environment(\.dismiss) private var dismiss
    @State private var feedbackMessage = ""
    @State private var showFeedback = false
    @State private var feedbackColor = Color.green
    let synthesizer = AVSpeechSynthesizer()
    
    init(card: FlashCard) {
        _card = State(initialValue: card)
        _currentCard = State(initialValue: card)
        _nextCard = State(initialValue: FlashCard.randomCard)
    }
    
    func speakWord() {
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        
        let utterance = AVSpeechUtterance(string: currentCard.word)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.4
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        synthesizer.speak(utterance)
    }
    
    func startListening() {
        // Only start if not already listening
        guard !isListening else { return }
        
        isListening = true
        feedbackMessage = ""
        showFeedback = false
        
        speechRecognizer.startRecording { spokenText in
            let similarity = calculateSimilarity(between: spokenText.lowercased(), and: currentCard.word.lowercased())
            
            if similarity >= 0.8 {
                score += 1
                showCelebration = true
                feedbackMessage = "Perfect! 🌟"
                feedbackColor = .green
                
                // Ensure proper animation timing
                withAnimation(.easeInOut(duration: 0.5)) {
                    showFeedback = true
                }
                
                // Add delay before card transition
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    showCelebration = false
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        changeCard()
                    }
                }
            } else if similarity >= 0.6 {
                feedbackMessage = "Close! Try again 💪"
                feedbackColor = .orange
                withAnimation {
                    showFeedback = true
                }
            } else {
                feedbackMessage = "Keep practicing! 📚"
                feedbackColor = .red
                withAnimation {
                    showFeedback = true
                }
            }
            
            isListening = false
        }
    }
    
    func calculateSimilarity(between str1: String, and str2: String) -> Double {
        let length = Double(max(str1.count, str2.count))
        let distance = Double(str1.levenshteinDistance(to: str2))
        return 1 - (distance / length)
    }
    
    func changeCard() {
        withAnimation(.spring()) {
            currentCard = nextCard ?? FlashCard.randomCard
            nextCard = FlashCard.randomCard
            card = currentCard
        }
    }
    
    var body: some View {
        ZStack {
            ARViewContainer(card: currentCard, onTapText: speakWord)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                    }
                    
                    Spacer()
                    
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("Score: \(score)")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(15)
                    .padding(.trailing)
                }
                .padding(.top, 20)
                
                Spacer()
                
                VStack(spacing: 16) {
                    if showFeedback {
                        Text(feedbackMessage)
                            .font(.title3.bold())
                            .foregroundColor(feedbackColor)
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(15)
                            .transition(.scale.combined(with: .opacity))
                    }
                    
                    HStack(spacing: 20) {
                        Button(action: { changeCard() }) {
                            Image(systemName: "arrow.forward.circle.fill")
                                .font(.system(size: 44))
                                .foregroundColor(.white)
                                .background(Circle().fill(Color.black.opacity(0.3)))
                        }
                        
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
                    }
                }
                .padding(.bottom, 30)
            }
            
            if showCelebration {
                CelebrationView()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .onAppear {
            try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try? AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        }
        .onDisappear {
            speechRecognizer.stopRecording()
        }
    }
}

// Preview provider
struct ARFlashcardGameView_Previews: PreviewProvider {
    static var previews: some View {
        ARFlashcardGameView(card: FlashCard.randomCard)
    }
}
