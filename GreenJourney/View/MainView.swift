import SwiftUI

struct MainView: View {
    @State private var selectedTab = 1
    
    var body: some View {
        TabView(selection: $selectedTab) {
            RankingView()
                .tabItem {
                    Label("Ranking", systemImage: "star")
                }
                .tag(0)
            
            FromToView()
                .tabItem {
                    Label("From-To", systemImage: "location")
                }
                .tag(1)
            
            MyTravelsView()
                .tabItem {
                    Label("My travels", systemImage: "airplane")
                }
                .tag(2)
        }
    }
}
