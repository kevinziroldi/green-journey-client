import FirebaseAuth
import FirebaseCore
import SwiftData
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        // make the simulator start with software keyboard
        #if targetEnvironment(simulator)
            let setHardwareLayout = NSSelectorFromString("setHardwareLayout:")
            UITextInputMode.activeInputModes
                .filter { $0.responds(to: setHardwareLayout) }
                .forEach { $0.perform(setHardwareLayout, with: nil) }
        #endif
        return true
    }
}

@main
struct GreenJourneyApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    // persistence controller for SwiftData
    let persistenceHandler: PersistenceHandler = PersistenceHandler.shared
    // server service
    let serverService: ServerServiceProtocol = ServiceFactory.shared.getServerService()
    // firebase auth service
    let firebaseAuthService: FirebaseAuthServiceProtocol = ServiceFactory.shared.getFirebaseAuthService()
    
    var body: some Scene {
        WindowGroup {
            MainView(modelContext: persistenceHandler.container.mainContext, serverService: serverService, firebaseAuthService: firebaseAuthService)
        }
        // make persistence controller available to all views
        .modelContainer(persistenceHandler.container)
    }
}
