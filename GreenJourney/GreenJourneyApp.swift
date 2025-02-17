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
    let persistenceHandler = PersistenceHandler.shared
    // server service
    let serverService = ServiceFactory.shared.getServerService()
    // firebase auth service
    let firebaseAuthService = ServiceFactory.shared.getFirebaseAuthService()

    init() {
        if ProcessInfo.processInfo.arguments.contains("ui_tests") {
            let modelContext = persistenceHandler.container.mainContext
            let users = try! modelContext.fetch(FetchDescriptor<User>())
            for user in users {
                modelContext.delete(user)
            }
            try! modelContext.save()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            MainView(modelContext: persistenceHandler.container.mainContext, serverService: serverService, firebaseAuthService: firebaseAuthService)
        }
        // make persistence controller available to all views
        .modelContainer(persistenceHandler.container)
    }
}
