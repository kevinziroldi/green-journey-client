import SwiftData
import SwiftUI

struct MainView: View {
    @StateObject private var viewModel: MainViewModel
    @StateObject var travelSearchViewModel: TravelSearchViewModel
    @StateObject var cityReviewsViewModel: CitiesReviewsViewModel
    @StateObject var myTravelsViewModel: MyTravelsViewModel
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab = 2
    
    @State var navigationPath: NavigationPath = NavigationPath()
    
    init(modelContext: ModelContext) {
        _viewModel = StateObject(wrappedValue: MainViewModel(modelContext: modelContext))
        _travelSearchViewModel = StateObject(wrappedValue: TravelSearchViewModel(modelContext: modelContext))
        _cityReviewsViewModel = StateObject(wrappedValue: CitiesReviewsViewModel(modelContext: modelContext))
        _myTravelsViewModel = StateObject(wrappedValue: MyTravelsViewModel(modelContext: modelContext))
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
                        .environmentObject(cityReviewsViewModel)
                        .tabItem {
                            Label("Reviews", systemImage: "star.fill")
                        }
                        .tag(1)
                    
                    TravelSearchView(navigationPath: $navigationPath)
                        .environmentObject(travelSearchViewModel)
                        .tabItem {
                            Label("From-To", systemImage: "location")
                        }
                        .tag(2)
                    
                    MyTravelsView(modelContext: modelContext, navigationPath: $navigationPath)
                        .environmentObject(myTravelsViewModel)
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
                    case .UserPreferencesView:
                        UserPreferencesView(modelContext: modelContext, navigationPath: $navigationPath)
                    case .TravelOptionsView:
                        OutwardOptionsView(viewModel: travelSearchViewModel, navigationPath: $navigationPath)
                    case .ReturnOptionsView:
                        ReturnOptionsView(viewModel: travelSearchViewModel, navigationPath: $navigationPath)
                    case .LoginView:
                        LoginView(modelContext: modelContext)
                            .transition(.opacity.animation(.easeInOut(duration: 0.2)))
                    case .CityReviewsDetailsView:
                        CityReviewsDetailsView(viewModel: cityReviewsViewModel, navigationPath: $navigationPath)
                    case .TravelDetailsView:
                        TravelDetailsView(viewModel: myTravelsViewModel, navigationPath: $navigationPath)
                    }
                }
            }
        } else {
            LoginView(modelContext: modelContext)
        }
    }
}
