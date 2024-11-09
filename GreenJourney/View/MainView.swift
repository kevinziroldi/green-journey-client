import SwiftData
import SwiftUI

struct MainView: View {
    @StateObject private var viewModel: MainViewModel
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab = 1
    
    init(modelContext: ModelContext) {
        _viewModel = StateObject(wrappedValue: MainViewModel(modelContext: modelContext))
    }
    
    var body: some View {
        if viewModel.checkUserLogged() {
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
                
                TravelsView(modelContext: modelContext)
                    .tabItem {
                        Label("My travels", systemImage: "airplane")
                    }
                    .tag(2)
            }.onAppear {
                // refresh travels data
                viewModel.fetchTravels()
            }
        }else {
            LoginView(modelContext: modelContext)
        }
    }
}
