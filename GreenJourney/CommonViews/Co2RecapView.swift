import SwiftUI

struct Co2RecapView: View {
    let co2Emitted: Float64
    let numTrees: Int
    let distance: Float64
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: computeTravelColor(distance: distance, co2Emitted: co2Emitted).opacity(0.3), radius: 5, x: 0, y: 3)
            HStack (spacing:0){
                VStack {
                    Text("Co2")
                        .font(.title)
                        .padding(EdgeInsets(top: 15, leading: 15, bottom: 0, trailing: 0))
                        .foregroundStyle(computeTravelColor(distance: distance, co2Emitted: co2Emitted).opacity(0.8))
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("Emission: " + String(format: "%.1f", co2Emitted) + " Kg")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(computeTravelColor(distance: distance, co2Emitted: co2Emitted))
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                HStack {
                    Text("#\(numTrees)")
                    Image(systemName: "tree")
                }
                .foregroundStyle(computeTravelColor(distance: distance, co2Emitted: co2Emitted))
                .font(.title)
                .fontWeight(.semibold)
                .padding()
                .padding(.trailing)
            }
        }
    }
    func computeTravelColor(distance: Float64, co2Emitted: Float64) -> Color {
        if co2Emitted == 0.0 {
            return Color.mint
        }
        if distance/co2Emitted > 30 {
            return Color.green
        }
        if distance/co2Emitted > 20 {
            return Color.yellow
        }
        return Color.red
    }
}
