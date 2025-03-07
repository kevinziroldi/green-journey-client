import SwiftUI

struct SemicircleCo2ChartView: View {
    let progress: Double
    let height: Double
    let width: Double
    let lineWidth: Double
    var body: some View {
        ZStack {
            SemiCircle()
                .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .foregroundColor(.gray.opacity(0.6))
                .frame(width: width, height: height)
            
            // semiCircle filled
            SemiCircle(progress: progress)
                .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .foregroundStyle(LinearGradient(gradient: Gradient(colors: [.red, .orange, .yellow, .green, .mint]), startPoint: .leading, endPoint: .trailing))
                .frame(width: width, height: height)
            
            VStack (spacing: 15){
                Image(systemName: "carbon.dioxide.cloud")
                    .font(.largeTitle)
                    .scaleEffect(1.5)
                Text(String(format: "%.0f", progress * 100) + "%")
                    .font(.headline)
                    .fontWeight(.bold)
            }
            .foregroundStyle(computeColor(progress))
        }
    }
    
    func computeColor(_ progress: Double) -> Color {
        if progress >= 0.9 {
            return Color.mint
        }
        else if progress >= 0.7 {
            return Color.green
        }
        else if progress >= 0.5 {
            return Color.yellow
        }
        else if progress >= 0.3 {
            return Color.orange
        }
        else {
            return Color.red
        }
    }
}

struct SemiCircle: Shape {
    var progress: Double = 1.0
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let startAngle = Angle(degrees: 135)
        let endAngle = Angle(degrees: 135 + 270 * progress)
        
        path.addArc(
            center: CGPoint(x: rect.midX, y: rect.midY),
            radius: rect.width / 2,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )
        return path
    }
}
