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
        self.birthDate = birthDate
        self.gender = gender
        self.firebaseUID = firebaseUID
        self.zipCode = zipCode
        self.streetName = streetName
        self.houseNumber = houseNumber
        self.city = city
        self.userID = userID
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
        self.userID = try container.decodeIfPresent(Int.self, forKey: .userID)
        self.firstName = try container.decode(String.self, forKey: .firstName)
        self.lastName = try container.decode(String.self, forKey: .lastName)
        self.firebaseUID = try container.decode(String.self, forKey: .firebaseUID)
        if let dateString = try container.decodeIfPresent(String.self, forKey: .birthDate) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            self.birthDate = dateFormatter.date(from: dateString)
        } else {
            self.birthDate = nil
        }
        self.gender = try container.decodeIfPresent(String.self, forKey: .gender)
        self.zipCode = try container.decodeIfPresent(Int.self, forKey: .zipCode)
        self.streetName = try container.decodeIfPresent(String.self, forKey: .streetName)
        self.houseNumber = try container.decodeIfPresent(Int.self, forKey: .houseNumber)
        self.city = try container.decodeIfPresent(String.self, forKey: .city)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userID, forKey: .userID)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        if let birthDate = birthDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateString = dateFormatter.string(from: birthDate)
            try container.encode(dateString, forKey: .birthDate)
        }
        try container.encode(gender, forKey: .gender)
        try container.encode(firebaseUID, forKey: .firebaseUID)
        try container.encode(zipCode, forKey: .zipCode)
        try container.encode(streetName, forKey: .streetName)
        try container.encode(houseNumber, forKey: .houseNumber)
        try container.encode(city, forKey: .city)
    }
}
