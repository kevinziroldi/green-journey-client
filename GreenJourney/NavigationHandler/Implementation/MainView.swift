import FirebaseAuth
import SwiftData
import SwiftUI

struct MainView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    private var modelContext: ModelContext
    @State var navigationPath: NavigationPath = NavigationPath()
    private var serverService: ServerServiceProtocol
    private var firebaseAuthService: FirebaseAuthServiceProtocol
    @Query var users: [User]
    private var viewModel: MyTravelsViewModel
    
    // tab for NavigationStack (iPhone)
    @State private var selectedTab: TabViewElement = TabViewElement.SearchTravel
    
    // tab for NavigationSplitView (iPad)
    @State private var navigationSplitViewElement: TabViewElement? = TabViewElement.SearchTravel
    @State private var visibility: NavigationSplitViewVisibility = .detailOnly
    
    init(modelContext: ModelContext, serverService: ServerServiceProtocol, firebaseAuthService: FirebaseAuthServiceProtocol) {
        self.modelContext = modelContext
        self.viewModel = MyTravelsViewModel(modelContext: modelContext, serverService: serverService)
        self.serverService = serverService
        self.firebaseAuthService = firebaseAuthService
    }
    
    var body: some View {
        if horizontalSizeClass == .compact {
            // iOS
            
            if users.first != nil {
                NavigationStack(path: $navigationPath) {
                    TabView(selection: $selectedTab) {
                        RankingView(modelContext: modelContext, navigationPath: $navigationPath, serverService: serverService, firebaseAuthService: firebaseAuthService)
                            .tabItem {TabItemView(tabElement: TabViewElement.Ranking)}
                            .tag(TabViewElement.Ranking)
                        
                        CitiesReviewsView(modelContext: modelContext, navigationPath: $navigationPath, serverService: serverService, firebaseAuthService: firebaseAuthService)
                            .tabItem {TabItemView(tabElement: TabViewElement.Reviews)}
                            .tag(TabViewElement.Reviews)
                        
                        TravelSearchView(modelContext: modelContext, navigationPath: $navigationPath, serverService: serverService, firebaseAuthService: firebaseAuthService, navigationSplitViewVisibility: $visibility)
                            .tabItem {TabItemView(tabElement: TabViewElement.SearchTravel)}
                            .tag(TabViewElement.SearchTravel)
                        
                        MyTravelsView(modelContext: modelContext, navigationPath: $navigationPath, serverService: serverService, firebaseAuthService: firebaseAuthService)
                            .tabItem {TabItemView(tabElement: TabViewElement.MyTravels)}
                            .tag(TabViewElement.MyTravels)
                        
                        DashboardView(modelContext: modelContext, navigationPath: $navigationPath, serverService: serverService, firebaseAuthService: firebaseAuthService)
                            .tabItem {TabItemView(tabElement: TabViewElement.Dashboard)}
                            .tag(TabViewElement.Dashboard)
                    }
                    .navigationDestination(for: NavigationDestination.self) { destination in
                        destinationView(for: destination)
                    }
                }
                .onAppear {
                    if users.first != nil {
                        Task { await viewModel.getUserTravels() }
                    }
                }
            } else {
                NavigationStack(path: $navigationPath) {
                    LoginView(modelContext: modelContext, navigationPath: $navigationPath, serverService: serverService, firebaseAuthService: firebaseAuthService)
                        .navigationDestination(for: NavigationDestination.self) { destination in
                            destinationView(for: destination)
                        }
                        .onDisappear {
                            // reset selected tab
                            selectedTab = .SearchTravel
                            
                            // get travels from server
                            Task {
                                await viewModel.getUserTravels()
                            }
                        }
                }
            }
        } else {
            // iPadOS
            
            if users.first != nil {
                NavigationSplitView(columnVisibility: $visibility) {
                    List(selection: $navigationSplitViewElement) {
                        Section {
                            Label(TabViewElement.UserPreferences.title, systemImage: TabViewElement.UserPreferences.systemImage)
                                .overlay(Color.clear.accessibilityIdentifier(TabViewElement.UserPreferences.accessibilityIdentifier))
                                .tag(TabViewElement.UserPreferences)
                        }
                        Spacer()
                        Section {
                            ForEach(TabViewElement.allCases.filter { $0 != .UserPreferences }, id: \.self) { element in
                                Label(element.title, systemImage: element.systemImage)
                                    .overlay(Color.clear.accessibilityIdentifier(element.accessibilityIdentifier))
                                    .tag(element)
                            }
                        }
                    }
                } detail: {
                    NavigationStack(path: $navigationPath) {
                        Group {
                            switch navigationSplitViewElement {
                            case .Ranking:
                                RankingView(modelContext: modelContext, navigationPath: $navigationPath, serverService: serverService, firebaseAuthService: firebaseAuthService)
                            case .Reviews:
                                CitiesReviewsView(modelContext: modelContext, navigationPath: $navigationPath, serverService: serverService, firebaseAuthService: firebaseAuthService)
                            case .SearchTravel:
                                TravelSearchView(modelContext: modelContext, navigationPath: $navigationPath, serverService: serverService, firebaseAuthService: firebaseAuthService, navigationSplitViewVisibility: $visibility)
                            case .MyTravels:
                                MyTravelsView(modelContext: modelContext, navigationPath: $navigationPath, serverService: serverService, firebaseAuthService: firebaseAuthService)
                            case .Dashboard:
                                DashboardView(modelContext: modelContext, navigationPath: $navigationPath, serverService: serverService, firebaseAuthService: firebaseAuthService)
                            case .UserPreferences:
                                UserPreferencesView(modelContext: modelContext, navigationPath: $navigationPath, serverService: serverService, firebaseAuthService: firebaseAuthService)
                            case nil:
                                // never happens, but optional needed for selection
                                EmptyView()
                            }
                        }
                        .navigationDestination(for: NavigationDestination.self) { destination in
                            destinationView(for: destination)
                        }
                    }
                    .onAppear {
                        Task { await viewModel.getUserTravels() }
                    }
                }
            } else {
                // show login view
                NavigationStack(path: $navigationPath) {
                    LoginView(modelContext: modelContext, navigationPath: $navigationPath, serverService: serverService, firebaseAuthService: firebaseAuthService)
                        .navigationDestination(for: NavigationDestination.self) { destination in
                            destinationView(for: destination)
                        }
                        .onAppear() {
                            // reset tab after logout+login
                            navigationSplitViewElement = .SearchTravel
                        }
                        .onDisappear() {
                            // get travels from server
                            Task {
                                await viewModel.getUserTravels()
                            }
                        }
                }
            }
        }
    }
    
    @ViewBuilder
    private func destinationView(for destination: NavigationDestination) -> some View {
        switch destination {
        case .LoginView:
            LoginView(modelContext: modelContext, navigationPath: $navigationPath, serverService: serverService, firebaseAuthService: firebaseAuthService)
                .transition(.opacity.animation(.easeInOut(duration: 0.2)))
        case .SignupView(let viewModel):
            SignUpView(viewModel: viewModel, navigationPath: $navigationPath)
        case .EmailVerificationView(let viewModel):
            EmailVerificationView(viewModel: viewModel, navigationPath: $navigationPath)
        case .OutwardOptionsView(let departure, let arrival, let viewModel):
            OutwardOptionsView(departure: departure, arrival: arrival, viewModel: viewModel, navigationPath: $navigationPath)
        case .ReturnOptionsView(let departure, let arrival, let viewModel):
            ReturnOptionsView(departure: departure, arrival: arrival, viewModel: viewModel, navigationPath: $navigationPath)
        case .OptionDetailsView(let departure, let arrival, let option, let viewModel):
            OptionDetailsView(departure: departure, arrival: arrival, option: option, viewModel: viewModel, navigationPath: $navigationPath)
        case .CityReviewsDetailsView(let viewModel):
            CityReviewsDetailsView(viewModel: viewModel, navigationPath: $navigationPath)
        case .TravelDetailsView(let viewModel):
            TravelDetailsView(viewModel: viewModel, modelContext: modelContext, navigationPath: $navigationPath, serverService: serverService, firebaseAuthService: firebaseAuthService)
        case .AllReviewsView(let viewModel):
            AllReviewsView(viewModel: viewModel, navigationPath: $navigationPath)
        case .UserPreferencesView:
            UserPreferencesView(modelContext: modelContext, navigationPath: $navigationPath, serverService: serverService, firebaseAuthService: firebaseAuthService)
        case .Co2DetailsView(let viewModel):
            Co2DetailsView(viewModel: viewModel)
        case .WorldExplorationView(let viewModel):
            WorldExplorationView(viewModel: viewModel)
        case .GeneralDetailsView(let viewModel):
            GeneralDetailsView(viewModel: viewModel)
        case .RankingLeaderBoardView(let viewModel, let title, let leaderboardType):
            RankingLeaderBoardView(viewModel: viewModel, navigationPath: $navigationPath, title: title, leaderboardType: leaderboardType)
        case .UserDetailsRankingView(let viewModel, let user):
            UserDetailsRankingView(viewModel: viewModel, user: user)
        }
    }
}

/*
extension Auth {
    static func awaitCurrentUser(timeout: TimeInterval = 0.00001) async -> FirebaseAuth.User? {
        await withCheckedContinuation { cont in
            
            var isResumed = false
 
            var handle: AuthStateDidChangeListenerHandle?
            handle = Auth.auth().addStateDidChangeListener { _, user in
                if let u = user {
                    if let handle = handle {
                        Auth.auth().removeStateDidChangeListener(handle)
                    }
                    print("USER ", u)
                    guard !isResumed else { return }
                    isResumed = true
                    cont.resume(returning: u)
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + timeout) {
                guard !isResumed else {
                    print("already resumed")
                    return
                }
                isResumed = true
                
                print("NO FIREBASE USER")
                
                //Auth.auth().removeStateDidChangeListener(handle!)
                cont.resume(returning: nil)
            }
        }
    }
}
*/

struct TabItemView: View {
    var tabElement: TabViewElement
    
    var body: some View {
        Label(tabElement.title, systemImage: tabElement.systemImage)
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier(tabElement.accessibilityIdentifier)
    }
}
