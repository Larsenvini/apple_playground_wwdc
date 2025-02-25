import SwiftUI

struct PhotoScene: View {
    @Binding var currentScene: SceneType
    @State private var sceneStage: Int = 0 // 0 = Black Screen, 1 = Room, 2 = Zoom Board
    @State private var boardZoomed = false

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                // 🔹 Scene 0: Black Screen with Message
                if sceneStage == 0 {
                    Color.black.ignoresSafeArea()

                    Text("And just like that, memories are made")
                        .foregroundColor(.white)
                        .font(.largeTitle)
                        .multilineTextAlignment(.center)
                        .padding()
                        .transition(.opacity)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                                withAnimation {
                                    sceneStage = 1
                                }
                            }
                        }
                }
                else if sceneStage == 1 {
                    Image("new_room_light")
                        .resizable()
                        .scaledToFill()
                        .edgesIgnoringSafeArea(.all)
                        .transition(.opacity)

                    Button(action: {
                        withAnimation(.easeInOut(duration: 1.5)) {
                            boardZoomed = true
                            sceneStage = 2
                        }
                    }) {
                        Image("closer_button")
                            .resizable()
                            .scaledToFit()
                            .frame(width: proxy.size.width * 0.2)
                    }
                    .position(x: proxy.size.width * 0.75, y: proxy.size.height * 0.5) // **🔹 Adjusted near the board**
                }
                else if sceneStage == 2 {
                    Image("picture")
                        .resizable()
                        .scaledToFill()
                        .edgesIgnoringSafeArea(.all)
                        .transition(.opacity)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                                withAnimation {
                                    currentScene = .finalSheetView
                                }
                            }
                        }
                }
            }
        }
    }
}

#Preview {
    PhotoScene(currentScene: .constant(.photoScene))
}
