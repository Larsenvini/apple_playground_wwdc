import SwiftUI

struct FinalSheetView: View {
    @Binding var currentScene: SceneType
    @State private var showCredits = false
    @StateObject private var soundManager = SoundManager()

    var body: some View {
        ZStack {
            if showCredits {
                Color.black.ignoresSafeArea()
                
                VStack {
                    Text("Special Thanks")
                        .foregroundColor(.white)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.bottom, 20)
                    
                    Text("""
                    This project was made possible with the support of:
                    
                    Apple Developer Academy | PUC-Rio
                    My Family & Friends
                    The WWDC Community
                    
                    Thank you for being part of this journey.
                    """)
                    .foregroundColor(.white)
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .padding()

                    // 🔹 Restart Button → Goes back to OpeningScene
                    Button(action: {
                        withAnimation {
                            soundManager.stopHopefulTone()
                            currentScene = .opening
                        }
                    }) {
                        Image("restart")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 250)
                    }
                    .padding(.top, 40)
                }
                .transition(.opacity)
            } else {
                VStack {
                    Text("The Power of Connection")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                    
                    Text("Belonging isn’t just about where you are but who you connect with.\n\nA simple message, an invitation, or a smile can change someone’s world. Be that connection.")
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Button(action: {
                        withAnimation {
                            showCredits = true
                        }
                    }) {
                        Image("end_button")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 250)
                    }
                    .padding(.top, 40)
                }
                .transition(.opacity)
            }
        }
    }
}
