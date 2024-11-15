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
                    navigationPath.append("UserPreferencesView")
                }) {
                    Image(systemName: "person")
                        .font(.title)
                }
            }
            
            Spacer()
            
            Text("Ranking ...")
            
            Spacer()
        }
    }
}
