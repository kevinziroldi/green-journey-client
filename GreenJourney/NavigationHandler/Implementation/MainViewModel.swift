import Combine
import FirebaseAuth
import SwiftData
import SwiftUI

class MainViewModel: ObservableObject {
    var modelContext: ModelContext
    private var cancellables = Set<AnyCancellable>()
    
    @Published var userLogged: Bool = false
    @Published var isDataLoaded: Bool = false
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    /*
    func checkUserLogged() {
        do {
            let users = try modelContext.fetch(FetchDescriptor<User>())
            if users.first != nil {
                self.userLogged = true
            }
        }catch {
            print("Error interacting with SwiftData")
        }
        
        self.userLogged = false
    }*/
}
/*
extension Bool {
    init(_ int: Int) {
        if int == 1{
            self = true
        }
        self = false
    }
}
*/
