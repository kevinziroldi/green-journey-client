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
    @StateObject private var authenticationViewModel = AuthenticationViewModel(modelContext: PersistenceController.shared.container.mainContext)
    @StateObject private var citiesReviewsViewModel = CitiesReviewsViewModel(modelContext: PersistenceController.shared.container.mainContext)
    @StateObject private var completerViewModel: CompleterViewModel = CompleterViewModel(modelContext: PersistenceController.shared.container.mainContext)
    @StateObject private var dashboardViewModel: DashboardViewModel = DashboardViewModel()
    @StateObject private var destinationPredictionViewModel: DestinationPredictionViewModel = DestinationPredictionViewModel(modelContext: PersistenceController.shared.container.mainContext)
    @StateObject private var myTravelsViewModel: MyTravelsViewModel = MyTravelsViewModel(modelContext: PersistenceController.shared.container.mainContext)
    @StateObject private var rankingViewModel: RankingViewModel = RankingViewModel(modelContext: PersistenceController.shared.container.mainContext)
    @StateObject private var travelSearchViewModel: TravelSearchViewModel = TravelSearchViewModel(modelContext: PersistenceController.shared.container.mainContext)
    @StateObject private var userPreferencesViewModel: UserPreferencesViewModel = UserPreferencesViewModel(modelContext: PersistenceController.shared.container.mainContext)
    @StateObject private var mainViewModel: MainViewModel = MainViewModel(modelContext: PersistenceController.shared.container.mainContext)

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


