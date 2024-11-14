import SwiftData
import SwiftUI

struct MainView: View {
    @StateObject private var viewModel: MainViewModel
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab = 1
    
    @State var navigationPath: NavigationPath = NavigationPath()
    
    init(modelContext: ModelContext) {
        _viewModel = StateObject(wrappedValue: MainViewModel(modelContext: modelContext))
        navigationPath = NavigationPath()
    }
    
    var body: some View {
        if viewModel.checkUserLogged() {
            NavigationStack (path: $navigationPath) {
                TabView(selection: $selectedTab) {
                    RankingView()
                        .tabItem {
                            Label("Ranking", systemImage: "star")
                        }
                        .tag(0)
                    
                    FromToView(modelContext: modelContext)
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
                    // load cities from dataset (if needed)
                    viewModel.loadCityDataset()
                }
            }
            .onAppear {
                navigationPath = NavigationPath()
            }
        }else {
            LoginView(modelContext: modelContext)
        }
    }
}
