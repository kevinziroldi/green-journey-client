import Combine
import FirebaseAuth
import SwiftData
import SwiftUI

class MainViewModel: ObservableObject {
    var modelContext: ModelContext
    private var cancellables = Set<AnyCancellable>()
    
    @Published var isDataLoaded: Bool = false
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func checkUserLogged() -> Bool {
        do {
            let users = try modelContext.fetch(FetchDescriptor<User>())
            if users.first != nil {
                return true
            }
        }catch {
            print("Error interacting with SwiftData")
        }
        
        return false
    }
}

extension Bool {
    init(_ int: Int) {
        if int == 1{
            self = true
        }
        self = false
    }
}
