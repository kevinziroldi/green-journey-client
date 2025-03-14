import SwiftUI
import SwiftData

struct RankingView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @Binding var navigationPath: NavigationPath
    @StateObject var viewModel: RankingViewModel
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @Environment(\.modelContext) private var modelContext
    @State var legendTapped: Bool = false
    private var serverService: ServerServiceProtocol
    private var firebaseAuthService: FirebaseAuthServiceProtocol
    
    var gridItemsCompactDevice: [GridItem] {
        [
            GridItem(.fixed(50), alignment: .center),
            GridItem(.flexible(minimum: 80), alignment: .center),
            GridItem(.fixed(60), alignment: .center)
        ]
    }
    
    var gridItemsRegularDevice: [GridItem] {
        [
            GridItem(.flexible(), alignment: .center),
            GridItem(.flexible(), alignment: .center),
            GridItem(.flexible(), alignment: .center),
            GridItem(.flexible(), alignment: .center)
        ]
    }
    
    init(modelContext: ModelContext,navigationPath: Binding<NavigationPath>, serverService: ServerServiceProtocol, firebaseAuthService: FirebaseAuthServiceProtocol) {
        _viewModel = StateObject(wrappedValue: RankingViewModel(modelContext: modelContext, serverService: serverService))
        _navigationPath = navigationPath
        self.serverService = serverService
        self.firebaseAuthService = firebaseAuthService
    }
    
    var body: some View {
        VStack {
            if horizontalSizeClass == .compact {
                // iOS
                ScrollView {
                    VStack {
                        HStack {
                            // title
                            RankingTitleView()
                            
                            Spacer()
                            
                            // user preferences button
                            UserPreferencesButtonView(navigationPath: $navigationPath, serverService: serverService, firebaseAuthService: firebaseAuthService)
                        }
                        .padding(5)
                        
                        UserBadgesView(legendTapped: $legendTapped, badges: viewModel.badges, inline: true)
                        
                        ScoresView(scoreLongDistance: viewModel.longDistanceScore, scoreShortDistance: viewModel.shortDistanceScore)
                        
                        Spacer()
                        
                        // LeaderBoards
                        LeaderboardNavigationView(viewModel: viewModel, navigationPath: $navigationPath, title: "Long Distance", leaderboard: viewModel.longDistanceRanking, gridItems: gridItemsCompactDevice, leaderboardType: true)
                            .overlay(Color.clear.accessibilityIdentifier("longDistanceNavigationView"))
                        
                        LeaderboardNavigationView(viewModel: viewModel,navigationPath: $navigationPath, title: "Short Distance", leaderboard: viewModel.shortDistanceRanking, gridItems: gridItemsCompactDevice, leaderboardType: false)
                            .overlay(Color.clear.accessibilityIdentifier("shortDistanceNavigationView"))
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                }
            } else {
                // iPadOS
                
                // TODO da rifare
                /*
                ScrollView {
                    // title
                    RankingTitleView()
                        .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                    
                    // picker
                    LeaderBoardPickerView(viewModel: viewModel)
                        .frame(maxWidth: 400) // set a max width to control the size
                    
                    Spacer()
                    
                    // LeaderBoards
                    LeaderBoardsView(viewModel: viewModel, navigationPath: $navigationPath, gridItems: gridItemsRegularDevice, currentRanking: Array(viewModel.longDistanceRanking.prefix(3)))
                        .frame(maxWidth: 700)
                    LeaderBoardsView(viewModel: viewModel, navigationPath: $navigationPath, gridItems: gridItemsRegularDevice, currentRanking: Array(viewModel.shortDistanceRanking.prefix(3)))
                        .frame(maxWidth: 700)
                    
                    Spacer()
                }
                 */
            }
        }
        .background(colorScheme == .dark ? AppColors.backColorDark : AppColors.backColorLight)
        .sheet(isPresented: $legendTapped) {
            LegendBadgeView(isPresented: $legendTapped)
                .presentationDetents([.fraction(0.95)])
                .presentationCornerRadius(15)
                .overlay(Color.clear.accessibilityIdentifier("infoBadgesView"))
        }
        .onAppear {
            Task {
                await viewModel.getUserFromServer()
                await viewModel.fecthRanking()
            }
        }
    }
}

private struct RankingTitleView: View {
    var body: some View {
        Text("Ranking")
            .font(.system(size: 32).bold())
            .padding()
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityIdentifier("rankingTitle")
    }
}

private struct UserBadgesView: View {
    @Binding var legendTapped: Bool
    var badges: [Badge]
    var inline: Bool
    
    var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(uiColor: .systemBackground))
                    .shadow(color: AppColors.mainColor.opacity(0.3), radius: 5, x: 0, y: 3)
                VStack(spacing:0) {
                    HStack {
                        Text("Badges")
                            .font(.title)
                            .foregroundStyle(AppColors.mainColor.opacity(0.8))
                            .fontWeight(.semibold)
                        Spacer()
                        Button(action: {
                            legendTapped = true
                        }) {
                            Image(systemName: "info.circle")
                                .font(.title3)
                        }
                        .accessibilityIdentifier("infoBadgesButton")
                    }
                    .padding(EdgeInsets(top: 15, leading: 15, bottom: 0, trailing: 15))
                    
                    HStack{
                        BadgeView(badges: badges, dim: (UIScreen.main.bounds.width - 120)/4, inline: inline)
                            .padding()
                    }
                }
            }
            .overlay(Color.clear.accessibilityIdentifier("userBadgesView"))
        
        .padding(EdgeInsets(top: 5, leading: 15, bottom: 7, trailing: 15))
    }
}

struct LeaderboardNavigationView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @ObservedObject var viewModel: RankingViewModel
    @Binding var navigationPath: NavigationPath
    let title: String
    let leaderboard: [RankingElement]
    var gridItems: [GridItem]
    let leaderboardType: Bool

    var body: some View {
        NavigationLink(destination: RankingLeaderBoardView(viewModel: viewModel, navigationPath: $navigationPath, title: title, gridItems: gridItems, currentRanking: leaderboard)) {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(uiColor: .systemBackground))
                    .shadow(color: AppColors.mainColor.opacity(0.3), radius: 5, x: 0, y: 3)
                VStack (spacing:0){
                    HStack {
                        Text(title)
                            .font(.title)
                            .foregroundStyle(AppColors.mainColor.opacity(0.8))
                            .fontWeight(.semibold)
                            .scaledToFit()
                            .minimumScaleFactor(0.6)
                            .lineLimit(1)
                        Spacer()
                        Image(systemName: "list.number")
                            .foregroundColor(AppColors.mainColor.opacity(0.8))
                            .font(.title2)
                            .fontWeight(.bold)
                        Image(systemName: "chevron.right")
                            .foregroundColor(AppColors.mainColor.opacity(0.8))
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .padding()
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(AppColors.mainColor, lineWidth: 3)
                        VStack (spacing: 0) {
                            if leaderboard.isEmpty {
                                CircularProgressView()
                                    .padding(30)
                            } else {
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
                                
                                ForEach(leaderboard.prefix(3).indices, id: \.self) { index in
                                    LeaderBoardRow(gridItems: gridItems, leaderboard: Array(leaderboard.prefix(3)), leaderBoardSelected: leaderboardType, index: index)
                                        .accessibilityIdentifier("rankingRow_\(index)")
                                }
                                .padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                            }
                        }
                    }
                    .padding(10)
                }
            }
            .padding(EdgeInsets(top: 7, leading: 15, bottom: 7, trailing: 15))
        }
    }
}
