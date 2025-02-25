import SwiftUI
import AVFoundation
import CoreMotion

struct BelongingScene: View {
    @Binding var currentScene: SceneType
    @State private var sceneStage: Int = 0 // 0 = Black Screen, 1 = Friendly Message, 2 = Park, 3 = Park Acceptance
    @State private var attemptCount = 0
    @State private var showSpeechBubble = false
    @State private var showResponseBubble = false
    @State private var showHangOutButton = false
    @StateObject private var speechRecognizer = SpeechManager()
    @StateObject private var motionManager = MotionManager()
    @StateObject private var soundManager = SoundManager()

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                // 🔹 Scene 0: Black Screen with Message
                if sceneStage == 0 {
                    Image("friendly_message") // ✅ First, show the friendly message
                        .resizable()
                        .scaledToFill()
                        .edgesIgnoringSafeArea(.all)
                        .transition(.opacity)
                        .onAppear {
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                                withAnimation {
                                    soundManager.playHopefulTone()
                                    sceneStage = 1
                                }
                            }
                        }
                }
                else if sceneStage == 1 {
                    Color.black.ignoresSafeArea()
                    
                    Text("Sometimes, belonging starts with an act from someone who cares")
                        .foregroundColor(.white)
                        .font(.largeTitle)
                        .multilineTextAlignment(.center)
                        .padding()
                        .transition(.opacity)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                                withAnimation {
                                    sceneStage = 2
                                }
                            }
                        }
                }
                // 🔹 Scene 2: Park Image + Motion Tilt
                else if sceneStage == 2 {
                    Image("park_image")
                        .resizable()
                        .scaledToFill()
                        .edgesIgnoringSafeArea(.all)
                        .transition(.opacity)
                        .onAppear {
                            motionManager.startMotionUpdates { detected in
                                if detected {
                                    motionManager.stopMotionUpdates()
                                }
                            }
                        }
                        .onChange(of: motionManager.tilted) { newValue in
                            if newValue {
                                withAnimation {
                                    sceneStage = 3
                                }
                                motionManager.stopMotionUpdates()
                            }
                        }
                    
                    VStack {
                        Spacer()
                        NarrativeTextBox(text: "Tilt the iPad right to go to the Park!")
                            .padding(.bottom, proxy.size.height * 0.12)
                    }
                }
                // 🔹 Scene 3: Park Acceptance (People Responding!)
                else {
                    Image("park_belonging") // ✅ The group responds this time 🎉
                        .resizable()
                        .scaledToFill()
                        .edgesIgnoringSafeArea(.all)
                        .onAppear {
                            speechRecognizer.startListeningWithLevel { recognizedText, _ in
                                if recognizedText.lowercased().contains("hey") {
                                    withAnimation {
                                        attemptCount += 1
                                        showSpeechBubble = true
                                        showResponseBubble = true
                                    }
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                        showSpeechBubble = false
                                        showResponseBubble = false
                                        showHangOutButton = true // ✅ Show "Hang Out" button
                                    }
                                }
                            }
                        }
                    
                    VStack {
                        Spacer()
                        NarrativeTextBox(text: "Let's do this!")
                            .padding(.bottom, proxy.size.height * 0.05)
                    }
                    
                    // ✅ Speech Bubbles (Player & Group Response)
                    if showSpeechBubble {
                        SpeechBubbleView(text: "Hey!")
                            .position(x: proxy.size.width * 0.4, y: proxy.size.height * 0.4)
                            .transition(.scale)
                    }
                    
                    if showResponseBubble {
                        SpeechBubbleView(text: "Hey, nice to meet you!")
                            .position(x: proxy.size.width * 0.6, y: proxy.size.height * 0.4)
                            .transition(.scale)
                    }
                    
                    // ✅ Hang Out Button (Appears after greeting)
                    if showHangOutButton {
                        Button(action: {
                            withAnimation {
                                currentScene = .photoScene
                            }
                        }) {
                            Image("hang_out_button")
                                .resizable()
                                .scaledToFit()
                                .frame(width: proxy.size.width * 0.3)
                        }
                        .position(x: proxy.size.width / 2, y: proxy.size.height * 0.8)
                    }
                }
            }
        }
    }
}
//detec only once
class MotionManager: ObservableObject {
    private var motionManager = CMMotionManager()
    @Published var tilted = false
    func startMotionUpdates(onTilt: @escaping (Bool) -> Void) {
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 1 / 60
            motionManager.startDeviceMotionUpdates(to: .main) { (motionData, error) in
                guard let motionData = motionData, error == nil else { return }
                
                let tiltX = motionData.rotationRate.z
                print(tiltX)
                
                if abs(tiltX) > 2 {
                    self.tilted = true
                }
            }
        }
    }
    
    func stopMotionUpdates() {
        motionManager.stopDeviceMotionUpdates()
    }
}

