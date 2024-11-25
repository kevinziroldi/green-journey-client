import SwiftUI

struct UserDetailsRankingView: View {
    @ObservedObject var viewModel: RankingViewModel
    @Binding var navigationPath: NavigationPath
    
    var user: UserRanking
    var body: some View {
        VStack {
            HStack {
                Text(user.firstName + " " + user.lastName)
                Spacer()
                ForEach (user.badges, id: \.self) { badge in
                    Image("badge")
                }
                Spacer()
            }
            Text("Short distance score: " + String(format: "%.2f", user.scoreShortDistance))
            Text("Long distance score: " + String(format: "%.2f", user.scoreLongDistance))
            HStack {
                VStack {
                    Text("Total distance")
                    Text(String(format: "%.2f", user.distance))
                }
                VStack {
                    Text("Total travel time")
                    
                }
            }
            HStack {
                VStack {
                    Text("Co2 emitted")
                    Text(String(format: "%.2f", user.co2Emitted))
                }
                VStack {
                    Text("co2 compensated")
                    Text(String(format: "%.2f", user.co2Compensated))
                }
            }
            
        }
    }
    
}
