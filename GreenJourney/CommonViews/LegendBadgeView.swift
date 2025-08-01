import SwiftUI

struct LegendBadgeView: View {
    @Binding var isPresented: Bool
    @Binding var isPresenting: Bool
    var body: some View {
        HStack {
            Spacer()
            Button(action: {
                isPresented = false
                isPresenting = false
            }) {
                Text("Done")
                    .fontWeight(.bold)
            }
            .accessibilityIdentifier("infoBadgesCloseButton")
        }
        .padding(.top)
        .padding(.horizontal)
        
        ScrollView {
            VStack {
                let badgeSize = min(200, (UIScreen.main.bounds.width - 60)/4, (UIScreen.main.bounds.height - 60)/4)
                
                Text("CO\u{2082} Compensator")
                    .font(.title)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .scaledToFit()
                    .lineLimit(1)
                HStack {
                    BadgeView(badges: [Badge.badgeCompensationBase, Badge.badgeCompensationLow, Badge.badgeCompensationMid, Badge.badgeCompensationHigh], dim: badgeSize, inline: true, allBadgeTypes: false)
                        .scaledToFit()
                }
                Text("This badge reflects your efforts to compensate for your carbon footprint. The more you offset, the bigger your impact!")
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("Kilometer Hunter")
                    .padding(.top, 30)
                    .font(.title)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .scaledToFit()
                    .lineLimit(1)
                HStack {
                    BadgeView(badges: [Badge.badgeDistanceBase, Badge.badgeDistanceLow, Badge.badgeDistanceMid, Badge.badgeDistanceHigh], dim: badgeSize, inline: true, allBadgeTypes: false)
                        .scaledToFit()
                }
                Text("See how far you’ve gone! This badge records the total distance you’ve traveled in kilometers.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("Planet Saver")
                    .padding(.top, 30)
                    .font(.title)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .scaledToFit()
                    .lineLimit(1)
                HStack {
                    BadgeView(badges: [Badge.badgeEcologicalChoiceBase, Badge.badgeEcologicalChoiceLow, Badge.badgeEcologicalChoiceMid, Badge.badgeEcologicalChoiceHigh], dim: badgeSize, inline: true, allBadgeTypes: false)
                        .scaledToFit()
                }
                Text("Earn this badge by making sustainable travel choices. The greener your trips, the higher your score!")
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("Serial Traveller")
                    .padding(.top, 30)
                    .font(.title)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .scaledToFit()
                    .lineLimit(1)
                HStack {
                    BadgeView(badges: [Badge.badgeTravelsNumberBase, Badge.badgeTravelsNumberLow, Badge.badgeTravelsNumberMid, Badge.badgeTravelsNumberHigh], dim: badgeSize, inline: true, allBadgeTypes: false)
                        .scaledToFit()
                }
                Text("This badge tracks the total number of trips you have taken. Keep exploring and watch your count grow!")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .overlay(Color.clear.accessibilityIdentifier("infoBadgesContent"))
            .padding(.bottom)
            .padding(.horizontal)
        }
    }
}
