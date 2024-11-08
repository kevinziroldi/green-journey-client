import Foundation
import SwiftData

@Model
class User: Codable {
    var userID: Int?
    var firstName: String
    var lastName: String
    var birthDate: Date?
    var gender: String?
    var firebaseUID: String
    var zipCode: Int?
    var streetName: String?
    var houseNumber: Int?
    var city: String?
    
    init(userID: Int? = nil, firstName: String, lastName: String, birthDate: Date? = nil, gender: String? = nil, firebaseUID: String, zipCode: Int? = nil, streetName: String? = nil, houseNumber: Int? = nil, city: String? = nil) {
        self.firebaseUID = firebaseUID
        self.firstName = firstName
        self.lastName = lastName
    }
    
    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case firstName = "first_name"
        case lastName = "last_name"
        case birthDate = "birth_date"
        case gender = "gender"
        case firebaseUID = "firebase_uid"
        case zipCode = "zip_code"
        case streetName = "street_name"
        case houseNumber = "house_number"
        case city = "city"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userID = try container.decode(Int.self, forKey: .userID)
        self.firstName = try container.decode(String.self, forKey: .firstName)
        self.lastName = try container.decode(String.self, forKey: .lastName)
        self.birthDate = try container.decode(Date.self, forKey: .birthDate)
        self.gender = try container.decode(String.self, forKey: .gender)
        self.firebaseUID = try container.decode(String.self, forKey: .firebaseUID)
        self.zipCode = try container.decode(Int.self, forKey: .zipCode)
        self.streetName = try container.decode(String.self, forKey: .streetName)
        self.houseNumber = try container.decode(Int.self, forKey: .houseNumber)
        self.city = try container.decode(String.self, forKey: .city)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userID, forKey: .userID)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(birthDate, forKey: .birthDate)
        try container.encode(gender, forKey: .gender)
        try container.encode(firebaseUID, forKey: .firebaseUID)
        try container.encode(zipCode, forKey: .zipCode)
        try container.encode(streetName, forKey: .streetName)
        try container.encode(houseNumber, forKey: .houseNumber)
        try container.encode(city, forKey: .city)
    }
}
