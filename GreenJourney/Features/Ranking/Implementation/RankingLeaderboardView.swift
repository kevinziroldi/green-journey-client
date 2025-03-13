import SwiftUI

struct RankingLeaderboardView: View {
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
                    LeaderBoardsView(viewModel: viewModel, navigationPath: $navigationPath, gridItems: gridItems, currentRanking: currentRanking)
                }
                .padding(.horizontal)
            }
        }
    }
}

