import SwiftUI

struct DepartureScene: View {
    @Binding var currentScene: SceneType
    @State private var showPackingScreen = false
    @StateObject private var soundManager = SoundManager()

    var body: some View {
        ZStack {
            if showPackingScreen {
                PackingScreen(currentScene: $currentScene)
            } else {
                Image("black_screen")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all) // ✅ Background Image
                
                VStack {
                    Text("You're playing as Larsen! \n A young adult who got accepted into a new University! \n It's his first time leaving the country,\n he is eager to make friends!")
                        .foregroundColor(.white)
                        .font(.largeTitle)
                        .bold()
                        .multilineTextAlignment(.center)
                    
                }
            }
        }
        .onAppear {
            soundManager.playHopefulTone()
            DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
                withAnimation {
                    showPackingScreen = true
                }
            }
        }
    }
}



// 📌 Bedroom Scene Before Packing
struct PackingScreen: View {
    @Binding var currentScene: SceneType
    @State private var showSuitcasePacking = false

    var body: some View {
        GeometryReader { proxy in
            
        
            ZStack {
                
                
                    ZStack {
                        VStack {
                            Spacer()
                            NarrativeTextBox(text: "Today is the day, can't believe I'm going to The Apple University! \n Better to finish packing my luggage.")// ✅ Pushes everything else downward
                        }
                        Button(action: {
                            showSuitcasePacking = true
                        }) {
                            Image("pack_luggage")
                                .resizable()
                                .scaledToFit()
                                .frame(width: proxy.size.width * 0.15)
                                
                        }
                        .position(x: proxy.size.width * 0.85, y: proxy.size.width * 0.44)
                    }
                    
                    HStack {
                        
                        
                        
                        
                    }
                
                
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            Image("bedroom")
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .scaledToFill()
        }
        .fullScreenCover(isPresented: $showSuitcasePacking) {
            PackingSuitcaseView(currentScene: $currentScene, soundManager: SoundManager())
        }
    }
}




struct PackingSuitcaseView: View {
    @Binding var currentScene: SceneType
    
    @State private var packedItems: [PackedItem] = []
    @State private var unpackedItems: [UnpackedItem] = [
        UnpackedItem(id: UUID(), image: "interact_item 2", packedImage: "fixed_item 2", size: CGSize(width: 300, height: 300), position: CGPoint(x: 0.3, y: 0.85)),  // Hoodie
        UnpackedItem(id: UUID(), image: "interact_item", packedImage: "fixed_item", size: CGSize(width: 80, height: 80), position: CGPoint(x: 0.5, y: 0.88)),   // Bracelet
        UnpackedItem(id: UUID(), image: "interact_item 1", packedImage: "fixed_item 1", size: CGSize(width: 230, height: 230), position: CGPoint(x: 0.7, y: 0.83)) // Picture
    ]
    
    var soundManager: SoundManager
    
    // MARK: - Computed Properties
    var itemsPackedCount: Int {
        return packedItems.count
    }
    
    var progress: CGFloat {
        return CGFloat(itemsPackedCount) / 3.0
    }
    
    var lockImage: String {
        return itemsPackedCount == 3 ? "lock_open" : "lock_closed"
    }
    
    var progressBarImage: String {
        switch itemsPackedCount {
        case 1: return "progress_bar1"
        case 2: return "progress_bar2"
        case 3: return "progress_bar3"
        default: return "progress_bar0"
        }
    }
    
    let suitcaseArea = CGRect(x: 0.2, y: 0.4, width: 0.6, height: 0.3)
    
    let fixedSizes: [String: CGSize] = [
        "fixed_item 2": CGSize(width: 260, height: 260),
        "fixed_item": CGSize(width: 75, height: 75),
        "fixed_item 1": CGSize(width: 170, height: 170)
    ]
    
