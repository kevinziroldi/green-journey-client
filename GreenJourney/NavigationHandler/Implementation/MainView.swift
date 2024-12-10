import SwiftData
import SwiftUI

struct MainView: View {
    @EnvironmentObject private var viewModel: MainViewModel
    @EnvironmentObject private var rankingViewModel: RankingViewModel
    @Environment(\.modelContext) private var modelContext: ModelContext
    @State var navigationPath: NavigationPath
    
    @State private var selectedTab: TabViewElement
    
    init(modelContext: ModelContext) {
        self.navigationPath = NavigationPath()
        self.selectedTab = TabViewElement.SearchTravel
    }
    
    var body: some View {
        NavigationStack (path: $navigationPath) {
            TabView(selection: $selectedTab) {
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
            }.onAppear {
                viewModel.loadData()
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
        }.onAppear() {
            if !viewModel.checkUserLogged() {
                navigationPath.append(NavigationDestination.LoginView)
            }
        }
        .onChange(of:selectedTab) {
            
            print("Selected tab = ", selectedTab)
            
            if selectedTab == TabViewElement.Ranking {
                rankingViewModel.fecthRanking()
            }
        }
    }
}


