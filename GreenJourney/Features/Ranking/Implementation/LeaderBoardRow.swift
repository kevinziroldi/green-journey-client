import SwiftData
import SwiftUI

struct LeaderBoardRow: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var gridItems: [GridItem]
    @Query var users: [User]
    var leaderboard: [RankingElement]
    var leaderBoardSelected: Bool
    var index: Int
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    var body: some View {
        VStack(spacing: 5) {
            LazyVGrid(columns: gridItems, spacing: 10) {
                ZStack {
                    Circle()
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [.green, .blue]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                        .frame(width: 40, height: 40)
                    Text("#\(index + 1)")
                        .foregroundStyle(
                            leaderboard[index].userID == users.first?.userID ?? -1 ?
                                .blue :
                                (colorScheme == .dark ? .white : .black)
                        )
                        .fontWeight(.semibold)
                }
                
                VStack(alignment: .center) {
                    Text(leaderboard[index].firstName)
                        .foregroundStyle(
                            leaderboard[index].userID == users.first?.userID ?? -1 ?
                                .blue :
                                (colorScheme == .dark ? .white : .black)
                        )
                        .fontWeight(.semibold)
                    Text(leaderboard[index].lastName)
                        .foregroundStyle(
                            leaderboard[index].userID == users.first?.userID ?? -1 ?
                                .blue :
                                (colorScheme == .dark ? .white : .black)
                        )
                        .fontWeight(.semibold)
                }
                
                if horizontalSizeClass != .compact {
                    BadgeView(badges: leaderboard[index].badges, dim: 40, inline: false)
                }
                
                Text(String(format: "%.1f", leaderBoardSelected ?  leaderboard[index].scoreLongDistance : leaderboard[index].scoreShortDistance))
                    .scaledToFit()
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [.green, .blue]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .fontWeight(.bold)
            }
            .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
            
            if index < leaderboard.count - 1 {
                Divider()
            }
        }
    }
}