    let fixedPositions: [String: CGPoint] = [
        "fixed_item 2": CGPoint(x: 0.33, y: 0.54),
        "fixed_item": CGPoint(x: 0.7, y: 0.58),
        "fixed_item 1": CGPoint(x: 0.6, y: 0.54)
    ]
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                VStack {
                    Image(lockImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                    
                    Image(progressBarImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 250)
                    
                    if itemsPackedCount == 3 {
                        Button(action: {
                            withAnimation {
                                currentScene = .travel
                            }
                        }) {
                            Image("travel_button")
                                .resizable()
                                .scaledToFit()
                                .frame(width: proxy.size.width * 0.15)
                        }
                        .transition(.opacity)
                    }
                }
                .position(x: proxy.size.width * 0.1, y: proxy.size.height * 0.4)
                
                // Packed Items
                ForEach(packedItems) { item in
                    Image(item.packedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(
                            width: fixedSizes[item.packedImage]?.width ?? 150,
                            height: fixedSizes[item.packedImage]?.height ?? 150
                        )
                        .position(
                            x: proxy.size.width * (fixedPositions[item.packedImage]?.x ?? 0.5),
                            y: proxy.size.height * (fixedPositions[item.packedImage]?.y ?? 0.5)
                        )
                }
                
                // Unpacked (Draggable) Items
                ForEach(unpackedItems) { item in
                    PackingItemView(
                        image: item.image,
                        packedImage: item.packedImage,
                        initialPosition: CGPoint(
                            x: proxy.size.width * item.position.x,
                            y: proxy.size.height * item.position.y
                        ),
                        suitcaseArea: CGRect(
                            x: proxy.size.width * suitcaseArea.origin.x,
                            y: proxy.size.height * suitcaseArea.origin.y,
                            width: proxy.size.width * suitcaseArea.width,
                            height: proxy.size.height * suitcaseArea.height
                        ),
                        size: item.size,
                        onPacked: { packedImage in
                            addPackedItem(image: packedImage)
                            withAnimation {
                                unpackedItems.removeAll { $0.packedImage == packedImage }
                            }
                        }
                    )
                }
            }.background(Image("suitcase")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all))
        }
    }
    
    private func addPackedItem(image: String) {
        let packedItem = PackedItem(
            id: UUID(),
            packedImage: image,
            size: fixedSizes[image] ?? CGSize(width: 150, height: 150),
            position: fixedPositions[image] ?? CGPoint(x: 0.5, y: 0.5)
        )
        withAnimation {
            packedItems.append(packedItem)
        }
    }
}

struct PackedItem: Identifiable {
    let id: UUID
    let packedImage: String
    let size: CGSize
    let position: CGPoint
}

struct UnpackedItem: Identifiable {
    let id: UUID
    let image: String
    let packedImage: String
    let size: CGSize
    let position: CGPoint
}

struct PackingItemView: View {
    let image: String
    let packedImage: String
    let initialPosition: CGPoint
    let suitcaseArea: CGRect
    let size: CGSize
    let onPacked: (String) -> Void
    
    @State private var itemPosition: CGPoint
    @State private var isDragging = false
    
    init(image: String, packedImage: String, initialPosition: CGPoint, suitcaseArea: CGRect, size: CGSize, onPacked: @escaping (String) -> Void) {
        self.image = image
        self.packedImage = packedImage
        self.initialPosition = initialPosition
        self.suitcaseArea = suitcaseArea
        self.size = size
        self.onPacked = onPacked
        self._itemPosition = State(initialValue: initialPosition)
    }
    
    var body: some View {
        Image(image)
            .resizable()
            .scaledToFit()
            .frame(width: size.width, height: size.height)
            .position(itemPosition)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        isDragging = true
                        itemPosition = value.location
                    }
                    .onEnded { value in
                        isDragging = false
                        let finalPosition = value.location
                        if suitcaseArea.contains(finalPosition) {
                            onPacked(packedImage)
                        } else {
                            withAnimation {
                                itemPosition = initialPosition
                            }
                        }
                    }
            )
            .onAppear {
                self.itemPosition = initialPosition
            }
    }
}
