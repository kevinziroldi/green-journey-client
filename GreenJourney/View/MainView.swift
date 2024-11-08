import SwiftData
import SwiftUI

struct MainView: View {
    @State private var selectedTab = 1
    @Environment(\.modelContext) private var modelContext
    @Query var users: [User]
    
    var body: some View {
        if checkUserLogged() {
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
                
                TravelsView()
                    .tabItem {
                        Label("My travels", systemImage: "airplane")
                    }
                    .tag(2)
            }
        }else {
            LoginView(modelContext: modelContext)
        }
    }
    
    func checkUserLogged() -> Bool {
        if users.first != nil {
            print("user IS logged")
            return true
        }else {
            print("user IS NOT logged")
            return false
        }
    }
}
