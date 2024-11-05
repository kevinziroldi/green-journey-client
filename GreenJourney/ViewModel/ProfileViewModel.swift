import Foundation

class ProfileViewModel: ObservableObject {
    @Published var user: User? //possibile che basti lo userID
    let userID: Int
    
    func getUserByID (forUserId userId: Int) {
        
    }
    
    init(userID: Int) {
        self.userID = userID
    }
}
