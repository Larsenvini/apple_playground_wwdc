import SwiftUI
import AVFoundation
import Combine

struct OpeningScene: View {
    @Binding var currentScene: SceneType
    @State private var airplanePosition = CGSize(width: -UIScreen.main.bounds.width / 2, height: -UIScreen.main.bounds.height / 2)
    @State private var airplaneRotation: Double = 40
    @State private var showButton = false
    @State private var hideButton = false
    @State private var logoPrompt = true
    @State private var landscapePrompt = false
    @StateObject private var soundManager = SoundManager()
    @StateObject private var speechRecognizer = SpeechManager()
    
    var body: some View {
        ZStack {
            if logoPrompt {
                ZStack {
                    Color.black.ignoresSafeArea()
                    Image("journey_lars")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 600, height: 600)
                }
                .transition(.opacity)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        withAnimation {
                            logoPrompt = false
                            landscapePrompt = true
                        }
                    }
                }
            } else if landscapePrompt {
                ZStack {
                    Color.black.ignoresSafeArea()
                    VStack {
                        Spacer()
                        Image("device_landscape")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 500, height: 500)
                        
                        Text("Make sure your device is LOCKED in landscape mode please!")
                            .foregroundColor(.white)
                            .font(.title2)
                            .multilineTextAlignment(.center)
                            .padding()
                        Spacer()
                    }
                }
                .transition(.opacity)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                        withAnimation {
                            landscapePrompt = false
                        }
                    }
                }
            } else {
                ZStack {
                    // ✅ Black background instead of video
                    Color.gray.ignoresSafeArea()
                    
                    VStack {
                        Spacer()
                        ZStack {
                            Image("airplane")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 250, height: 250)
                                .rotationEffect(.degrees(airplaneRotation))
                                .offset(x: airplanePosition.width, y: airplanePosition.height)
                                .animation(.easeInOut(duration: 6.5), value: airplanePosition)
                                .animation(.easeInOut(duration: 6.5), value: airplaneRotation)
                            
                            if showButton && !hideButton {
                                Button(action: {
                                    hideButton = true
                                    startSecondAnimation()
                                    
                                    speechRecognizer.requestPermission()
                                }) {
                                    Image("start_button")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 400, height: 400)
                                }
                                .offset(y: 150)
                                .transition(.opacity)
                            }
                        }
                        Spacer()
                    }
                }
                .onAppear {
                    startFirstAnimation()
                }
            }
        }
    }
    
    private func startFirstAnimation() {
        withAnimation(.easeInOut(duration: 3.0)) {
            airplanePosition = CGSize(width: 0, height: 0)
            airplaneRotation = 0
        }
        soundManager.playFlyover()
        soundManager.playHopefulTone()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 6.5) {
            soundManager.stopFlyover()
            withAnimation {
                showButton = true
            }
        }
    }
    
    private func startSecondAnimation() {
        soundManager.playFlyover(from: 3.5)
        
        withAnimation(.easeInOut(duration: 4.0)) {
            airplanePosition = CGSize(width: UIScreen.main.bounds.width, height: -UIScreen.main.bounds.height)
            airplaneRotation = -30
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            withAnimation {
                currentScene = .departure
            }
            soundManager.stopFlyover()
        }
    }
}

class SoundManager: ObservableObject {
    private var flyoverPlayer: AVAudioPlayer?
    private var hopefulPlayer: AVAudioPlayer?
    private var rejectionPlayer: AVAudioPlayer?

    init() {
        if let hopefulURL = Bundle.main.url(forResource: "hopeful_tone", withExtension: "mp3") {
            do {
                hopefulPlayer = try AVAudioPlayer(contentsOf: hopefulURL)
                hopefulPlayer?.numberOfLoops = -1 // Loop indefinitely
                hopefulPlayer?.volume = 0.2
            } catch {
                print("Error loading hopeful tune: \(error.localizedDescription)")
            }
        }

        if let flyoverURL = Bundle.main.url(forResource: "airplane_flyover", withExtension: "mp3") {
            do {
                flyoverPlayer = try AVAudioPlayer(contentsOf: flyoverURL)
            } catch {
                print("Error loading airplane flyover: \(error.localizedDescription)")
            }
        }

        if let rejectionURL = Bundle.main.url(forResource: "rejection_sound", withExtension: "mp3") {
            do {
                rejectionPlayer = try AVAudioPlayer(contentsOf: rejectionURL)
                rejectionPlayer?.volume = 0.15
            } catch {
                print("Error loading rejection sound: \(error.localizedDescription)")
            }
        }
    }
    
    func playHopefulTone() {
        hopefulPlayer?.numberOfLoops = -1
        hopefulPlayer?.play()
    }

    func stopHopefulTone() {
        hopefulPlayer?.stop()
    }

    func playRejectionSound() {
        stopHopefulTone()
        rejectionPlayer?.play()
    }
    
    func stopRejectionSound() {
        rejectionPlayer?.stop()
    }

    func playFlyover(from time: TimeInterval = 0) {
        if let player = flyoverPlayer {
            player.currentTime = time
            player.play()
        }
    }

    func stopFlyover() {
        flyoverPlayer?.stop()
        flyoverPlayer?.currentTime = 0
    }
}

