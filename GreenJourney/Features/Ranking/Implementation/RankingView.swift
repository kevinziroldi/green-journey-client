import SwiftUI
import SwiftData

struct RankingView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @Binding var navigationPath: NavigationPath
    @StateObject private var viewModel: RankingViewModel
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @Environment(\.modelContext) private var modelContext
    @Query var users: [User]
    @State var legendTapped: Bool = false
    @State var isPresenting: Bool = false
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
                            UserPreferencesButtonView(navigationPath: $navigationPath, isPresenting: $isPresenting)
                        }
                        .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                        
                        VStack {
                            UserBadgesView(legendTapped: $legendTapped, badges: viewModel.badges, inline: true, isPresenting: $isPresenting)
                            
                            ScoresView(scoreLongDistance: viewModel.longDistanceScore, scoreShortDistance: viewModel.shortDistanceScore, isPresenting: $isPresenting)
                            
                            Spacer()
                            
                            if viewModel.resetRanking && viewModel.errorMessage == nil {
                                ProgressView()
                                    .padding(.top, 60)
                            }
                            else if !viewModel.longDistanceRanking.isEmpty {
                                // LeaderBoards
                                LeaderboardNavigationView(viewModel: viewModel, navigationPath: $navigationPath, title: "Long Distance", leaderboard: viewModel.longDistanceRanking, gridItems: gridItemsCompactDevice, leaderboardType: true, isPresenting: $isPresenting)
                                    .overlay(Color.clear.accessibilityIdentifier("longDistanceNavigationView"))
                                
                                LeaderboardNavigationView(viewModel: viewModel,navigationPath: $navigationPath, title: "Short Distance", leaderboard: viewModel.shortDistanceRanking, gridItems: gridItemsCompactDevice, leaderboardType: false, isPresenting: $isPresenting)
                                    .overlay(Color.clear.accessibilityIdentifier("shortDistanceNavigationView"))
                            }
                            
                            if viewModel.errorMessage != nil {
                                if colorScheme == .dark {
                                    Image("no_connection_dark")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 150, height: 150)
                                        .padding(.top, 60)
                                }
                                else {
                                    Image("no_connection_light")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 150, height: 150)
                                        .padding(.top, 60)
                                }
                                Text(viewModel.errorMessage ?? "")
                                    .padding(.horizontal)
                                    .multilineTextAlignment(.center)
                            }
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                }
                .scrollClipDisabled(true)
                .clipShape(Rectangle())
            } else {
                // iPadOS
                
                ScrollView {
                    HStack {
                        Spacer()
                        VStack {
                            // title
                            RankingTitleView()
                                .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                            
                            HStack(alignment: .top) {
                                // badges
                                UserBadgesView(legendTapped: $legendTapped, badges: viewModel.badges, inline: false, isPresenting: $isPresenting)
                                    .fixedSize(horizontal: false, vertical: true)

                                
                                // scores
                                ScoresView(scoreLongDistance: viewModel.longDistanceScore, scoreShortDistance: viewModel.shortDistanceScore, isPresenting: $isPresenting)
                            }
                            
                            Spacer()
                            
                            if viewModel.resetRanking && viewModel.errorMessage == nil {
                                ProgressView()
                                    .padding(.top, 60)
                            }
                            
                            else if !viewModel.longDistanceRanking.isEmpty {
                                // LeaderBoards
                                LeaderboardNavigationView(viewModel: viewModel, navigationPath: $navigationPath, title: "Long Distance", leaderboard: viewModel.longDistanceRanking, gridItems: gridItemsRegularDevice, leaderboardType: true, isPresenting: $isPresenting)
                                    .overlay(Color.clear.accessibilityIdentifier("longDistanceNavigationView"))
                                
                                LeaderboardNavigationView(viewModel: viewModel,navigationPath: $navigationPath, title: "Short Distance", leaderboard: viewModel.shortDistanceRanking, gridItems: gridItemsRegularDevice, leaderboardType: false, isPresenting: $isPresenting)
                                    .overlay(Color.clear.accessibilityIdentifier("shortDistanceNavigationView"))
                            }
                            
                            if viewModel.errorMessage != nil {
                                if colorScheme == .dark {
                                    Image("no_connection_dark")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 150, height: 150)
                                        .padding(.top, 60)
                                }
                                else {
                                    Image("no_connection_light")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 150, height: 150)
                                        .padding(.top, 60)
                                }
                                Text(viewModel.errorMessage ?? "")
                                    .padding(.horizontal)
                                    .multilineTextAlignment(.center)
                            }
                            Spacer()
                        }
                        .frame(maxWidth: 800)
                        Spacer()
                    }
                }
                .scrollClipDisabled(true)
                .clipShape(Rectangle())
            }
        }
        .refreshable {
            isPresenting = false
            viewModel.resetRanking = true
            if users.first != nil {
                Task {
                    await withTaskGroup(of: Void.self) { group in
                        group.addTask {
                            await viewModel.getUserFromServer()
                        }
                        group.addTask {
                            await viewModel.fecthRanking()
                        }
                    }
                }
            }
        }
        .background(colorScheme == .dark ? AppColors.backColorDark : AppColors.backColorLight)
        .sheet(isPresented: $legendTapped, onDismiss: {isPresenting = false}) {
            LegendBadgeView(isPresented: $legendTapped, isPresenting: $isPresenting)
                .presentationDetents([.fraction(0.95)])
                .presentationCornerRadius(15)
                .overlay(Color.clear.accessibilityIdentifier("infoBadgesView"))
        }
        .onAppear {
            isPresenting = false
            if users.first != nil {
                Task {
                    await withTaskGroup(of: Void.self) { group in
                        group.addTask {
                            await viewModel.getUserFromServer()
                        }
                        group.addTask {
                            await viewModel.fecthRanking()
                        }
                    }
                }
            }
        }
        .onDisappear {
            viewModel.resetRanking = true
        }
    }
}

