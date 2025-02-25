import SwiftUI

struct ContentView: View {
    @State private var currentScene: SceneType = .opening

    var body: some View {
        ZStack {
            switch currentScene {
            case .opening:
                OpeningScene(currentScene: $currentScene)
            case .departure:
                DepartureScene(currentScene: $currentScene)
            case .travel:
                TravelScene(currentScene: $currentScene)
            case .park:
                ParkScene(currentScene: $currentScene)
            case .homeScene:
                HomeScene(currentScene: $currentScene)
            case .belonging:
                BelongingScene(currentScene: $currentScene)
            case .photoScene:
                PhotoScene(currentScene: $currentScene)
            case .finalSheetView:
                FinalSheetView(currentScene: $currentScene)
            }
            
            NavigationControls(currentScene: $currentScene)
        }
        .animation(.easeInOut(duration: 1), value: currentScene)
    }
}

enum SceneType {
    case opening
    case departure
    case travel
    case park
    case homeScene
    case belonging
    case photoScene
    case finalSheetView
}
