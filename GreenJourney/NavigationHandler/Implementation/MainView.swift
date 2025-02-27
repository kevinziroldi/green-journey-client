import SwiftData
import SwiftUI

struct MainView: View {
    private var modelContext: ModelContext
    @State var navigationPath: NavigationPath = NavigationPath()
    private var serverService: ServerServiceProtocol
    private var firebaseAuthService: FirebaseAuthServiceProtocol
    
    @State private var selectedTab: TabViewElement = TabViewElement.SearchTravel
    @Query var users: [User]
    
    private var viewModel: MyTravelsViewModel
    
    init(modelContext: ModelContext, serverService: ServerServiceProtocol, firebaseAuthService: FirebaseAuthServiceProtocol) {
        self.modelContext = modelContext
        self.viewModel = MyTravelsViewModel(modelContext: modelContext, serverService: serverService)
        self.serverService = serverService
        self.firebaseAuthService = firebaseAuthService
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            TabView(selection: $selectedTab) {
                if users.first != nil {
                    RankingView(modelContext: modelContext, navigationPath: $navigationPath, serverService: serverService, firebaseAuthService: firebaseAuthService)
                        .tabItem {
                            Label("Ranking", systemImage: "trophy")
                                .accessibilityElement(children: .contain)
                                .accessibilityIdentifier("rankingTabViewElement")
                        }
                        .tag(TabViewElement.Ranking)
                    
                    CitiesReviewsView(modelContext: modelContext, navigationPath: $navigationPath, serverService: serverService, firebaseAuthService: firebaseAuthService)
                        .tabItem {
                            Label("Reviews", systemImage: "star.fill")
                                .accessibilityElement(children: .contain)
                                .accessibilityIdentifier("citiesReviewsTabViewElement")
                        }
                        .tag(TabViewElement.Reviews)
                    
                    TravelSearchView(modelContext: modelContext, navigationPath: $navigationPath, serverService: serverService, firebaseAuthService: firebaseAuthService)
                        .tabItem {
                            Label("From-To", systemImage: "location")
                                .accessibilityElement(children: .contain)
                                .accessibilityIdentifier("travelSearchTabViewElement")
                        }
                        .tag(TabViewElement.SearchTravel)
                    
                    MyTravelsView(modelContext: modelContext, navigationPath: $navigationPath, serverService: serverService, firebaseAuthService: firebaseAuthService)
                        .tabItem {
                            Label("My travels", systemImage: "airplane")
                                .accessibilityElement(children: .contain)
                                .accessibilityIdentifier("myTravelsTabViewElement")
                        }
                        .tag(TabViewElement.MyTravels)
                    
                    DashboardView(modelContext: modelContext, navigationPath: $navigationPath, serverService: serverService, firebaseAuthService: firebaseAuthService)
                        .tabItem {
                            Label("Dashboard", systemImage: "house")
                                .accessibilityElement(children: .contain)
                                .accessibilityIdentifier("dashboardTabViewElement")
                        }
                        .tag(TabViewElement.Dashboard)
                }else {
                    LoginView(modelContext: modelContext, navigationPath: $navigationPath, serverService: serverService, firebaseAuthService: firebaseAuthService)
                        .onAppear() {
                            // reset tab after logout+login
                            selectedTab = .SearchTravel
                        }
                        .onDisappear() {
                            // get travels from server
                            Task {
                                await viewModel.getUserTravels()
                            }
                        }
                }
            }
            .navigationDestination(for: NavigationDestination.self) { destination in
                switch destination {
                case .LoginView:
                    LoginView(modelContext: modelContext, navigationPath: $navigationPath, serverService: serverService, firebaseAuthService: firebaseAuthService)
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
                case .AllReviewsView(let viewModel):
                    AllReviewsView(viewModel: viewModel, navigationPath: $navigationPath)
                }
            }
        }.onAppear() {
            // get travels from server
            Task {
                await viewModel.getUserTravels()
            }
        }
    }
}
