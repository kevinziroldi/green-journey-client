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
            
            NavigationStack(path: $navigationPath) {
                TabView(selection: $selectedTab) {
                    if users.first != nil {
                        RankingView(modelContext: modelContext, navigationPath: $navigationPath, serverService: serverService, firebaseAuthService: firebaseAuthService)
                            .tabItem {TabItemView(tabElement: TabViewElement.Ranking)}
                            .tag(TabViewElement.Ranking)
                        
                        CitiesReviewsView(modelContext: modelContext, navigationPath: $navigationPath, serverService: serverService, firebaseAuthService: firebaseAuthService)
                            .tabItem {TabItemView(tabElement: TabViewElement.Reviews)}
                            .tag(TabViewElement.Reviews)
                        
                        TravelSearchView(modelContext: modelContext, navigationPath: $navigationPath, serverService: serverService, firebaseAuthService: firebaseAuthService)
                            .tabItem {TabItemView(tabElement: TabViewElement.SearchTravel)}
                            .tag(TabViewElement.SearchTravel)
                        
                        MyTravelsView(modelContext: modelContext, navigationPath: $navigationPath, serverService: serverService, firebaseAuthService: firebaseAuthService)
                            .tabItem {TabItemView(tabElement: TabViewElement.MyTravels)}
                            .tag(TabViewElement.MyTravels)
                        
                        DashboardView(modelContext: modelContext, navigationPath: $navigationPath, serverService: serverService, firebaseAuthService: firebaseAuthService)
                            .tabItem {TabItemView(tabElement: TabViewElement.Dashboard)}
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
                        destinationView(for: destination)
                }
            }.onAppear() {
                // get travels from server
                Task {
                    await viewModel.getUserTravels()
                }
            }
        } else {
            // iPadOS
            
            NavigationSplitView(columnVisibility: $visibility) {
                List(TabViewElement.allCases, selection: $navigationSplitViewElement) { element in
                    Label(element.title, systemImage: element.systemImage)
                        .accessibilityIdentifier(element.accessibilityIdentifier)
                }
                .listStyle(.sidebar)
            } detail: {
                NavigationStack(path: $navigationPath) {
                    Group {
                        if users.first != nil {
                            switch navigationSplitViewElement {
                            case .Ranking:
                                RankingView(modelContext: modelContext, navigationPath: $navigationPath, serverService: serverService, firebaseAuthService: firebaseAuthService)
                            case .Reviews:
                                CitiesReviewsView(modelContext: modelContext, navigationPath: $navigationPath, serverService: serverService, firebaseAuthService: firebaseAuthService)
                            case .SearchTravel:
                                TravelSearchView(modelContext: modelContext, navigationPath: $navigationPath, serverService: serverService, firebaseAuthService: firebaseAuthService)
                            case .MyTravels:
                                MyTravelsView(modelContext: modelContext, navigationPath: $navigationPath, serverService: serverService, firebaseAuthService: firebaseAuthService)
                            case .Dashboard:
                                DashboardView(modelContext: modelContext, navigationPath: $navigationPath, serverService: serverService, firebaseAuthService: firebaseAuthService)
                            case nil:
                                // never happens, but optional needed for selection
                                EmptyView()
                            }
                        } else {
                            LoginView(modelContext: modelContext, navigationPath: $navigationPath, serverService: serverService, firebaseAuthService: firebaseAuthService)
                                .onAppear() {
                                    // remove side bar 
                                    visibility = .detailOnly
                                    
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
                        destinationView(for: destination)
                    }
                }
                .onAppear {
                    Task { await viewModel.getUserTravels() }
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
        case .OutwardOptionsView(let viewModel):
            OutwardOptionsView(viewModel: viewModel, navigationPath: $navigationPath)
        case .ReturnOptionsView(let viewModel):
            ReturnOptionsView(viewModel: viewModel, navigationPath: $navigationPath)
        case .CityReviewsDetailsView(let viewModel):
            CityReviewsDetailsView(viewModel: viewModel, navigationPath: $navigationPath)
        case .TravelDetailsView(let viewModel):
            TravelDetailsView(viewModel: viewModel, modelContext: modelContext, navigationPath: $navigationPath, serverService: serverService, firebaseAuthService: firebaseAuthService)
        case .AllReviewsView(let viewModel):
            AllReviewsView(viewModel: viewModel, navigationPath: $navigationPath)
        }
    }
}

struct TabItemView: View {
    var tabElement: TabViewElement
    
    var body: some View {
        Label(tabElement.title, systemImage: tabElement.systemImage)
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier(tabElement.accessibilityIdentifier)
    }
}

