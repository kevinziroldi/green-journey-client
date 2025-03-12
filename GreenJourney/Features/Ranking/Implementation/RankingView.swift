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
                        LeaderboardNavigationView(title: "Long Distance", leaderboard: Array(viewModel.longDistanceRanking.prefix(3)), gridItems: gridItemsCompactDevice, leaderboardType: true)
                        
                        LeaderboardNavigationView(title: "Short Distance", leaderboard: Array(viewModel.shortDistanceRanking.prefix(3)), gridItems: gridItemsCompactDevice, leaderboardType: false)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                }
            } else {
                // iPadOS
                
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
            }
        }
        .background(colorScheme == .dark ? AppColors.backColorDark : AppColors.backColorLight)
        .sheet(isPresented: $legendTapped) {
            LegendBadgeView(isPresented: $legendTapped)
                .presentationDetents([.medium])
                .presentationCornerRadius(15)
        }
        .onAppear {
            Task {
                await viewModel.getUserFromServer()
                await viewModel.fecthRanking()
            }
        }
    }
}

private struct TopRoundedCorners: Shape {
    var cornerRadius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + cornerRadius))
        path.addArc(
            center: CGPoint(x: rect.minX + cornerRadius, y: rect.minY + cornerRadius),
            radius: cornerRadius,
            startAngle: .degrees(180),
            endAngle: .degrees(270),
            clockwise: false
        )
        path.addLine(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY))
        path.addArc(
            center: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY + cornerRadius),
            radius: cornerRadius,
            startAngle: .degrees(270),
            endAngle: .degrees(0),
            clockwise: false
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
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

private struct LeaderBoardPickerView: View {
    @ObservedObject var viewModel: RankingViewModel
    
    var body: some View {
        Picker("", selection: $viewModel.leaderboardSelected) {
            Text("Long distance").tag(true)
            Text("Short distance").tag(false)
        }
        .pickerStyle(.segmented)
        .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
        .accessibilityIdentifier("shortLongDistanceControl")
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
                    VStack{
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
                    LeaderBoardUserView(userRanking: currentRanking[10], gridItems: gridItems, leaderBoardSelected: viewModel.leaderboardSelected)
                        .accessibilityElement(children: .contain)
                        .accessibilityIdentifier("leaderboardUserLongDistance")
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

private struct LeaderBoardRow: View {
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
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.gray)
            }
        }
    }
}

private struct LeaderBoardUserView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

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
            
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(AppColors.mainColor, lineWidth: 3)
                    .shadow(radius: 10)
                
                VStack(spacing: 0) {
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
                            Text("#.")
                                .foregroundStyle(.blue)
                                .fontWeight(.semibold)
                        }
                        
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
        .padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
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
            VStack (spacing:0){
                HStack {
                    Text("Badges")
                        .font(.title)
                        .foregroundStyle(AppColors.mainColor.opacity(0.8))
                        .fontWeight(.semibold)
                    Button(action: {
                        legendTapped = true
                    }) {
                        Image(systemName: "info.circle")
                            .font(.title3)
                            .foregroundStyle(.gray)
                    }
                    Spacer()
                }
                .padding(EdgeInsets(top: 15, leading: 15, bottom: 0, trailing: 0))
                HStack{
                    BadgeView(badges: badges, dim: 80, inline: inline)
                        .padding()
                }
            }
        }
        .padding(EdgeInsets(top: 5, leading: 15, bottom: 7, trailing: 15))
        .overlay(Color.clear.accessibilityIdentifier("userBadges"))
    }
}

struct LeaderboardNavigationView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    let title: String
    let leaderboard: [RankingElement]
    var gridItems: [GridItem]
    let leaderboardType: Bool

    var body: some View {
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
                            
                            ForEach(leaderboard.indices, id: \.self) { index in
                                LeaderBoardRow(gridItems: gridItems, leaderboard: leaderboard, leaderBoardSelected: leaderboardType, index: index)
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
