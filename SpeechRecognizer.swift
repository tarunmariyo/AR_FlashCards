import Foundation
import Speech

class SpeechRecognizer: ObservableObject {
    private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    @Published private(set) var isRecording = false
    private let queue = DispatchQueue(label: "com.speechrecognizer.queue")
    
    private var completionHandler: ((String) -> Void)?
    
    func startRecording(completion: @escaping (String) -> Void) {
        // Store completion handler
        completionHandler = completion
        
        // Stop any existing recording session
        stopRecording()
        
        // Request authorization
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            guard let self = self, status == .authorized else { return }
            
            self.queue.async { [weak self] in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.isRecording = true
                }
            }
            
            // Set up audio session
            do {
                let audioSession = AVAudioSession.sharedInstance()
                try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
                try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            } catch {
                print("Failed to set up audio session: \(error)")
                return
            }
            
            // Start recording and recognition
            self.recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            guard let recognitionRequest = self.recognitionRequest else { return }
            
            self.recognitionTask = self.speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
                guard let self = self else { return }
                
                if let result = result {
                    self.completionHandler?(result.bestTranscription.formattedString)
                }
                
                if error != nil || result?.isFinal == true {
                    self.stopRecording()
                }
            }
            
            let inputNode = self.audioEngine.inputNode
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
                self?.recognitionRequest?.append(buffer)
            }
            
            do {
                self.audioEngine.prepare()
                try self.audioEngine.start()
            } catch {
                print("Failed to start audio engine: \(error)")
                self.stopRecording()
            }
        }
    }
    
    func stopRecording() {
        // Stop audio engine and remove tap
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        
        // End recognition request and task
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        
        // Cleanup
        recognitionRequest = nil
        recognitionTask = nil
        
        // Update recording state
        queue.async {
            DispatchQueue.main.async {
                self.isRecording = false
            }
        }
        
        // Reset audio session
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
    
    deinit {
        stopRecording()
    }
}