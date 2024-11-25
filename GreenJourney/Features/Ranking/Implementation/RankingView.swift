import SwiftUI

struct RankingView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var navigationPath: NavigationPath
    @StateObject var viewModel: RankingViewModel = RankingViewModel()
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
            
            Spacer()
            
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
            ForEach (viewModel.shortDistanceRanking) { user in
                NavigationLink (destination: UserDetailsRankingView(viewModel: viewModel, navigationPath: $navigationPath, user: user)) {
                    HStack {
                        // Colonna Nome Utente
                        Text(user.firstName + " " + user.lastName)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Colonna Badge
                        HStack(spacing: 5) {
                            /*ForEach(entry.badges, id: \.self) { badge in
                                Image(systemName: badge)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(badge == "star.fill" ? .yellow : .gray)
                            }*/
                        }
                        .frame(maxWidth: .infinity)
                        
                        // Colonna Punteggio
                        Text(String(format: "%.2f", user.scoreShortDistance))
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
            ForEach (viewModel.longDistanceRanking) { user in
                NavigationLink (destination: UserDetailsRankingView(viewModel: viewModel, navigationPath: $navigationPath, user: user)) {
                    HStack {
                        // Colonna Nome Utente
                        Text(user.firstName + " " + user.lastName)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Colonna Badge
                        HStack(spacing: 5) {
                            /*ForEach(entry.badges, id: \.self) { badge in
                                Image(systemName: badge)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(badge == "star.fill" ? .yellow : .gray)
                            }*/
                        }
                        .frame(maxWidth: .infinity)
                        
                        // Colonna Punteggio
                        Text(String(format: "%.2f", user.scoreShortDistance))
                            .frame(maxWidth: 80, alignment: .trailing)
                    }
                    .padding(.vertical, 5)
                }
            }
            
            Spacer()
        }
    }
}
