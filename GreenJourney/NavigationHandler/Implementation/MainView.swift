import SwiftData
import SwiftUI

struct MainView: View {
    @EnvironmentObject private var viewModel: MainViewModel
    @EnvironmentObject private var rankingViewModel: RankingViewModel
    @Environment(\.modelContext) private var modelContext
    @State var navigationPath: NavigationPath = NavigationPath()
    
    @State private var selectedTab = 2
    
    init(modelContext: ModelContext) {
        navigationPath = NavigationPath()
    }
    
    var body: some View {
        NavigationStack (path: $navigationPath) {
            TabView(selection: $selectedTab) {
                RankingView(navigationPath: $navigationPath)
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
                }
            }
        }.onAppear() {
            if !viewModel.checkUserLogged() {
                navigationPath.append(NavigationDestination.LoginView)
            }
        }
        .onChange(of:selectedTab) {
            
            print("Selected tab = ", selectedTab)
            
            if selectedTab == 0 {
                rankingViewModel.fecthRanking()
            }
        }
    }
}


