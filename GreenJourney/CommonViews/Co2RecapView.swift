import SwiftUI

struct Co2RecapView: View {
    var halfWidth: Bool
    var co2Emitted: Float64
    var numTrees: Int
    var distance: Float64
    
    var body: some View {
        ZStack {
            if halfWidth {
                VStack {
                    Co2RecapViewTitle(color:computeTravelColor(distance: distance, co2Emitted: co2Emitted))
                    Co2RecapEmissionView(co2Emitted: co2Emitted, color: computeTravelColor(distance: distance, co2Emitted: co2Emitted))
                    Co2RecapNumTreesView(numTrees: numTrees, color: computeTravelColor(distance: distance, co2Emitted: co2Emitted))
                }
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color(uiColor: .systemBackground))
                        .shadow(color: computeTravelColor(distance: distance, co2Emitted: co2Emitted).opacity(0.3), radius: 5, x: 0, y: 3)
                )
            } else {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(uiColor: .systemBackground))
                    .shadow(color: computeTravelColor(distance: distance, co2Emitted: co2Emitted).opacity(0.3), radius: 5, x: 0, y: 3)
                
                HStack (spacing:0){
                    VStack {
                        Co2RecapViewTitle(color:computeTravelColor(distance: distance, co2Emitted: co2Emitted))
                        Co2RecapEmissionView(co2Emitted: co2Emitted, color: computeTravelColor(distance: distance, co2Emitted: co2Emitted))
                    }
                    .padding(.bottom, 15)
                    
                    Co2RecapNumTreesView(numTrees: numTrees, color: computeTravelColor(distance: distance, co2Emitted: co2Emitted))
                }
            }
        }
    }
    func computeTravelColor(distance: Float64, co2Emitted: Float64) -> Color {
        if co2Emitted == 0.0 {
            return Color(red: 102/255, green: 187/255, blue: 106/255)
        }
        if distance/co2Emitted > 30 {
            return Color(red: 102/255, green: 187/255, blue: 106/255)
        }
        if distance/co2Emitted > 20 {
            return Color(red: 207/255, green: 155/255, blue: 2/255)
        }
        return Color(red: 184/255, green: 56/255, blue: 53/255)
    }
}

private struct Co2RecapViewTitle: View {
    var color: Color
    var body: some View {
        VStack {
            Text("CO\u{2082}")
                .font(.title)
                .padding(EdgeInsets(top: 15, leading: 15, bottom: 0, trailing: 0))
                .foregroundStyle(color)
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
            .padding(EdgeInsets(top: 5, leading: 15, bottom: 0, trailing: 15))
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
        .padding(EdgeInsets(top: 5, leading: 15, bottom: 15, trailing: 15))
        .padding(.trailing)
    }
}
