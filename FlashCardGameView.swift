import SwiftUI
import AVFoundation
import Speech

struct FlashCardGameView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var card: FlashCard
    @State private var isFlipped = false
    @State private var offset = CGSize.zero
    @State private var score = 0
    @State private var showAR = false
    @State private var isListening = false
    @State private var showCelebration = false
    @State private var feedbackMessage = ""
    @State private var showFeedback = false
    @State private var feedbackColor = Color.green
    @StateObject private var speechRecognizer = SpeechRecognizer()
    let synthesizer = AVSpeechSynthesizer()
    @State private var isGameStarted = false
    @State private var isPlaying = false
    @GestureState private var dragState = DragState.inactive
    @State private var cardOffset: CGSize = .zero
    @State private var currentCard: FlashCard
    @State private var previousCard: FlashCard?
    @State private var nextCard: FlashCard?
    
    init(card: FlashCard) {
        _card = State(initialValue: card)
        _currentCard = State(initialValue: card)
        _nextCard = State(initialValue: FlashCard.randomCard)
    }
    
    func speakWord() {
        isPlaying = true
        
        // Configure speech synthesizer
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        
        let utterance = AVSpeechUtterance(string: currentCard.word)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.4
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        synthesizer.speak(utterance)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isPlaying = false
        }
    }
    
    func startListening() {
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
                
                // Show celebration and change card after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation {
                        showCelebration = false
                        changeCard(direction: .left)
                    }
                }
            } else if similarity >= 0.6 {
                feedbackMessage = "Close! Try again 💪"
                feedbackColor = .orange
            } else {
                feedbackMessage = "Keep practicing! 📚"
                feedbackColor = .red
            }
            
            showFeedback = true
            isListening = false
        }
    }
    
    func calculateSimilarity(between str1: String, and str2: String) -> Double {
        let length = Double(max(str1.count, str2.count))
        let distance = Double(str1.levenshteinDistance(to: str2))
        return 1 - (distance / length)
    }
    
    func changeCard(direction: SwipeDirection) {
        let impactMed = UIImpactFeedbackGenerator(style: .medium)
        impactMed.impactOccurred()
        
        withAnimation(.spring()) {
            switch direction {
            case .left:
                previousCard = currentCard
                currentCard = nextCard ?? FlashCard.randomCard
                nextCard = FlashCard.randomCard
                card = currentCard // Update the main card state
            case .right:
                previousCard = currentCard
                currentCard = nextCard ?? FlashCard.randomCard
                nextCard = FlashCard.randomCard
                card = currentCard // Update the main card state
            }
            cardOffset = .zero
        }
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                          startPoint: .topLeading,
                          endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Top bar with back button, score, and AR button
                HStack {
                    Button(action: {
                        isGameStarted = false
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .font(.title3.bold())
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Capsule().fill(Color.black.opacity(0.3)))
                    }
                    .padding(.leading)
                    
                    Spacer()
                    
                    // Score display
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("Score: \(score)")
                            .font(.title2.bold())
                    }
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(15)
                    
                    Spacer()
                    
                    // AR Mode button moved to top right
                    Button(action: { showAR = true }) {
                        HStack {
                            Image(systemName: "arkit")
                            Text("AR")
                        }
                        .font(.title3.bold())
                        .foregroundColor(.white)
                        .padding(10)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(colors: [.blue, .purple],
                                                 startPoint: .leading,
                                                 endPoint: .trailing)
                                )
                        )
                        .shadow(radius: 5)
                    }
                    .padding(.trailing)
                }
                .padding(.top)
                
                Spacer()
                
                // Card Stack
                ZStack {
                    // Next card (behind)
                    if let next = nextCard {
                        cardView(for: next)
                            .offset(x: cardOffset.width > 0 ? cardOffset.width + 300 : cardOffset.width - 300)
                            .scaleEffect(0.9)
                            .opacity(0.5)
                    }
                    
                    // Current card
                    cardView(for: currentCard)
                        .offset(x: cardOffset.width)
                        .rotationEffect(.degrees(Double(cardOffset.width / 20)))
                        .gesture(
                            DragGesture()
                                .updating($dragState) { drag, state, _ in
                                    state = .dragging(translation: drag.translation)
                                }
                                .onChanged { value in
                                    cardOffset = CGSize(width: value.translation.width, height: 0)
                                }
                                .onEnded { value in
                                    let threshold: CGFloat = 100
                                    if value.translation.width > threshold {
                                        changeCard(direction: .right)
                                    } else if value.translation.width < -threshold {
                                        changeCard(direction: .left)
                                    } else {
                                        withAnimation(.spring()) {
                                            cardOffset = .zero
                                        }
                                    }
                                }
                        )
                }
                
                Spacer()
                
                // Bottom controls
                VStack(spacing: 20) {
                    // Feedback message
                    if showFeedback {
                        Text(feedbackMessage)
                            .font(.title2.bold())
                            .foregroundColor(feedbackColor)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.white.opacity(0.9))
                                    .shadow(radius: 5)
                            )
                            .transition(.scale.combined(with: .opacity))
                    }
                    
                    // Speech recognition button centered
                    Button(action: startListening) {
                        HStack(spacing: 15) {
                            Image(systemName: isListening ? "waveform.circle.fill" : "mic.circle.fill")
                                .font(.system(size: 30))
                            Text(isListening ? "Listening..." : "Speak the Word!")
                                .font(.title3.bold())
                        }
                        .foregroundColor(isListening ? .green : .white)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 15)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: isListening ? [.green.opacity(0.3), .blue.opacity(0.3)] : [.blue, .purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                        .shadow(radius: 5)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.bottom, 30)
            }
            
            // Celebration overlay
            if showCelebration {
                CelebrationView()
                    .transition(.opacity)
            }
        }
        .onAppear {
            // Initialize audio session when view appears
            try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try? AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        }
        .fullScreenCover(isPresented: $showAR) {
            ARFlashcardGameView(card: card, onDismiss: { showAR = false })
        }
    }
    
    func cardView(for card: FlashCard) -> some View {
        ZStack {
            // Card background
            RoundedRectangle(cornerRadius: 25)
                .fill(
                    LinearGradient(
                        colors: [.white, .white.opacity(0.9)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.2), radius: 15, x: 0, y: 10)
                .frame(width: 320, height: 420)
            
            // Card content
            VStack(spacing: 25) {
                Text(card.word)
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
                    .shadow(color: .gray.opacity(0.3), radius: 2, x: 0, y: 2)
                
                if let image = UIImage(named: card.imageName) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 220)
                        .cornerRadius(15)
                        .shadow(radius: 8)
                        .padding(.horizontal, 20)
                }
                
                Text("Tap card to hear pronunciation")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.top, 10)
            }
            .frame(width: 320, height: 420)
        }
        .scaleEffect(isPlaying ? 1.02 : 1.0)
        .animation(.spring(response: 0.3), value: isPlaying)
        .onTapGesture {
            speakWord()
        }
    }
}

// Helper extension for calculating word similarity
extension String {
    func levenshteinDistance(to string: String) -> Int {
        let str1 = Array(self)
        let str2 = Array(string)
        var matrix = Array(repeating: Array(repeating: 0, count: str2.count + 1), count: str1.count + 1)
        
        for i in 0...str1.count {
            matrix[i][0] = i
        }
        for j in 0...str2.count {
            matrix[0][j] = j
        }
        
        for i in 1...str1.count {
            for j in 1...str2.count {
                if str1[i - 1] == str2[j - 1] {
                    matrix[i][j] = matrix[i - 1][j - 1]
                } else {
                    matrix[i][j] = Swift.min(
                        matrix[i - 1][j] + 1,     // deletion
                        matrix[i][j - 1] + 1,     // insertion
                        matrix[i - 1][j - 1] + 1  // substitution
                    )
                }
            }
        }
        
        return matrix[str1.count][str2.count]
    }
}

// Helper enums
enum SwipeDirection {
    case left, right
}

enum DragState {
    case inactive
    case dragging(translation: CGSize)
    
    var translation: CGSize {
        switch self {
        case .inactive:
            return .zero
        case .dragging(let translation):
            return translation
        }
    }
} 
