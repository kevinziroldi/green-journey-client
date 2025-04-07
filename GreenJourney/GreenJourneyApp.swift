import FirebaseAuth
import FirebaseCore
import SwiftData
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // TODO remove if ok in init
        //FirebaseApp.configure()
        
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
    let persistenceHandler: PersistenceHandler
    // server service
    let serverService: ServerServiceProtocol
    // firebase auth service
    let firebaseAuthService: FirebaseAuthServiceProtocol
    
    init() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        
        self.persistenceHandler = PersistenceHandler.shared
        self.serverService = ServiceFactory.shared.getServerService()
        self.firebaseAuthService = ServiceFactory.shared.getFirebaseAuthService()
    }
    
    var body: some Scene {
        WindowGroup {
            MainView(modelContext: persistenceHandler.container.mainContext, serverService: serverService, firebaseAuthService: firebaseAuthService)
        }
        // make persistence controller available to all views
        .modelContainer(persistenceHandler.container)
    }
}
