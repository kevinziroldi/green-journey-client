import SwiftData
import SwiftUI

struct RankingLeaderBoardView: View {
    @ObservedObject var viewModel: RankingViewModel
    @Binding var navigationPath: NavigationPath
    let title: String
    var gridItems: [GridItem]
    var currentRanking: [RankingElement]
    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    Text(title)
                        .font(.system(size: 32).bold())
                        .padding()
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .accessibilityIdentifier("rankingName")
                    
                    LeaderBoardsView(viewModel: viewModel, navigationPath: $navigationPath, gridItems: gridItems, currentRanking: currentRanking)
                }
                .padding(.horizontal)
            }
        }
    }
}

private struct LeaderBoardsView: View {
    @ObservedObject var viewModel: RankingViewModel
    @Binding var navigationPath: NavigationPath
    var gridItems: [GridItem]
    var currentRanking: [RankingElement]
    
    var body: some View {
        VStack{
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.headline)
                    .fontWeight(.light)
                    .foregroundStyle(.red)
                    .accessibilityIdentifier("errorMessage")
            }
            else {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(AppColors.mainColor, lineWidth: 3)
                        .padding(.top, 5)
                    VStack {
                        if currentRanking.isEmpty {
                            CircularProgressView()
                                .padding(30)
                        } else {
                            LeaderBoardView(viewModel: viewModel, navigationPath: $navigationPath, gridItems: gridItems, leaderboard: Array(currentRanking.prefix(10)), leaderBoardSelected: viewModel.leaderboardSelected)
                        }
                    }
                    .accessibilityElement(children: .contain)
                    .accessibilityIdentifier("leaderboard")
                }
                .padding(10)
            }
            
            if currentRanking.count == 11 {
                if viewModel.longDistanceRanking.isEmpty {
                    CircularProgressView()
                } else {
                    LeaderBoardUserView(viewModel: viewModel, navigationPath: $navigationPath, userRanking: currentRanking[10], gridItems: gridItems, leaderBoardSelected: viewModel.leaderboardSelected)
                        .accessibilityElement(children: .contain)
                        .accessibilityIdentifier("leaderboardUser")
                        .padding(.horizontal, 10)
                }
            }
        }.fixedSize(horizontal: false, vertical: true)
    }
}

private struct LeaderBoardView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @ObservedObject var viewModel: RankingViewModel
    @Binding var navigationPath: NavigationPath
    var gridItems: [GridItem]
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    var leaderboard: [RankingElement]
    var leaderBoardSelected: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            LazyVGrid(columns: gridItems, spacing: 10) {
                Text("#.")
                    .font(.headline)
                Text("User")
                    .font(.headline)
                
                if horizontalSizeClass != .compact {
                    Text("Badges")
                        .font(.headline)
                }
                
                Text("Score")
                    .font(.headline)
            }
            .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
            .foregroundStyle(.white)
            .background(
                AppColors.mainColor
                    .clipShape(TopRoundedCorners(cornerRadius: 10))
            )
            .overlay(Color.clear.accessibilityIdentifier("tableHeader"))
            
            ForEach(leaderboard.indices, id: \.self) { index in
                NavigationLink(
                    destination: UserDetailsRankingView(
                        viewModel: viewModel,
                        navigationPath: $navigationPath,
                        user: leaderboard[index]
                    )
                ) {
                    LeaderBoardRow(gridItems: gridItems, leaderboard: leaderboard, leaderBoardSelected: leaderBoardSelected, index: index)
                }
                .accessibilityIdentifier("rankingRow_\(index)")
            }
        }
        .padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
    }
}

private struct LeaderBoardUserView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @ObservedObject var viewModel: RankingViewModel
    @Binding var navigationPath: NavigationPath
    
    var userRanking: RankingElement
    
    var gridItems: [GridItem]
    var leaderBoardSelected: Bool
    
    var body: some View {
        VStack {
            HStack {
                Circle()
                    .frame(width: 8, height: 8)
                Circle()
                    .frame(width: 8, height: 8)
                Circle()
                    .frame(width: 8, height: 8)
            }
            .padding(.bottom, 10)
            NavigationLink(
                destination: UserDetailsRankingView(
                    viewModel: viewModel,
                    navigationPath: $navigationPath,
                    user: userRanking
                )
            ) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(AppColors.mainColor, lineWidth: 3)
                    
                    VStack(spacing: 0) {
                        LazyVGrid(columns: gridItems, spacing: 10) {
                            ZStack {
                                Circle()
                                    .stroke(LinearGradient(
                                        gradient: Gradient(colors: [.green, .blue]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing)
                                    , lineWidth: 3)
                                    .frame(width: 40, height: 40)
                                Text("#")
                                    .foregroundStyle(.blue)
                                    .font(.system(size: 22))
                                    .fontWeight(.semibold)                            }
                            
                            VStack {
                                Text(userRanking.firstName)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .foregroundStyle(LinearGradient(gradient: Gradient(colors: [.green, .blue]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .fontWeight(.semibold)
                                Text(userRanking.lastName)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .foregroundStyle(LinearGradient(gradient: Gradient(colors: [.green, .blue]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .fontWeight(.semibold)
                            }
                            
                            if horizontalSizeClass != .compact {
                                BadgeView(badges: userRanking.badges, dim: 40, inline: false)
                            }
                            
                            Text(String(format: "%.1f", leaderBoardSelected ? userRanking.scoreLongDistance : userRanking.scoreShortDistance))
                                .frame(maxWidth: 90, alignment: .center)
                                .foregroundStyle(LinearGradient(gradient: Gradient(colors: [.green, .blue]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                .fontWeight(.bold)
                        }
                        .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
                    }
                }
            }
        }
        .padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
    }
}
