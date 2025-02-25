import SwiftUI

struct NarrativeTextBox: View {
    let text: String
    
    var body: some View {
        VStack {
            Text(text)
                .font(.title)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.black.opacity(0.8))
                .cornerRadius(15)
                .padding()
        }
        .frame(maxWidth: .infinity)
        .transition(.opacity) 
    }
}
