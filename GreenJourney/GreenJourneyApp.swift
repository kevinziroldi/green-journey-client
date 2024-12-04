import FirebaseAuth
import FirebaseCore
import SwiftData
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct GreenJourneyApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    // persistence controller for SwiftData
    let persistenceController = PersistenceController.shared
    
    // ViewModels
    @StateObject private var authenticationViewModel: AuthenticationViewModel
    @StateObject private var citiesReviewsViewModel: CitiesReviewsViewModel
    @StateObject private var completerViewModel: CompleterViewModel
    @StateObject private var dashboardViewModel: DashboardViewModel
    @StateObject private var destinationPredictionViewModel: DestinationPredictionViewModel
    @StateObject private var myTravelsViewModel: MyTravelsViewModel
    @StateObject private var rankingViewModel: RankingViewModel
    @StateObject private var travelSearchViewModel: TravelSearchViewModel
    @StateObject private var userPreferencesViewModel: UserPreferencesViewModel
    @StateObject private var mainViewModel: MainViewModel
    
    init() {
        let modelContext = persistenceController.container.mainContext
        _authenticationViewModel = StateObject(wrappedValue: AuthenticationViewModel(modelContext: modelContext))
        _citiesReviewsViewModel = StateObject(wrappedValue: CitiesReviewsViewModel(modelContext: modelContext))
        _completerViewModel = StateObject(wrappedValue: CompleterViewModel(modelContext: modelContext))
        _dashboardViewModel = StateObject(wrappedValue: DashboardViewModel())
        _destinationPredictionViewModel = StateObject(wrappedValue: DestinationPredictionViewModel(modelContext: modelContext))
        _myTravelsViewModel = StateObject(wrappedValue: MyTravelsViewModel(modelContext: modelContext))
        _rankingViewModel = StateObject(wrappedValue: RankingViewModel(modelContext: modelContext))
        _travelSearchViewModel = StateObject(wrappedValue: TravelSearchViewModel(modelContext: modelContext))
        _userPreferencesViewModel = StateObject(wrappedValue: UserPreferencesViewModel(modelContext: modelContext))
        _mainViewModel = StateObject(wrappedValue: MainViewModel(modelContext: modelContext))
    }
    
    var body: some Scene {
        WindowGroup {
            MainView(modelContext: persistenceController.container.mainContext)
                .environmentObject(authenticationViewModel)
                .environmentObject(citiesReviewsViewModel)
                .environmentObject(completerViewModel)
                .environmentObject(dashboardViewModel)
                .environmentObject(destinationPredictionViewModel)
                .environmentObject(myTravelsViewModel)
                .environmentObject(rankingViewModel)
                .environmentObject(travelSearchViewModel)
                .environmentObject(userPreferencesViewModel)
                .environmentObject(mainViewModel)
        }
        // make persistence controller available to all views
        .modelContainer(persistenceController.container)
    }
}


