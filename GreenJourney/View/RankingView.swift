import SwiftUI

struct RankingView: View {
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("Ranking")
                        .font(.title)
                        .padding()
                    
                    Spacer()
                    
                    NavigationLink(destination: UserPreferencesView(modelContext: modelContext)) {
                        Image(systemName: "person")
                            .font(.title)
                    }
                    .padding()
                }
                
                Spacer()
                
                Text("Ranking ...")
                
                Spacer()
            }
        }
    }
}
