import SwiftUI

struct NavigationControls: View {
    @Binding var currentScene: SceneType
    
    var body: some View {
        HStack {
            // 🔹 Back Button
            Button(action: {
                previousScene()
            }) {
                Image(systemName: "arrow.left.circle.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.white)
                    .shadow(radius: 5)
            }
            .padding(.leading, 10)
            .disabled(!canGoBack())
            
            Spacer()
            
        }
        .padding(.top, 50)
    }
    
    private func canGoBack() -> Bool {
        return currentScene != .opening
    }
    
    private func previousScene() {
        switch currentScene {
        case .departure: currentScene = .opening
        case .travel: currentScene = .departure
        case .park: currentScene = .travel
        case .homeScene: currentScene = .park
        case .belonging: currentScene = .homeScene
        case .photoScene: currentScene = .belonging
        case .finalSheetView: currentScene = .photoScene
        default: break
        }
    }
}
