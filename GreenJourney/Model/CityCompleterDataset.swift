import Foundation
import SwiftData

@Model
class CityCompleterDataset: Identifiable {
    var id: UUID
    
    var cityName: String
    var countryName: String
    var iata: String
    var countryCode: String
    var continent: String
    
    init(city: String, countryName: String, continent: String, locode: String, countryCode: String) {
        self.id = UUID()

        self.cityName = city
        self.countryName = countryName
        self.iata = locode
        self.countryCode = countryCode
        self.continent = continent
    }
    
    init() {
        self.id = UUID()
        self.cityName = ""
        self.countryName = ""
        self.continent = ""
        self.countryCode = ""
        self.iata = ""
    }
}
  