private struct RankingTitleView: View {
    var body: some View {
        Text("Ranking")
            .font(.system(size: 32).bold())
            .padding(.vertical)
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityIdentifier("rankingTitle")
    }
}

private struct LeaderboardNavigationView: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @ObservedObject var viewModel: RankingViewModel
    @Binding var navigationPath: NavigationPath
    let title: String
    let leaderboard: [RankingElement]
    var gridItems: [GridItem]
    let leaderboardType: Bool
    @Binding var isPresenting: Bool
    
    var body: some View {
        Button(action: {
            if !isPresenting {
                isPresenting = true
                navigationPath.append(NavigationDestination.RankingLeaderBoardView(viewModel, title, leaderboardType))
            }
        })
        {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(colorScheme == .dark ? AppColors.blockColorDark: Color(uiColor: .systemBackground))
                    .shadow(radius: 3, x: 0, y: 3)
                VStack(spacing:0) {
                    HStack {
                        Text(title)
                            .font(.title)
                            .foregroundStyle(AppColors.mainColor)
                            .fontWeight(.semibold)
                            .scaledToFit()
                            .minimumScaleFactor(0.6)
                            .lineLimit(1)
                        Spacer()
                        Image(systemName: "list.number")
                            .foregroundColor(AppColors.mainColor)
                            .font(.title3)
                            .fontWeight(.bold)
                        Image(systemName: "chevron.right")
                            .foregroundColor(AppColors.mainColor)
                            .font(.title3)
                            .fontWeight(.bold)
                    }
                    .padding()
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(AppColors.mainColor, lineWidth: 3)
                        VStack (spacing: 0) {
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
                                LeaderBoardRow(leaderboard: Array(leaderboard.prefix(3)), leaderBoardSelected: leaderboardType, index: index)
                                    .accessibilityIdentifier("rankingRow_\(index)")
                            }
                            .padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                        }
                    }
                    .padding(10)
                }
            }
            .padding(EdgeInsets(top: 7, leading: 15, bottom: 7, trailing: 15))
        }
    }
}
