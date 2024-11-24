import Foundation
import SwiftData

@Model
class CityCompleterDataset {
    var city: String
    var countryName: String
    var locode: String
    var countryCode: String
    var continent: String
    
    init(city: String, countryName: String, continent: String, locode: String, countryCode: String) {
        self.city = city
        self.countryName = countryName
        self.locode = locode
        self.countryCode = countryCode
        self.continent = continent
    }
    
    init() {
        self.city = ""
        self.countryName = ""
        self.continent = ""
        self.countryCode = ""
        self.locode = ""
    }
}
  
