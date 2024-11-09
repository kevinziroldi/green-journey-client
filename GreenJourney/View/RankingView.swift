import SwiftUI

struct RankingView: View {
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("Ranking")
                        .font(.title)
                        .padding()
                    
                    Spacer()
                    
                    NavigationLink(destination: UserPreferencesView()) {
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
