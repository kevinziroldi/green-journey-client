
import SwiftUI
import Combine

struct MeshGradientView: View {
    @State var maskTimer: Float = 0.0
    var gradientSpeed: Float = 0.3
    
    @State private var timerSubscription: Cancellable? = nil
    
    var body: some View {
        MeshGradient(width: 3, height: 3, points: [
            .init(0, 0), .init(0.0, 0), .init(1, 0),
            
            [sinInRange(-0.8...(-0.2), offset: 0.439, timeScale: 0.342, t: maskTimer), sinInRange(0.3...0.7, offset: 3.42, timeScale: 0.984, t: maskTimer)],
            [sinInRange(0.1...0.8, offset: 0.239, timeScale: 0.084, t: maskTimer), sinInRange(0.2...0.8, offset: 5.21, timeScale: 0.242, t: maskTimer)],
            [sinInRange(1.0...1.5, offset: 0.939, timeScale: 0.084, t: maskTimer), sinInRange(0.4...0.8, offset: 0.25, timeScale: 0.642, t: maskTimer)],
            [sinInRange(-0.8...0.0, offset: 1.439, timeScale: 0.442, t: maskTimer), sinInRange(1.4...1.9, offset: 3.42, timeScale: 0.984, t: maskTimer)],
            [sinInRange(0.3...0.6, offset: 0.339, timeScale: 0.784, t: maskTimer), sinInRange(1.0...1.2, offset: 1.22, timeScale: 0.772, t: maskTimer)],
            [sinInRange(1.0...1.5, offset: 0.939, timeScale: 0.056, t: maskTimer), sinInRange(1.3...1.7, offset: 0.47, timeScale: 0.342, t: maskTimer)]
        ], colors: [
            .green, .blue, .mint,
            .mint, .green, .blue,
            .blue, .mint, .green
        ])
        
        .ignoresSafeArea()
        .onAppear() {
            timerSubscription = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
                .sink {_ in
                    maskTimer += gradientSpeed
                }
        }
        .onDisappear {
            timerSubscription?.cancel()
        }
    }
    
    private func sinInRange(_ range: ClosedRange<Float>, offset: Float, timeScale: Float, t: Float) -> Float {
        let amplitude = (range.upperBound - range.lowerBound) / 2
        let midPoint = (range.upperBound + range.lowerBound) / 2
        return midPoint + amplitude * sin(timeScale * t + offset)
    }
}

