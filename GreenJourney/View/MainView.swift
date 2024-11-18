import SwiftData
import SwiftUI

struct MainView: View {
    @StateObject private var viewModel: MainViewModel
    @StateObject var fromToViewModel: FromToViewModel
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab = 2
    
    @State var navigationPath: NavigationPath = NavigationPath()
    
    init(modelContext: ModelContext) {
        _viewModel = StateObject(wrappedValue: MainViewModel(modelContext: modelContext))
        _fromToViewModel = StateObject(wrappedValue: FromToViewModel(modelContext: modelContext))
        navigationPath = NavigationPath()
    }
    
    var body: some View {
        if viewModel.checkUserLogged() {
            NavigationStack (path: $navigationPath) {
                TabView(selection: $selectedTab) {
                    RankingView(navigationPath: $navigationPath)
                        .tabItem {
                            Label("Ranking", systemImage: "star")
                        }
                        .tag(0)
                    
                    ReviewsView(navigationPath: $navigationPath)
                        .tabItem {
                            Label("Reviews", systemImage: "star.fill")
                        }
                        .tag(1)
                    
                    FromToView(navigationPath: $navigationPath)
                        .environmentObject(fromToViewModel)
                        .tabItem {
                            Label("From-To", systemImage: "location")
                        }
                        .tag(2)
                    
                    TravelsView(modelContext: modelContext, navigationPath: $navigationPath)
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
                    // load cities from dataset (if needed)
                    viewModel.loadCityDataset()
                }
                .navigationDestination(for: NavigationDestination.self) { destination in
                    switch destination {
                    case .UserPreferencesView:
                        UserPreferencesView(modelContext: modelContext, navigationPath: $navigationPath)
                    case .TravelOptionsView:
                        TravelOptionsView(viewModel: fromToViewModel, navigationPath: $navigationPath)
                    case .ReturnOptionsView:
                        ReturnOptionsView(viewModel: fromToViewModel, navigationPath: $navigationPath)
                    case .LoginView:
                        LoginView(modelContext: modelContext)
                            .transition(.opacity.animation(.easeInOut(duration: 0.2)))
                    default:
                        Text("unknown destination")
                    }
                }
            }
        }else {
            LoginView(modelContext: modelContext)
        }
    }
}
