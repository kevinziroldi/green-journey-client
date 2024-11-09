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
    
    var body: some Scene {
        WindowGroup {
            MainView(modelContext: persistenceController.container.mainContext)
        }
        .modelContainer(persistenceController.container)
        // make persistence controller available to all views
    }
}


