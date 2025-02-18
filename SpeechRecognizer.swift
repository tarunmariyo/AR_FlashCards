import Foundation
import Speech

class SpeechRecognizer: ObservableObject {
    private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    func startRecording(completion: @escaping (String) -> Void) {
        // Request authorization
        SFSpeechRecognizer.requestAuthorization { status in
            guard status == .authorized else { return }
            
            // Set up audio session
            try? AVAudioSession.sharedInstance().setCategory(.record, mode: .measurement, options: .duckOthers)
            try? AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
            
            // Start recording and recognition
            self.recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            guard let recognitionRequest = self.recognitionRequest else { return }
            
            self.recognitionTask = self.speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
                if let result = result {
                    completion(result.bestTranscription.formattedString)
                }
            }
            
            let inputNode = self.audioEngine.inputNode
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                self.recognitionRequest?.append(buffer)
            }
            
            self.audioEngine.prepare()
            try? self.audioEngine.start()
        }
    }
    
    func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
    }
} 