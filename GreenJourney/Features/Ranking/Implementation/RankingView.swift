import SwiftUI
import SwiftData

struct RankingView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @Binding var navigationPath: NavigationPath
    @StateObject var viewModel: RankingViewModel
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @Environment(\.modelContext) private var modelContext
    private var serverService: ServerServiceProtocol
    private var firebaseAuthService: FirebaseAuthServiceProtocol

    var gridItems: [GridItem] {
        [
            GridItem(.flexible(), alignment: .leading),
            GridItem(.flexible(), alignment: .leading),
            GridItem(.flexible(), alignment: .leading),
            GridItem(.flexible(), alignment: .trailing)
        ]
    }
    
    init(modelContext: ModelContext,navigationPath: Binding<NavigationPath>, serverService: ServerServiceProtocol, firebaseAuthService: FirebaseAuthServiceProtocol) {
        _viewModel = StateObject(wrappedValue: RankingViewModel(modelContext: modelContext, serverService: serverService))
        _navigationPath = navigationPath
        self.serverService = serverService
        self.firebaseAuthService = firebaseAuthService
    }
    
    var body: some View {
        if horizontalSizeClass == .compact {
            ScrollView {
                HStack {
                    // title
                    RankingTitleView()
                    
                    Spacer()
                    
                    // user preferences button
                    UserPreferencesButton(navigationPath: $navigationPath, serverService: serverService, firebaseAuthService: firebaseAuthService)
                }
                .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                
                // picker
                LeaderBoardPickerView(viewModel: viewModel)
                
                Spacer()
                
                
                LeaderBoardsView(viewModel: viewModel, navigationPath: $navigationPath, gridItems: gridItems)
                
                Spacer()
            }
            .onAppear {
                Task {
                    await viewModel.fecthRanking()
                }
            }
        } else {
            ScrollView {
                // title
                RankingTitleView()
                    .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                
                // picker
                LeaderBoardPickerView(viewModel: viewModel)
                    .frame(maxWidth: 300)
                
                Spacer()
                
                // LeaderBoards
                LeaderBoardsView(viewModel: viewModel, navigationPath: $navigationPath, gridItems: gridItems)
                    .frame(maxWidth: 700)
                
                Spacer()
            }
            .onAppear {
                Task {
                    await viewModel.fecthRanking()
                }
            }
        }
    }
}

struct TopRoundedCorners: Shape {
    var cornerRadius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY)) // Bottom-left
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + cornerRadius)) // Left side
        path.addArc(
            center: CGPoint(x: rect.minX + cornerRadius, y: rect.minY + cornerRadius),
            radius: cornerRadius,
            startAngle: .degrees(180),
            endAngle: .degrees(270),
            clockwise: false
        )
        path.addLine(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY)) // Top side
        path.addArc(
            center: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY + cornerRadius),
            radius: cornerRadius,
            startAngle: .degrees(270),
            endAngle: .degrees(0),
            clockwise: false
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY)) // Right side
        path.closeSubpath()
        return path
    }
}

struct RankingTitleView: View {
    var body: some View {
        Text("Ranking")
            .font(.system(size: 32).bold())
            .padding()
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityIdentifier("rankingTitle")
    }
}

struct UserPreferencesButton: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var navigationPath: NavigationPath
    var serverService: ServerServiceProtocol
    var firebaseAuthService: FirebaseAuthServiceProtocol
    
    var body: some View {
        NavigationLink(destination: UserPreferencesView(modelContext: modelContext, navigationPath: $navigationPath, serverService: serverService, firebaseAuthService: firebaseAuthService)) {
            Image(systemName: "person")
                .font(.title)
                .foregroundStyle(AppColors.mainGreen)
        }
        .accessibilityIdentifier("userPreferencesButton")
    }
}

