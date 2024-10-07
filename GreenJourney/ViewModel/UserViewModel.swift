import Foundation

class ProfileViewModel: ObservableObject {
    @Published var user: User? //possibile che basti lo userID
    let userID: Int
    
    func getUserByID (forUserId userId: Int) {
        guard let url = URL(string: "http://localhost:8080/getUserById?userID=\(userID)") else {
            //invalid url
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                //error occurred
            }
            
            guard let data = data else {
                //no data received
                return
            }
            
            do {
                let user = try JSONDecoder().decode(User.self, from: data)
            } catch {
                //error in decoding data
            }
        }
        task.resume()
    }
    
    init(userID: Int) {
        self.userID = userID
    }
}
