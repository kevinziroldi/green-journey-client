import SwiftUI

struct LegendBadgeView: View {
    @Binding var isPresented: Bool
    var body: some View {
        ZStack {
            Text("Legend")
                .font(.largeTitle)
                .padding(.bottom)
            HStack {
                Spacer()
                Button(action: {
                    isPresented = false
                }) {
                    Text("Done")
                        .fontWeight(.bold)
                }
                .padding(.bottom, 30)
            }
            .padding(.horizontal)
        }
        .padding(.top)
        ScrollView {
            VStack {
                Text("Co2 compensator")
                    .font(.title)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .scaledToFit()
                    .lineLimit(1)
                HStack {
                    BadgeView(badges: [Badge.badgeCompensationBase, Badge.badgeCompensationLow, Badge.badgeCompensationMid, Badge.badgeCompensationHigh], dim: 90, inline: true)
                        .scaledToFit()
                }
                Text("This badge reflects your efforts to compensate for your carbon footprint. The more you offset, the bigger your impact!")
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("Kilometer hunter")
                    .padding(.top, 30)
                    .font(.title)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .scaledToFit()
                    .lineLimit(1)
                HStack {
                    BadgeView(badges: [Badge.badgeDistanceBase, Badge.badgeDistanceLow, Badge.badgeDistanceMid, Badge.badgeDistanceHigh], dim: 90, inline: true)
                        .scaledToFit()
                }
                Text("See how far you’ve gone! This badge records the total distance you’ve traveled in kilometers.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("Planet saver")
                    .padding(.top, 30)
                    .font(.title)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .scaledToFit()
                    .lineLimit(1)
                HStack {
                    BadgeView(badges: [Badge.badgeEcologicalChoiceBase, Badge.badgeEcologicalChoiceLow, Badge.badgeEcologicalChoiceMid, Badge.badgeEcologicalChoiceHigh], dim: 90, inline: true)
                        .scaledToFit()
                }
                Text("Earn this badge by making sustainable travel choices. The greener your trips, the higher your score!")
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("Serial traveller")
                    .padding(.top, 30)
                    .font(.title)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .scaledToFit()
                    .lineLimit(1)
                HStack {
                    BadgeView(badges: [Badge.badgeTravelsNumberBase, Badge.badgeTravelsNumberLow, Badge.badgeTravelsNumberMid, Badge.badgeTravelsNumberHigh], dim: 90, inline: true)
                        .scaledToFit()
                }
                Text("This badge tracks the total number of trips you have taken. Keep exploring and watch your count grow!")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.bottom)
            .padding(.horizontal)
        }
    }
}
