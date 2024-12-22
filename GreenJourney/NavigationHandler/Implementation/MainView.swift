import SwiftData
import SwiftUI

struct MainView: View {
    private var modelContext: ModelContext
    @State var navigationPath: NavigationPath = NavigationPath()
    
    @State private var selectedTab: TabViewElement = TabViewElement.SearchTravel
    @Query var users: [User]
    
    private var viewModel: MyTravelsViewModel
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.viewModel = MyTravelsViewModel(modelContext: modelContext)
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            TabView(selection: $selectedTab) {
                if users.first != nil {
                    RankingView(modelContext: modelContext, navigationPath: $navigationPath)
                        .tabItem {
                            Label("Ranking", systemImage: "star")
                        }
                        .tag(TabViewElement.Ranking)
                    
                    CitiesReviewsView(modelContext: modelContext, navigationPath: $navigationPath)
                        .tabItem {
                            Label("Reviews", systemImage: "star.fill")
                        }
                        .tag(TabViewElement.Reviews)
                    
                    TravelSearchView(modelContext: modelContext, navigationPath: $navigationPath)
                        .tabItem {
                            Label("From-To", systemImage: "location")
                        }
                        .tag(TabViewElement.SearchTravel)
                    
                    MyTravelsView(modelContext: modelContext, navigationPath: $navigationPath)
                        .tabItem {
                            Label("My travels", systemImage: "airplane")
                        }
                        .tag(TabViewElement.MyTravels)
                    
                    DashboardView(modelContext: modelContext, navigationPath: $navigationPath)
                        .tabItem {
                            Label("Dashboard", systemImage: "house")
                        }
                        .tag(TabViewElement.Dashboard)
                }else {
                    LoginView(modelContext: modelContext, navigationPath: $navigationPath)
                        .onAppear() {
                            // reset tab after logout+login
                            selectedTab = .SearchTravel
                        }
                        .onDisappear() {
                            print("Loading travels on disappear login")
                        
                            // get travels from server
                            viewModel.getUserTravels()
                        }
                }
            }
            .navigationDestination(for: NavigationDestination.self) { destination in
                switch destination {
                case .LoginView:
                    LoginView(modelContext: modelContext, navigationPath: $navigationPath)
                        .transition(.opacity.animation(.easeInOut(duration: 0.2)))
                case .SignupView(let viewModel):
                    SignUpView(viewModel: viewModel, navigationPath: $navigationPath)
                case .EmailVerificationView(let viewModel):
                    EmailVerificationView(viewModel: viewModel, navigationPath: $navigationPath)
                case .OutwardOptionsView(let viewModel):
                    OutwardOptionsView(viewModel: viewModel, navigationPath: $navigationPath)
                case .ReturnOptionsView(let viewModel):
                    ReturnOptionsView(viewModel: viewModel, navigationPath: $navigationPath)
                case .CityReviewsDetailsView(let viewModel):
                    CityReviewsDetailsView(viewModel: viewModel, navigationPath: $navigationPath)
                case .TravelDetailsView(let viewModel):
                    TravelDetailsView(viewModel: viewModel, navigationPath: $navigationPath)
                case .TravelNotDoneDetailsView(let vieModel):
                    TravelNotDoneDetailsView(viewModel: vieModel, navigationPath: $navigationPath)
                }
            }
        }.onAppear() {
            print("Loading travels onAppear navigation stack")
        
            // get travels from server
            viewModel.getUserTravels()
        }
    }
}
