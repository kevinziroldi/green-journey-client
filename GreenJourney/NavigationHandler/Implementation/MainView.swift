/*
import SwiftData
import SwiftUI
struct MainView: View {
    @EnvironmentObject private var viewModel: MainViewModel
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab = 2
    @State var navigationPath: NavigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            // Verifica se l'utente è loggato
            if viewModel.checkUserLogged() {
                TabView(selection: $selectedTab) {
                    ForEach(TabItem.allCases, id: \.self) { item in
                        item.view(navigationPath: $navigationPath, modelContext: modelContext)
                            .tabItem {
                                Label(item.label, systemImage: item.systemImage)
                            }
                            .tag(item.rawValue)
                    }
                }
                .onAppear {
                    viewModel.loadData()
                }
                .navigationDestination(for: NavigationDestination.self) { destination in
                    handleNavigation(destination: destination)
                }
            } else {
                // Mostra la schermata di login come destinazione iniziale
                LoginView(navigationPath: $navigationPath)
                    .onAppear {
                        navigationPath.append(NavigationDestination.LoginView)
                    }
            }
        }
    }

    // Funzione per gestire le destinazioni di navigazione
    @ViewBuilder
    private func handleNavigation(destination: NavigationDestination) -> some View {
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
}

// MARK: - Tab Items Enum

enum TabItem: Int, CaseIterable {
    case ranking, reviews, travelSearch, myTravels, dashboard

    var label: String {
        switch self {
        case .ranking: return "Ranking"
        case .reviews: return "Reviews"
        case .travelSearch: return "From-To"
        case .myTravels: return "My travels"
        case .dashboard: return "Dashboard"
        }
    }

    var systemImage: String {
        switch self {
        case .ranking: return "star"
        case .reviews: return "star.fill"
        case .travelSearch: return "location"
        case .myTravels: return "airplane"
        case .dashboard: return "house"
        }
    }

    @ViewBuilder
    func view(navigationPath: Binding<NavigationPath>, modelContext: ModelContext) -> some View {
        switch self {
        case .ranking:
            RankingView(navigationPath: navigationPath)
        case .reviews:
            CitiesReviewsView(navigationPath: navigationPath)
        case .travelSearch:
            TravelSearchView(navigationPath: navigationPath)
        case .myTravels:
            MyTravelsView(modelContext: modelContext, navigationPath: navigationPath)
        case .dashboard:
            DashboardView(navigationPath: navigationPath)
        }
    }
}
*/



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
    }
}

