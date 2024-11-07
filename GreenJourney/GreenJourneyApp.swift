import SwiftUI
import FirebaseCore
import FirebaseAuth

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
    
    var body: some Scene {
        WindowGroup {
            LoginView()
        }
        .modelContainer(persistenceController.container)
        // make persistence controller available to all views
    }
}
