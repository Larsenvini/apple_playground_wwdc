import SwiftUI
import AVFoundation
import CoreMotion

struct ParkScene: View {
    @Binding var currentScene: SceneType
    @State private var sceneStage: Int = 0 // 0 = Tablet, 1 = Park, 2 = Approaching Group
    @State private var attemptCount = 0
    @State private var showRejectionText = false
    @State private var showSpeechBubble = false
    @State private var showBlackScreen = false
    @State private var showVoicePrompt = false
    @State private var showKeepTryingButton = false
    @State private var voiceLevel: CGFloat = 10 // ✅ Tracks voice input level
    @StateObject private var speechRecognizer = SpeechManager()
    @StateObject private var motionManager = MotionManager()
    @StateObject private var soundManager = SoundManager()
    
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                if showBlackScreen {
                    Color.black.ignoresSafeArea()
                        .transition(.opacity)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                withAnimation {
                                    currentScene = .homeScene
                                }
                            }
                        }
                } else {
                    ZStack {
                        if sceneStage == 0 {
                            VStack {
                                Spacer()
                                NarrativeTextBox(text: "This park is close! I heard the university is doing an event there!")
                                    .padding(.bottom, proxy.size.height * 0.05)
                            }.background{Image("tablet_news")
                                    .resizable()
                                    .scaledToFill()
                                    .edgesIgnoringSafeArea(.all)
                                    .transition(.opacity)
                                    .onAppear {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
                                            withAnimation { sceneStage = 1 }
                                        }
                                    }
                            }
                        }
                        else if sceneStage == 1 {
                            Image("park_image")
                                .resizable()
                                .scaledToFill()
                                .edgesIgnoringSafeArea(.all)
                                .transition(.opacity)
                                .onAppear {
                                    soundManager.playHopefulTone()
                                    motionManager.startMotionUpdates { detected in
                                        if detected {
                                            motionManager.stopMotionUpdates()
                                        }
                                    }
                                }
                                .onChange(of: motionManager.tilted) { newValue in
                                    if newValue {
                                        withAnimation {
                                            sceneStage = 2
                                        }
                                        motionManager.stopMotionUpdates()
                                    }
                                }
                            
                            VStack {
                                Spacer()
                                NarrativeTextBox(text: "This is it!! Tilt the iPad right to enter!")
                                    .padding(.bottom, proxy.size.height * 0.1)
                            }
                        }
                        else {
                            ZStack {
                                Image("park_rejection")
                                    .resizable()
                                    .scaledToFill()
                                    .edgesIgnoringSafeArea(.all)
                                    .onAppear {
                                        speechRecognizer.startListeningWithLevel { recognizedText, level in
                                            voiceLevel = CGFloat(level) * 2 // ✅ Adjust bar fill dynamically

                                            if recognizedText.lowercased().contains("hey") {
                                                withAnimation {
                                                    attemptCount += 1
                                                    showSpeechBubble = true
                                                    showRejectionText = true
                                                }

                                                DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                                                    showRejectionText = false
                                                    showSpeechBubble = false
                                                }

                                                // ✅ SHOW "KEEP TRYING" BUTTON AFTER **ONE** FAILURE
                                                if attemptCount >= 1 && attemptCount < 3 {
                                                    showKeepTryingButton = true
                                                }

                                                // ✅ AFTER 3 ATTEMPTS, GO TO HOME SCENE (2s transition)
                                                if attemptCount == 3 {
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                                        withAnimation {
                                                            showBlackScreen = true
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }

                                VStack {
                                    Spacer()
                                    NarrativeTextBox(text:
                                        attemptCount < 3 ? "Maybe I should try talking to them..." :
                                        "No one even noticed me... Maybe I should just go home."
                                    )
                                    .padding(.bottom, proxy.size.height * 0.05)

                                    // ✅ "KEEP TRYING" BUTTON (APPEARS AFTER FIRST FAILURE)
                                    if showKeepTryingButton {
                                        Button(action: {
                                            withAnimation {
                                                // ✅ No reset to `attemptCount`, just try again
                                            }
                                        }) {
                                            Text("Keep Trying")
                                                .font(.title2)
                                                .padding()
                                                .background(Color.green)
                                                .foregroundColor(.white)
                                                .cornerRadius(10)
                                                .shadow(radius: 5)
                                        }
                                        .padding(.top, 10)
                                    }
                                }

                                if showSpeechBubble {
                                    SpeechBubbleView(text: "Hey!")
                                        .position(x: proxy.size.width * 0.1, y: proxy.size.height * 0.4)
                                        .transition(.scale)
                                }

                                if showRejectionText {
                                    Text("They didn't even notice...")
                                        .font(.largeTitle)
                                        .foregroundColor(.white)
                                        .padding(.all, 30)
                                        .background(Color.black.opacity(0.8))
                                        .cornerRadius(10)
                                        .transition(.opacity)
                                }
                            }

                            // ✅ Voice Instruction Pop-up (Always visible)
                            VStack {
                                Text("Say 'Hey!' to try joining the group")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.black.opacity(0.7))
                                    .cornerRadius(10)
                                    .shadow(radius: 5)

                                // ✅ Voice Input Level Bar
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 200, height: 20)

                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color.green)
                                        .frame(width: max(10, voiceLevel), height: 20)
                                        .animation(.easeInOut(duration: 0.2), value: voiceLevel)
                                }
                                .frame(width: 200)
                                .padding(.top, 10)
                            }
                            .position(x: proxy.size.width * 0.5, y: proxy.size.height * 0.2)
                            .transition(.opacity)

                        }
                        
                        if sceneStage == 2 {
                            if showSpeechBubble {
                                SpeechBubbleView(text: "Hey!")
                                    .position(x: proxy.size.width * 0.1, y: proxy.size.height * 0.4)
                                    .transition(.scale)
                            }
                            
                            if showRejectionText {
                                Text("They didn't even notice...")
                                    .font(.largeTitle)
                                    .foregroundColor(.white)
                                    .padding(.all, 30)
                                    .background(Color.black.opacity(0.8))
                                    .cornerRadius(10)
                                    .transition(.opacity)
                            }
                        }
                    }
                    
                    if showVoicePrompt {
                        VStack {
                            Text("Say 'Hey!' to try joining the group")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black.opacity(0.7))
                                .cornerRadius(10)
                                .shadow(radius: 5)
                            
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 200, height: 20)
                                
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.green)
                                    .frame(width: max(10, voiceLevel), height: 20)
                                    .animation(.easeInOut(duration: 0.2), value: voiceLevel)
                            }
                            .frame(width: 200)
                            .padding(.top, 10)
                        }
                        .position(x: proxy.size.width * 0.5, y: proxy.size.height * 0.2)
                        .transition(.opacity)
                    }
                }
            }
            .onChange(of: attemptCount) { newValue in
                if newValue >= 3 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation { showBlackScreen = true }
                    }
                }
            }
        }
    }
    
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
}

