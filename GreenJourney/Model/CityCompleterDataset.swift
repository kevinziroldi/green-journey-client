import Foundation
import SwiftData

@Model
class CityCompleterDataset {
    var city: String
    var countryName: String
    var id: Int64
    var locode: String
    var countryCode: String
    
    init(city: String, countryName: String, id: Int64, locode: String, countryCode: String) {
        self.city = city
        self.countryName = countryName
        self.id = id
        self.locode = locode
        self.countryCode = countryCode
    }
}
  