struct LeaderBoardPickerView: View {
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

struct LeaderBoardsView: View {
    @ObservedObject var viewModel: RankingViewModel
    @Binding var navigationPath: NavigationPath
    var gridItems: [GridItem]
    
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
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(AppColors.mainGreen, lineWidth: 3)
                        .padding(.top, 5)
                    VStack{
                        if viewModel.leaderboardSelected {
                            if viewModel.longDistanceRanking.isEmpty {
                                CircularProgressView()
                                    .padding(30)
                            } else {
                                LeaderBoardView(viewModel: viewModel, navigationPath: $navigationPath, gridItems: gridItems, leaderboard: Array(viewModel.longDistanceRanking.prefix(10)))
                            }
                        }
                        else {
                            if viewModel.longDistanceRanking.isEmpty {
                                CircularProgressView()
                                    .padding(30)
                            } else {
                                LeaderBoardView(viewModel: viewModel, navigationPath: $navigationPath, gridItems: gridItems, leaderboard: Array(viewModel.shortDistanceRanking.prefix(10)))
                            }
                        }
                    }
                    .accessibilityElement(children: .contain)
                    .accessibilityIdentifier("leaderboard")
                }
                .padding(10)
            }
            if viewModel.leaderboardSelected && viewModel.longDistanceRanking.count == 11 {
                if viewModel.longDistanceRanking.isEmpty {
                    CircularProgressView()
                }
                else {
                    LeaderBoardUserView(userRanking: viewModel.longDistanceRanking[10], gridItems: gridItems)
                        .accessibilityElement(children: .contain)
                        .accessibilityIdentifier("leaderboardUserLongDistance")
                        .padding(10)
                }
            }
            
            if !viewModel.leaderboardSelected && viewModel.shortDistanceRanking.count == 11 {
                if viewModel.shortDistanceRanking.isEmpty {
                    CircularProgressView()
                }
                else {
                    LeaderBoardUserView(userRanking: viewModel.shortDistanceRanking[10], gridItems: gridItems)
                        .accessibilityElement(children: .contain)
                        .accessibilityIdentifier("leaderboardUserShortDistance")
                        .padding(10)
                }
            }
        }.fixedSize(horizontal: false, vertical: true)
    }
}

struct LeaderBoardView: View {
    @ObservedObject var viewModel: RankingViewModel
    @Binding var navigationPath: NavigationPath
    var gridItems: [GridItem]
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    @Query var users: [User]
    var leaderboard: [RankingElement]
    
    var body: some View {
        VStack(spacing: 0) {
            LazyVGrid(columns: gridItems, spacing: 10) {
                Text("#.")
                    .font(.headline)
                Text("User")
                    .font(.headline)
                Text("Badges")
                    .font(.headline)
                Text("Score")
                    .font(.headline)
            }
            .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
            .foregroundStyle(.white)
            .background(
                AppColors.mainGreen
                    .clipShape(TopRoundedCorners(cornerRadius: 20))
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
                        
                        VStack(alignment: .leading) {
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
                        
                        BadgeView(badges: leaderboard[index].badges, dim: 40, inline: false)
                        
                        Text(String(format: "%.1f", leaderboard[index].score))
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
                }
                .accessibilityIdentifier("rankingRow_\(index)")
            }
        }
        .padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
    }
}

struct LeaderBoardUserView: View {
    var userRanking: RankingElement
    var gridItems: [GridItem]
    
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
            
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(AppColors.mainGreen, lineWidth: 3)
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
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundStyle(LinearGradient(gradient: Gradient(colors: [.green, .blue]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                .fontWeight(.semibold)
                            Text(userRanking.lastName)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundStyle(LinearGradient(gradient: Gradient(colors: [.green, .blue]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                .fontWeight(.semibold)
                        }
                        
                        BadgeView(badges: userRanking.badges, dim: 40, inline: false)
                        
                        Text(String(format: "%.1f", userRanking.score))
                            .frame(maxWidth: 90, alignment: .trailing)
                            .foregroundStyle(LinearGradient(gradient: Gradient(colors: [.green, .blue]), startPoint: .topLeading, endPoint: .bottomTrailing))
                            .fontWeight(.bold)
                        
                    }
                    .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
                }
                .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
            }
        }
        .padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
    }
}
