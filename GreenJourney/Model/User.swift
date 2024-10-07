import Foundation

class User: Decodable{
    var id: Int
    var firstName: String
    var lastname: String
    var birthDate: Date
    var gender: String
    var firebaseUID: String
    var zipCode: Int
    var streetName: String
    var houseNumber: Int
    var city: String
    
    init(id: Int, firstName: String, lastname: String, birthDate: Date, gender: String, firebaseUID: String, zipCode: Int, streetName: String, houseNumber: Int, city: String) {
        self.id = id
        self.firstName = firstName
        self.lastname = lastname
        self.birthDate = birthDate
        self.gender = gender
        self.firebaseUID = firebaseUID
        self.zipCode = zipCode
        self.streetName = streetName
        self.houseNumber = houseNumber
        self.city = city
    }
    
}
