import SwiftUI
import AVFoundation

struct HomeScene: View {
    @Binding var currentScene: SceneType
    @State private var showGoHomeButton = false
    @State private var showLayDownButton = false
    @State private var showCheckPhoneButton = false
    @State private var sceneStage = 0
    @State private var player: AVAudioPlayer?
    @StateObject private var soundManager = SoundManager()

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                if sceneStage == 0 {
                    
                    Image("park_angry")
                        .resizable()
                        .scaledToFill()
                        .edgesIgnoringSafeArea(.all)
                        .transition(.opacity)
                        .onAppear {
                            playRejectionSound()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                withAnimation {
                                    showGoHomeButton = true
                                }
                            }
                        }
                    
                    // ✅ Narrative Text for park_angry stage
                    VStack {
                        Spacer()
                        NarrativeTextBox(text: "Arghh! Why can't I fit in? Aw man >.<")
                            .padding(.bottom, proxy.size.height * 0.13)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    
                } else if sceneStage == 1 {
                    Image("new_room_dark")
                        .resizable()
                        .scaledToFill()
                        .edgesIgnoringSafeArea(.all)
                        .transition(.opacity)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                withAnimation {
                                    showLayDownButton = true
                                }
                            }
                        }
                    
                    // ✅ Narrative Text for new_room_dark stage
                    VStack {
                        Spacer()
                        NarrativeTextBox(text: "I just need to lie down for a while...")
                            .padding(.bottom, proxy.size.height * 0.13)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    
                } else {
                    Image("phone_screen")
                        .resizable()
                        .scaledToFill()
                        .edgesIgnoringSafeArea(.all)
                        .transition(.opacity)
                        .onAppear {
                            soundManager.stopRejectionSound()
                            playPhoneMessageSound() // ✅ Play phone message sound
                        }
                    
                    // ✅ Narrative Text for phone_screen stage
                    VStack {
                        Spacer()
                        NarrativeTextBox(text: "Huh? Who could it be..")
                            .padding(.bottom, proxy.size.height * 0.11)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                }
                
                // 🔹 Go Home Button (Appears after 3s in park_angry)
                if showGoHomeButton && sceneStage == 0 {
                    Button(action: {
                        withAnimation {
                            sceneStage = 1
                            showGoHomeButton = false
                        }
                    }) {
                        Image("go_home_button")
                            .resizable()
                            .scaledToFit()
                            .frame(width: proxy.size.width * 0.3)
                    }
                    .position(x: proxy.size.width / 2, y: proxy.size.height * 0.8)
                }
                
                // 🔹 Lay Down Button (Appears after 3s in new_room_dark)
                if showLayDownButton && sceneStage == 1 {
                    Button(action: {
                        withAnimation {
                            sceneStage = 2
                        }
                    }) {
                        Image("lay_down_button")
                            .resizable()
                            .scaledToFit()
                            .frame(width: proxy.size.width * 0.25)
                    }
                    .position(x: proxy.size.width / 2, y: proxy.size.height * 0.8)
                }
                
                if showCheckPhoneButton && sceneStage == 2 {
                    Button(action: {
                        withAnimation {
                            soundManager.playHopefulTone()
                            currentScene = .belonging
                        }
                    }) {
                        Image("check_phone")
                            .resizable()
                            .scaledToFit()
                            .frame(width: proxy.size.width * 0.3)
                    }
                    .position(x: proxy.size.width / 2, y: proxy.size.height * 0.8)
                }
            }
        }
    }
    
    private func playRejectionSound() {
        soundManager.playRejectionSound()
    }
    private func playPhoneMessageSound() {
        if let url = Bundle.main.url(forResource: "phone_message", withExtension: "mp3") {
            do {
                player = try AVAudioPlayer(contentsOf: url)
                player?.play()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + (player?.duration ?? 2.0)) {
                    withAnimation {
                        showCheckPhoneButton = true
                    }
                }
            } catch {
                print("Error playing phone message sound: \(error.localizedDescription)")
            }
        }
    }
}

