import SwiftData
import SwiftUI

struct MainView: View {
    @EnvironmentObject private var viewModel: MainViewModel
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab = 2
    
    @State var navigationPath: NavigationPath = NavigationPath()
    
    init(modelContext: ModelContext) {
        navigationPath = NavigationPath()
    }
    
    var body: some View {
        if viewModel.checkUserLogged() {
            NavigationStack (path: $navigationPath) {
                TabView(selection: $selectedTab) {
                    RankingView(modelContext: modelContext, navigationPath: $navigationPath)
                        .tabItem {
                            Label("Ranking", systemImage: "star")
                        }
                        .tag(0)
                    
                    CitiesReviewsView(navigationPath: $navigationPath)
                        .tabItem {
                            Label("Reviews", systemImage: "star.fill")
                        }
                        .tag(1)
                    
                    TravelSearchView(navigationPath: $navigationPath)
                        .tabItem {
                            Label("From-To", systemImage: "location")
                        }
                        .tag(2)
                    
                    MyTravelsView(modelContext: modelContext, navigationPath: $navigationPath)
                        .tabItem {
                            Label("My travels", systemImage: "airplane")
                        }
                        .tag(3)
                    
                    DashboardView(navigationPath: $navigationPath)
                        .tabItem {
                            Label("Dashboard", systemImage: "house")
                        }
                        .tag(4)
                }.onAppear {
                    // refresh travels data
                    viewModel.fetchTravels()
                    // load cities from dataset for ML (if needed)
                    viewModel.loadCityMLDataset()
                    // load cities from dataset for auto completer (if needed)
                    viewModel.loadCityCompleterDataset()
                }
                .navigationDestination(for: NavigationDestination.self) { destination in
                    switch destination {
                    case .OutwardOptionsView:
                        OutwardOptionsView(navigationPath: $navigationPath)
                    case .ReturnOptionsView:
                        ReturnOptionsView(navigationPath: $navigationPath)
                    case .LoginView:
                        LoginView()
                            .transition(.opacity.animation(.easeInOut(duration: 0.2)))
                    case .CityReviewsDetailsView:
                        CityReviewsDetailsView(navigationPath: $navigationPath)
                    case .TravelDetailsView:
                        TravelDetailsView(navigationPath: $navigationPath)
                    }
                }
            }
        } else {
            LoginView()
        }
    }
}
