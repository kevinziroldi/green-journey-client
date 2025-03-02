import SwiftUI
import SwiftData

struct RankingView: View {
    @Binding var navigationPath: NavigationPath
    @StateObject var viewModel: RankingViewModel
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @Environment(\.modelContext) private var modelContext
    private var serverService: ServerServiceProtocol
    private var firebaseAuthService: FirebaseAuthServiceProtocol

    init(modelContext: ModelContext,navigationPath: Binding<NavigationPath>, serverService: ServerServiceProtocol, firebaseAuthService: FirebaseAuthServiceProtocol) {
        _viewModel = StateObject(wrappedValue: RankingViewModel(modelContext: modelContext, serverService: serverService))
        _navigationPath = navigationPath
        self.serverService = serverService
        self.firebaseAuthService = firebaseAuthService
        
    }
    
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Text("Ranking")
                        .font(.system(size: 32).bold())
                        .padding()
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .accessibilityIdentifier("rankingTitle")
                    
                    Spacer()
                    
                    NavigationLink(destination: UserPreferencesView(modelContext: modelContext, navigationPath: $navigationPath, serverService: serverService, firebaseAuthService: firebaseAuthService)) {
                        Image(systemName: "person")
                            .font(.title)
                            .foregroundStyle(AppColors.mainGreen)
                    }
                    .accessibilityIdentifier("userPreferencesButton")
                }
                .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                
                Picker("", selection: $viewModel.leaderboardSelected) {
                    Text("Long distance").tag(true)
                    Text("Short distance").tag(false)
                }
                .pickerStyle(.segmented)
                .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                .accessibilityIdentifier("shortLongDistanceControl")
                
                Spacer()
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
                                //.fill(Color(uiColor: .systemBackground))
                                .padding(.top, 5)
                            VStack{
                                if viewModel.leaderboardSelected {
                                    LeaderBoardView(viewModel: viewModel, navigationPath: $navigationPath, leaderboard: Array(viewModel.longDistanceRanking.prefix(10)))
                                }
                                else {
                                    LeaderBoardView(viewModel: viewModel, navigationPath: $navigationPath, leaderboard: Array(viewModel.shortDistanceRanking.prefix(10)))
                                }
                            }
                            .accessibilityElement(children: .contain)
                            .accessibilityIdentifier("leaderboard")
                        }
                        .padding(10)
                    }
                    
                    if viewModel.leaderboardSelected && viewModel.longDistanceRanking.count == 11 {
                        LeaderBoardUserView(userRanking: viewModel.longDistanceRanking[10])
                            .accessibilityElement(children: .contain)
                            .accessibilityIdentifier("leaderboardUserLongDistance")
                    }
                    
                    if !viewModel.leaderboardSelected && viewModel.shortDistanceRanking.count == 11 {
                        LeaderBoardUserView(userRanking: viewModel.shortDistanceRanking[10])
                            .accessibilityElement(children: .contain)
                            .accessibilityIdentifier("leaderboardUserShortDistance")
                    }
                }.fixedSize(horizontal: false, vertical: true)
                
                Spacer()
                
            }
        }
        .onAppear {
            Task {
                await viewModel.fecthRanking()
            }
        }
    }
}

struct LeaderBoardView: View {
    @ObservedObject var viewModel: RankingViewModel
    @Binding var navigationPath: NavigationPath
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    @Query var users: [User]
    var leaderboard: [RankingElement]
    
    var body: some View {
        VStack (spacing: 0){
            HStack {
                Text("   #.")
                    .font(.headline)
                Spacer()
                Spacer()
                Spacer()
                
                Text("User")
                    .font(.headline)
                Spacer()
                Spacer()
                Spacer()
                
                Text("Badges")
                    .font(.headline)
                Spacer()
                Spacer()
                Spacer()
                
                Text("Score")
                    .font(.headline)
            }
            .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
            .foregroundStyle(.black)
            .background(AppColors.mainGreen.opacity(0.8).clipShape(TopRoundedCorners(cornerRadius: 20)))
            .overlay(Color.clear.accessibilityIdentifier("tableHeader"))
            
            
            ForEach (leaderboard.indices, id: \.self) { index in
                NavigationLink (destination: UserDetailsRankingView(viewModel: viewModel, navigationPath: $navigationPath, user: leaderboard[index])) {
                    VStack (spacing: 5){
                        HStack {
                            // row of the table
                            
                            //position in the ranking
                            ZStack {
                                Circle()
                                    .stroke(LinearGradient(gradient: Gradient(colors: [.green, .blue]), startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 2)
                                    .frame(width: 40, height: 40)
                                
                                
                                Text("#\(index + 1)")
                                    .foregroundStyle(
                                        leaderboard[index].userID == users.first?.userID ?? -1 ? .blue : colorScheme == .dark ? .white : .black)
                                    .fontWeight(.semibold)
                            }
                            
                            Spacer()
                            
                            // name
                            VStack {
                                Text(leaderboard[index].firstName)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundStyle(leaderboard[index].userID == users.first?.userID ?? -1 ? .blue : colorScheme == .dark ? .white : .black)
                                    .fontWeight(.semibold)
                                Text(leaderboard[index].lastName)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundStyle(leaderboard[index].userID == users.first?.userID ?? -1 ? .blue : colorScheme == .dark ? .white : .black)
                                    .fontWeight(.semibold)
                            }
                            .padding(.leading, 30)

                            Spacer()
                            
                            // badges
                            BadgeView(badges: leaderboard[index].badges, dim: 40)
                            
                            // score
                            Text(String(format: "%.1f", leaderboard[index].score))
                                .frame(maxWidth: 90, alignment: .trailing)
                                .foregroundStyle(LinearGradient(gradient: Gradient(colors: [.green, .blue]), startPoint: .topLeading, endPoint: .bottomTrailing))
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
                .accessibilityIdentifier("rankingRow_\(index)")
            }
        }
        .padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
        
    }
}

struct LeaderBoardUserView: View {
    var userRanking: RankingElement
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
                
                HStack {
                    ZStack {
                        Circle()
                            .stroke(LinearGradient(gradient: Gradient(colors: [.green, .blue]), startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 2)
                            .frame(width: 40, height: 40)
                        
                        Text("#.")
                            .foregroundStyle(.blue)
                            .fontWeight(.semibold)
                    }
                    
                    Spacer()
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
                    .padding(.leading, 30)

                    Spacer()
                    
                    BadgeView(badges: userRanking.badges, dim: 40)
                    
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

