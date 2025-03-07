import SwiftUI

struct Co2RecapView: View {
    var halfWidth: Bool
    var co2Emitted: Float64
    var numTrees: Int
    var distance: Float64
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: computeTravelColor(distance: distance, co2Emitted: co2Emitted).opacity(0.3), radius: 5, x: 0, y: 3)
            
            if halfWidth {
                VStack {
                    Co2RecapViewTitle(color:computeTravelColor(distance: distance, co2Emitted: co2Emitted))
                    Co2RecapEmissionView(co2Emitted: co2Emitted, color: computeTravelColor(distance: distance, co2Emitted: co2Emitted))
                    Co2RecapNumTreesView(numTrees: numTrees, color: computeTravelColor(distance: distance, co2Emitted: co2Emitted))
                    Spacer()
                }
            } else {
                HStack (spacing:0){
                    VStack {
                        Co2RecapViewTitle(color:computeTravelColor(distance: distance, co2Emitted: co2Emitted))
                        Co2RecapEmissionView(co2Emitted: co2Emitted, color: computeTravelColor(distance: distance, co2Emitted: co2Emitted))
                    }
                    
                    Co2RecapNumTreesView(numTrees: numTrees, color: computeTravelColor(distance: distance, co2Emitted: co2Emitted))
                }
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

private struct Co2RecapViewTitle: View {
    var color: Color
    var body: some View {
        VStack {
            Text("Co2")
                .font(.title)
                .padding(EdgeInsets(top: 15, leading: 15, bottom: 0, trailing: 0))
                .foregroundStyle(color).opacity(0.8)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct Co2RecapEmissionView: View {
    var co2Emitted: Double
    var color: Color
    
    var body: some View {
        Text("Emission: " + String(format: "%.1f", co2Emitted) + " Kg")
            .font(.title2)
            .fontWeight(.semibold)
            .scaledToFit()
            .minimumScaleFactor(0.6)
            .lineLimit(1)
            .foregroundStyle(color)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct Co2RecapNumTreesView: View {
    var numTrees: Int
    var color: Color
    var body: some View {
        HStack {
            Text("#\(numTrees)")
            Image(systemName: "tree")
            Spacer()
        }
        .foregroundStyle(color)
        .font(.title)
        .fontWeight(.semibold)
        .padding()
        .padding(.trailing)
    }
}
