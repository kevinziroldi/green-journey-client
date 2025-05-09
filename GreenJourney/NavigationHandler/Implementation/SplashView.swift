import FirebaseAuth
import Foundation
import SwiftData
import SwiftUI

struct SplashView: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme

    var modelContext: ModelContext
    var serverService: ServerServiceProtocol
    var firebaseAuthService: FirebaseAuthServiceProtocol

    @State private var isReady: Bool = false
    
    var body: some View {
        if isReady {
            MainView(modelContext: modelContext, serverService: serverService, firebaseAuthService: firebaseAuthService)
        } else {
            ZStack {
                if colorScheme == .dark {
                    AppColors.backColorDark
                } else {
                    Color(.systemBackground)
                }
                
                Image("app_logo_splash_view")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
            }
            .ignoresSafeArea()
            .task {
                switch ConfigReader.testMode {
                
                case .real:
                    do {
                        let users = try modelContext.fetch(FetchDescriptor<User>())
                        if users.isEmpty {
                            await MainActor.run {
                                self.isReady = true
                                return
                            }
                        }
                    } catch {
                        // check firebase current user
                    }
                    
                    let firebaseUser = await Auth.awaitCurrentUser()
                    
                    if firebaseUser == nil {
                        do {
                            let users = try modelContext.fetch(FetchDescriptor<User>())
                            for user in users {
                                modelContext.delete(user)
                            }
                            try modelContext.save()
                            print("User successfully logged out and removed from SwiftData")
                        } catch {
                            print("Error while saving context after logout")
                        }
                    }
                    
                    await MainActor.run {
                        self.isReady = true
                    }
                
                case .test:
                    await MainActor.run {
                        self.isReady = true
                    }
                }
            }
        }
    }
}

@MainActor
extension Auth {
    static func awaitCurrentUser() async -> FirebaseAuth.User? {
        return await withCheckedContinuation { cont in
            let timeout: TimeInterval = 1
            var isResumed = false
            var handle: AuthStateDidChangeListenerHandle?
            
            // check authentication
            handle = Auth.auth().addStateDidChangeListener { _, user in
                if let user = user {
                    if let handle = handle {
                        Auth.auth().removeStateDidChangeListener(handle)
                    }
                    guard !isResumed else { return }
                    isResumed = true
                    cont.resume(returning: user)
                }
            }
            
            // set timeout
            DispatchQueue.main.asyncAfter(deadline: .now() + timeout) {
                if let handle = handle {
                    Auth.auth().removeStateDidChangeListener(handle)
                }
                guard !isResumed else { return }
                isResumed = true
                cont.resume(returning: nil)
            }
        }
    }
}
