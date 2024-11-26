import SwiftUI
import SwiftData

struct RankingView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var navigationPath: NavigationPath
    @StateObject var viewModel: RankingViewModel
    
    init(modelContext: ModelContext, navigationPath: Binding<NavigationPath>) {
        _viewModel = StateObject(wrappedValue: RankingViewModel(modelContext: modelContext))
        _navigationPath = navigationPath
    }
    
    var body: some View {
        VStack {
            
            HStack {
                Text("Ranking")
                    .font(.title)
                    .padding()
                
                Spacer()
                
                Button(action: {
                    navigationPath.append(NavigationDestination.UserPreferencesView)
                }) {
                    Image(systemName: "person")
                        .font(.title)
                }
            }
            .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                        
            Text("Short distance leaderboard")
            HStack {
                Text("Nome Utente")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Badge")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                Text("Punteggio")
                    .font(.headline)
                    .frame(maxWidth: 80, alignment: .trailing)
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            ForEach (viewModel.shortDistanceRanking.indices, id: \.self) { index in
                NavigationLink (destination: UserDetailsRankingView(viewModel: viewModel, navigationPath: $navigationPath, user: viewModel.shortDistanceRanking[index])) {
                    HStack {
                        // Colonna Nome Utente
                        Text(viewModel.shortDistanceRanking[index].firstName + " " + viewModel.shortDistanceRanking[index].lastName)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        // Colonna Badge
                        BadgeView(badges: viewModel.shortDistanceRanking[index].badges)
                        // Colonna Punteggio
                        Text(String(format: "%.2f", viewModel.shortDistanceRanking[index].score))
                            .frame(maxWidth: 80, alignment: .trailing)
                    }
                    .padding(.vertical, 5)
                }
            }
            Spacer()
            Text("Long distance leaderboard")
            HStack {
                Text("Nome Utente")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Badge")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                Text("Punteggio")
                    .font(.headline)
                    .frame(maxWidth: 80, alignment: .trailing)
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            ForEach (viewModel.longDistanceRanking.indices, id: \.self) { index in
                NavigationLink (destination: UserDetailsRankingView(viewModel: viewModel, navigationPath: $navigationPath, user: viewModel.longDistanceRanking[index])) {
                    HStack {
                        // Colonna Nome Utente
                        Text(viewModel.longDistanceRanking[index].firstName + " " + viewModel.longDistanceRanking[index].lastName)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Colonna Badge
                        BadgeView(badges: viewModel.longDistanceRanking[index].badges)
                        // Colonna Punteggio
                        Text(String(format: "%.2f", viewModel.longDistanceRanking[index].score))
                            .frame(maxWidth: 80, alignment: .trailing)
                    }
                    .padding(.vertical, 5)
                }
            }
            
            Spacer()
         
        }
        .onAppear() {
            viewModel.fecthRanking()
        }
    }
}


struct BadgeView: View {
    var badges: [Badge]
    
    var body: some View {
        HStack {
            ForEach(Badge.allTypes, id: \.self) { badgeType in
                ZStack {
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(style: StrokeStyle(lineWidth: .infinity, dash: [10, 10]))
                        .frame(width: 30, height: 30)
                    //badge image
                    Image(imageForBadge(badgeType: badgeType))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                }
            }
        }
    }
    private func imageForBadge(badgeType: [Badge]) -> String {
        if let unlockedBadge = badges.first(where: { badgeType.contains($0) }) {
            return unlockedBadge.rawValue // Badge sbloccato
        } else {
            return badgeType.first?.baseBadge ?? "" // Badge base
        }
    }
}
