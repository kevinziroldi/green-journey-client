import SwiftUI
import SwiftData

struct RankingView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var navigationPath: NavigationPath
    @EnvironmentObject var viewModel: RankingViewModel
    
    init(navigationPath: Binding<NavigationPath>) {
        _navigationPath = navigationPath
    }
    
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Text("Ranking")
                        .font(.title)
                        .padding()
                    
                    Spacer()
                    
                    NavigationLink(destination: UserPreferencesView(navigationPath: $navigationPath)) {
                        Image(systemName: "person")
                            .font(.title)
                    }
                }
                .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                
                
                Picker("", selection: $viewModel.leaderboardSelected) {
                    Text("Long distance").tag(true)
                    Text("Short distance").tag(false)
                }
                .pickerStyle(.segmented)
                .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                
                Spacer()
                VStack{
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.black, lineWidth: 1.5)
                            .shadow(radius: 10)
                            .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                        VStack{
                            if viewModel.leaderboardSelected {
                                LeaderBoardView(navigationPath: $navigationPath, leaderboard: Array(viewModel.longDistanceRanking.prefix(10)))
                            }
                            else {
                                LeaderBoardView(navigationPath: $navigationPath, leaderboard: Array(viewModel.shortDistanceRanking.prefix(10)))
                            }
                        }
                        .padding(EdgeInsets(top: 0, leading: 10, bottom: 5, trailing: 10))
                    }
                    
                    if viewModel.leaderboardSelected && viewModel.longDistanceRanking.count == 11 {
                        LeaderBoardUserView(userRanking: viewModel.longDistanceRanking[10])
                    }
                    
                    if !viewModel.leaderboardSelected && viewModel.shortDistanceRanking.count == 11 {
                        LeaderBoardUserView(userRanking: viewModel.shortDistanceRanking[10])
                    }
                    
                    
                    
                }.fixedSize(horizontal: false, vertical: true)
                
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
            }
        }
        .onAppear() {
            viewModel.fecthRanking()
        }
    }
}

struct LeaderBoardView: View {
    @EnvironmentObject var viewModel: RankingViewModel
    @Binding var navigationPath: NavigationPath
    var leaderboard: [RankingElement]
    @State private var userID = 1
    
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
            .background(
                Color.green.opacity(0.2)
                    .clipShape(TopRoundedCorners(cornerRadius: 20))
            )
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.black)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 0))
            ForEach (leaderboard.indices, id: \.self) { index in
                    NavigationLink (destination: UserDetailsRankingView(navigationPath: $navigationPath, user: leaderboard[index])) {
                        VStack (spacing: 5){
                            HStack {
                                // Colonna Nome Utente
                                ZStack {
                                    Circle()
                                        .stroke(LinearGradient(gradient: Gradient(colors: [.green, .blue]), startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 2)
                                        .frame(width: 40, height: 40)
                                    
                                    
                                    Text("#\(index + 1)")
                                        .foregroundStyle(
                                            leaderboard[index].userID == userID ? .blue : .black)
                                        .fontWeight(.semibold)
                                }
                                Spacer()
                                Text(leaderboard[index].firstName + " " + leaderboard[index].lastName.prefix(1) + ".")
                                    .frame(alignment: .leading)
                                    .foregroundStyle(leaderboard[index].userID == userID ? .blue : .black)
                                    .fontWeight(.semibold)
                                /*VStack (spacing: 0){
                                 Text(leaderboard[index].firstName)
                                 .frame(maxWidth: .infinity, alignment: .leading)
                                 .foregroundStyle(leaderboard[index].userID == userID ? .blue : .black)
                                 Text(leaderboard[index].lastName)
                                 .frame(maxWidth: .infinity, alignment: .leading)
                                 .foregroundStyle(leaderboard[index].userID == userID ? .blue : .black)
                                 }*/
                                Spacer()
                                // Colonna Badge
                                BadgeView(badges: leaderboard[index].badges, dim: 40, inline: false)
                                // Colonna Punteggio
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
                    .stroke(Color.black, lineWidth: 1.5)
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
                    Text(userRanking.firstName + " " + userRanking.lastName.prefix(1) + ".")
                        .frame(alignment: .leading)
                        .foregroundStyle(LinearGradient(gradient: Gradient(colors: [.green, .blue]), startPoint: .topLeading, endPoint: .bottomTrailing))
                        .fontWeight(.semibold)
                    
                    Spacer()
                    // Colonna Badge
                    BadgeView(badges: userRanking.badges, dim: 40, inline: false)
                    // Colonna Punteggio
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


struct BadgeView: View {
    var badges: [Badge]
    var dim: CGFloat
    var inline: Bool
    
    var body: some View {
        let allBadges = getBestBadges(badges: badges)
        if !inline {
            
            VStack(spacing: 5) { // Due righe
                HStack(spacing: 5) { // Prima riga
                    Image(allBadges[0].rawValue)
                        .resizable()
                        .scaledToFit()
                        .frame(width: dim, height: dim)
                    Image(allBadges[1].rawValue)
                        .resizable()
                        .scaledToFit()
                        .frame(width: dim, height: dim)
                }
                HStack(spacing: 5) { // Seconda riga
                    Image(allBadges[2].rawValue)
                        .resizable()
                        .scaledToFit()
                        .frame(width: dim, height: dim)
                    Image(allBadges[3].rawValue)
                        .resizable()
                        .scaledToFit()
                        .frame(width: dim, height: dim)
                }
            }
        }
        else{
            HStack (spacing: 3) {
                Image(allBadges[0].rawValue)
                    .resizable()
                    .scaledToFit()
                    .frame(width: dim, height: dim)
                Image(allBadges[1].rawValue)
                    .resizable()
                    .scaledToFit()
                    .frame(width: dim, height: dim)
                Image(allBadges[2].rawValue)
                    .resizable()
                    .scaledToFit()
                    .frame(width: dim, height: dim)
                Image(allBadges[3].rawValue)
                    .resizable()
                    .scaledToFit()
                    .frame(width: dim, height: dim)
            }
        }
        
    }
    
    private func getBestBadges(badges: [Badge]) -> [Badge] {
        var completedBadges: [Badge] = badges
        for group in Badge.allTypes {
            // Controlla se il gruppo è già rappresentato
            if !completedBadges.contains(where: { group.contains($0) }) {
                // Se mancante, aggiungi il badge base del gruppo
                if let baseBadge = group.first?.baseBadge {
                    completedBadges.append(baseBadge) // Fallback se il badge base non esiste
                }
            }
        }
        return completedBadges
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
