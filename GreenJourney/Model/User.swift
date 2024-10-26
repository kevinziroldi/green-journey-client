import Foundation

class User: Decodable{
    var id: Int?
    var firstName: String?
    var lastname: String?
    var birthDate: Date.FormatStyle.DateStyle?
    var gender: String?
    var firebaseUID: String
    var zipCode: Int?
    var streetName: String?
    var houseNumber: Int?
    var city: String?
    
    init(firebaseUID: String) {
        self.firebaseUID = firebaseUID
    }
}
