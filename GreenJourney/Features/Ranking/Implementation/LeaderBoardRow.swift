import SwiftData
import SwiftUI

struct LeaderBoardRow: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var gridItems: [GridItem] {
        if horizontalSizeClass == .regular {
            [
                GridItem(.flexible(), alignment: .center),
                GridItem(.flexible(), alignment: .center),
                GridItem(.flexible(), alignment: .center),
                GridItem(.flexible(), alignment: .center)
            ]
        }
        else {
            [
                GridItem(.fixed(50), alignment: .center),
                GridItem(.flexible(minimum: 80), alignment: .center),
                GridItem(.fixed(60), alignment: .center)
            ]
        }
    }
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
                        .stroke(computeColor(), lineWidth: 3)
                        .frame(width: 40, height: 40)
                    Text("\(index + 1)")
                        .foregroundStyle(computeColor())
                        .font(.system(size: 22))
                        .fontWeight(.semibold)
                }
                
                VStack(alignment: .center) {
                    Text(leaderboard[index].firstName)
                        .foregroundStyle(
                            leaderboard[index].userID == users.first?.userID ?? -1 ?
                            LinearGradient(gradient: Gradient(colors: [.green, .blue]), startPoint: .topLeading, endPoint: .bottomTrailing) :
                                (colorScheme == .dark ? LinearGradient(gradient: Gradient(colors: [.white]), startPoint: .topLeading, endPoint: .bottomTrailing) : LinearGradient(gradient: Gradient(colors: [.black]), startPoint: .topLeading, endPoint: .bottomTrailing))
                        )
                        .fontWeight(.semibold)
                    Text(leaderboard[index].lastName)
                        .foregroundStyle(
                            leaderboard[index].userID == users.first?.userID ?? -1 ?
                            LinearGradient(gradient: Gradient(colors: [.green, .blue]), startPoint: .topLeading, endPoint: .bottomTrailing) :
                                (colorScheme == .dark ? LinearGradient(gradient: Gradient(colors: [.white]), startPoint: .topLeading, endPoint: .bottomTrailing) : LinearGradient(gradient: Gradient(colors: [.black]), startPoint: .topLeading, endPoint: .bottomTrailing))
                        )
                        .fontWeight(.semibold)
                }
                
                if horizontalSizeClass != .compact {
                    BadgeView(badges: leaderboard[index].badges, dim: 40, inline: false, allBadgeTypes: true)
                }
                
                Text(String(format: "%.1f", leaderBoardSelected ?  leaderboard[index].scoreLongDistance : leaderboard[index].scoreShortDistance))
                    .scaledToFit()
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                    .foregroundStyle(
                        leaderboard[index].userID == users.first?.userID ?? -1 ?
                        LinearGradient(gradient: Gradient(colors: [.green, .blue]), startPoint: .topLeading, endPoint: .bottomTrailing) :
                            (colorScheme == .dark ? LinearGradient(gradient: Gradient(colors: [.white]), startPoint: .topLeading, endPoint: .bottomTrailing) : LinearGradient(gradient: Gradient(colors: [.black]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    )
                    .fontWeight(.bold)
            }
            .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
            
            if index < leaderboard.count - 1 {
                Divider()
            }
        }
    }
    func computeColor() -> Color{
        if index == 0 {
            return AppColors.gold
        }
        if index == 1 {
            return AppColors.silver
        }
        if index == 2 {
            return AppColors.bronze
        }
        return (colorScheme == .dark ? .white.opacity(0.7) : .black.opacity(0.7))
    }
}
