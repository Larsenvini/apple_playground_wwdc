import SwiftUI

struct TravelScene: View {
    @Binding var currentScene: SceneType
    @State private var showAirplaneWindow = false
    @State private var showNarrativeText = false
    @State private var showReadNewsButton = false
    @State private var show24HoursImage = true
    @StateObject private var soundManager = SoundManager()

    var body: some View {
        ZStack {
            if show24HoursImage {
                Image("24_hours")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                    .onAppear {
                        soundManager.playHopefulTone()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) { // Show for 3 seconds
                            withAnimation {
                                show24HoursImage = false
                                showAirplaneWindow = true
                            }
                        }
                    }
            } else {
                Image("airplane_window_landed")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                
                if showNarrativeText {
                    VStack {
                        Spacer()
                        NarrativeTextBox(text: "Finally, I've arrived!! Let me check the city's news.")
                            .padding(.bottom, 50)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    .transition(.opacity)
                }
                
                if showReadNewsButton {
                    Button(action: {
                        withAnimation {
                            currentScene = .park
                        }
                    }) {
                        Image("read_news")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 250)
                    }
                    .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height * 0.8)
                    .transition(.opacity)
                }
            }
        }
        .onAppear {
            startSceneTransition()
        }
    }
    
    private func startSceneTransition() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) { // Show airplane window after "24 Hours"
            withAnimation {
                showAirplaneWindow = true
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            withAnimation {
                showNarrativeText = true
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 8.0) { // Show Read News Button
            withAnimation {
                showReadNewsButton = true
            }
        }
    }
}

