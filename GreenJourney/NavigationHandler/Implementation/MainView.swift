import SwiftData
import SwiftUI

struct MainView: View {
    @EnvironmentObject private var viewModel: MainViewModel
    @EnvironmentObject private var myTravelsViewModel: MyTravelsViewModel
    @EnvironmentObject private var rankingViewModel: RankingViewModel
    @Environment(\.modelContext) private var modelContext: ModelContext
    @State var navigationPath: NavigationPath
    
    @State private var selectedTab: TabViewElement
    @Query var users: [User]
    
    init(modelContext: ModelContext) {
        self.navigationPath = NavigationPath()
        self.selectedTab = TabViewElement.SearchTravel
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            TabView(selection: $selectedTab) {
                if users.first != nil{
                    RankingView(navigationPath: $navigationPath)
                        .tabItem {
                            Label("Ranking", systemImage: "star")
                        }
                        .tag(TabViewElement.Ranking)
                    
                    CitiesReviewsView(navigationPath: $navigationPath)
                        .tabItem {
                            Label("Reviews", systemImage: "star.fill")
                        }
                        .tag(TabViewElement.Reviews)
                    
                    TravelSearchView(navigationPath: $navigationPath)
                        .tabItem {
                            Label("From-To", systemImage: "location")
                        }
                        .tag(TabViewElement.SearchTravel)
                    
                    MyTravelsView(navigationPath: $navigationPath)
                        .tabItem {
                            Label("My travels", systemImage: "airplane")
                        }
                        .tag(TabViewElement.MyTravels)
                    
                    DashboardView(navigationPath: $navigationPath)
                        .tabItem {
                            Label("Dashboard", systemImage: "house")
                        }
                        .tag(TabViewElement.Dashboard)
                }else {
                    EmptyView()
                }
            }
            .onAppear {
                if !viewModel.isDataLoaded {
                    myTravelsViewModel.fetchTravelsFromServer()
                    viewModel.isDataLoaded = true
                }
            }
            .navigationDestination(for: NavigationDestination.self) { destination in
                switch destination {
                case .LoginView:
                    LoginView(navigationPath: $navigationPath)
                        .transition(.opacity.animation(.easeInOut(duration: 0.2)))
                case .SignupView:
                    SignUpView(navigationPath: $navigationPath)
                case .EmailVerificationView:
                    EmailVerificationView(navigationPath: $navigationPath)
                case .OutwardOptionsView:
                    OutwardOptionsView(navigationPath: $navigationPath)
                case .ReturnOptionsView:
                    ReturnOptionsView(navigationPath: $navigationPath)
                case .CityReviewsDetailsView:
                    CityReviewsDetailsView(navigationPath: $navigationPath)
                case .TravelDetailsView:
                    TravelDetailsView(navigationPath: $navigationPath)
                }
            }
        }
        .onAppear {
            if users.first == nil {
                navigationPath.append(NavigationDestination.LoginView)
            }
        }
    }
}
