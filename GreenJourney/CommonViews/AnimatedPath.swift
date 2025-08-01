import SwiftUI
import Combine

struct AnimatedRectangle: View {
    var size: CGSize
    var padding: Double = 10.0
    var cornerRadius: CGFloat
    @State var t: CGFloat = 0.0
    @State private var timerSubscription: Cancellable? = nil
    
    var body: some View {
        Path { path in
            let width = size.width
            let height = size.height
            let radius = cornerRadius
            
            // define the initial points
            let initialPoints = [
                CGPoint(x: padding + radius, y: padding),
                CGPoint(x: width * 0.25 + padding, y: padding),
                CGPoint(x: width * 0.75 + padding, y: padding),
                CGPoint(x: width - padding - radius, y: padding),
                CGPoint(x: width - padding, y: padding + radius),
                CGPoint(x: width - padding, y: height * 0.25 - padding),
                CGPoint(x: width - padding, y: height * 0.75 - padding),
                CGPoint(x: width - padding, y: height - padding - radius),
                CGPoint(x: width - padding - radius, y: height - padding),
                CGPoint(x: width * 0.75 - padding, y: height - padding),
                CGPoint(x: width * 0.25 - padding, y: height - padding),
                CGPoint(x: padding + radius, y: height - padding),
                CGPoint(x: padding, y: height - padding - radius),
                CGPoint(x: padding, y: height * 0.75 - padding),
                CGPoint(x: padding, y: height * 0.25 - padding),
                CGPoint(x: padding, y: padding + radius)
            ]
            
            // define the arc centers
            let initialArcCenters = [
                CGPoint(x: padding + radius, y: padding + radius), // top-left
                CGPoint(x: width - padding - radius, y: padding + radius), // top-right
                CGPoint(x: width - padding - radius, y: height - padding - radius), // bottom-right
                CGPoint(x: padding + radius, y: height - padding - radius) // bottom-left
            ]
            
            // animate the points
            let points = initialPoints.map { point in
                CGPoint(
                    x: point.x + 10 * sin(t + point.y * 0.1),
                    y: point.y + 10 * sin(t + point.x * 0.1)
                )
            }
            
            // animate the arc centers
            let arcCenters = initialArcCenters.map { center in
                CGPoint(
                    x: center.x + 10 * sin(t + center.y * 0.3),
                    y: center.y + 10 * sin(t + center.x * 0.3)
                )
            }
            
            // draw the path
            path.move(to: CGPoint(x: padding, y: padding + radius))
            
            // top-left corner
            path.addArc(center: arcCenters[0], radius: radius, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
            
            // top edge
            for point in points[0...2] {
                path.addLine(to: point)
            }
            
            // top-right corner
            path.addArc(center: arcCenters[1], radius: radius, startAngle: .degrees(270), endAngle: .degrees(0), clockwise: false)
            
            // right edge
            for point in points[4...7] {
                path.addLine(to: point)
            }
            
            // bottom-right corner
            path.addArc(center: arcCenters[2], radius: radius, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)
            
            // bottom edge
            for point in points[8...10] {
                path.addLine(to: point)
            }
            
            // bottom-left corner
            path.addArc(center: arcCenters[3], radius: radius, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
            
            // left edge
            for point in points[11...14] {
                path.addLine(to: point)
            }
            
            path.closeSubpath()
        }
        .onAppear() {
            timerSubscription = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
                .sink {_ in
                    t += 0.1
                }
        }
        .onDisappear {
            timerSubscription?.cancel()
        }
    }
}
