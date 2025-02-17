import SwiftUI

struct LegendBadgeView: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    var onClose: () -> Void
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray, lineWidth: 2)
                .fill(colorScheme == .dark ? Color.black : Color.white)
                .shadow(radius: 10)
            VStack {
                Spacer()
                HStack {
                    Image(Badge.badgeDistanceLow.rawValue)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 65, height: 65)
                        .shadow(radius: 10)
                    Image(systemName: "arrowshape.right")
                        .frame(width: 20, height: 20)
                    
                    Text("how much distance a user has traveled")
                    Spacer()
                }
                HStack {
                    Image(Badge.badgeEcologicalChoiceLow.rawValue)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 65, height: 65)
                        .shadow(radius: 10)
                    Image(systemName: "arrowshape.right")
                        .frame(width: 20, height: 20)
                    Text("how much a user has been ecofriendly")
                    Spacer()
                }
                HStack {
                    Image(Badge.badgeTravelsNumberLow.rawValue)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 65, height: 65)
                        .shadow(radius: 10)
                    Image(systemName: "arrowshape.right")
                        .frame(width: 20, height: 20)
                    Text("how many travels a user has done")
                    Spacer()
                }
                HStack {
                    Image(Badge.badgeCompensationLow.rawValue)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 65, height: 65)
                        .shadow(radius: 10)
                    Image(systemName: "arrowshape.right")
                        .frame(width: 20, height: 20)
                    Text("how much a user has compensated")
                    Spacer()
                }
                
                
                Spacer()
                Button("Close") {
                    onClose()
                }
                .buttonStyle(.bordered)
                Spacer()
            }
            .padding()

        }
        .frame(width: 330, height: 400)
        
    }
}

