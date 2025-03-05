import SwiftUI

struct CircularProgressView: View {
    @State private var rotation: Double = 0

    var body: some View {
        ZStack {
            // background circle
            Circle()
                .stroke(lineWidth: 8)
                .opacity(0.3)
                .foregroundColor(Color.gray)
            
            // rotating part
            Circle()
                .trim(from: 0, to: 0.3)
                .stroke(style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .foregroundStyle(LinearGradient(colors: [Color.blue, Color.green], startPoint: .leading, endPoint: .trailing))
                .rotationEffect(.degrees(rotation))
                .onAppear {
                    withAnimation(Animation.linear(duration: 3).repeatForever(autoreverses: false)) {
                        rotation = 360
                    }
                }
            Image("icon_no_background")
                .resizable()
                .frame(width: 60, height: 60)
        }
        .frame(width: 90, height: 90)
    }
}
