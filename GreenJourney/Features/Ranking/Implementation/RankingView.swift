import SwiftUI

struct RankingView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var navigationPath: NavigationPath

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
            
            Text("Ranking ...")
            
            Spacer()
        }
    }
}
