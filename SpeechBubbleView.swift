import SwiftUI

struct SpeechBubbleView: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.title2)
            .foregroundColor(.black)
            .padding()
            .background(Color.white)
            .clipShape(BubbleShape())
            .shadow(radius: 5)
    }
}

struct BubbleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let radius: CGFloat = 10
        let tailWidth: CGFloat = 20
        let tailHeight: CGFloat = 10

        path.addRoundedRect(in: CGRect(x: 0, y: 0, width: rect.width, height: rect.height - tailHeight), cornerSize: CGSize(width: radius, height: radius))

        path.move(to: CGPoint(x: rect.midX - tailWidth / 2, y: rect.height - tailHeight))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.height))
        path.addLine(to: CGPoint(x: rect.midX + tailWidth / 2, y: rect.height - tailHeight))

        return path
    }
}
