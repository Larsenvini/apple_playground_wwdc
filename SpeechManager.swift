import Speech
import AVFoundation

class SpeechManager: ObservableObject {
    private let speechRecognizer = SFSpeechRecognizer()
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?

    init() {
        requestPermission()
    }

    func startListeningWithLevel(completion: @escaping (String, Float) -> Void) {
        #if targetEnvironment(macCatalyst)
        print("⚠️ Speech Recognition disabled on macOS.")
        return
        #endif

        guard let recognizer = speechRecognizer, recognizer.isAvailable else {
            print("❌ Speech recognition is not available.")
            return
        }

        stopListening()

        do {
            let inputNode = audioEngine.inputNode
            let recordingFormat = AVAudioFormat(standardFormatWithSampleRate: 44100.0, channels: 1) // ✅ Valid format

            // ✅ Ensure recording format is valid
            guard let format = recordingFormat else {
                print("❌ Invalid audio format!")
                return
            }

            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            recognitionRequest?.shouldReportPartialResults = true

            inputNode.removeTap(onBus: 0) // Remove existing tap (if any)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { (buffer, _) in
                self.recognitionRequest?.append(buffer)
                let level = self.audioLevel(from: buffer)
                completion("", level) // ✅ Send empty text with level
            }

            restartAudioEngine()

            recognitionTask = recognizer.recognitionTask(with: recognitionRequest!) { result, error in
                if let result = result {
                    completion(result.bestTranscription.formattedString, 0.0)
                }
                if error != nil {
                    self.stopListening()
                }
            }
        } catch {
            print("❌ Speech recognition failed: \(error.localizedDescription)")
            stopListening()
        }
    }

    func stopListening() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
    }

    private func restartAudioEngine() {
        audioEngine.stop()
        audioEngine.reset()
        do {
            try audioEngine.start()
        } catch {
            print("❌ Error restarting audio engine: \(error.localizedDescription)")
        }
    }

    func requestPermission() {
        SFSpeechRecognizer.requestAuthorization { status in
            if status != .authorized {
                print("❌ Speech recognition permission denied.")
            }
        }
    }

    private func audioLevel(from buffer: AVAudioPCMBuffer) -> Float {
        let channelData = buffer.floatChannelData?[0]
        let channelDataValue = channelData?[0] ?? 0.0
        return abs(channelDataValue * 100)
    }
}


