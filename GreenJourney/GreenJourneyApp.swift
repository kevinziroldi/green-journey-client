//
//  GreenJourneyApp.swift
//  GreenJourney
//
//  Created by Kevin Ziroldi on 25/09/24.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    print("Firebase configurato correttamente: \(FirebaseApp.app() != nil)")
    return true
  }
}

@main
struct GreenJourneyApp: App {
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            if isLoggedIn {
                MainView() // Schermata principale
            } else {
                LoginView() // Schermata di login
            }
        }
    }
}
