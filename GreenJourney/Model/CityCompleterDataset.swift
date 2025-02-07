import Foundation
import SwiftData

@Model
class CityCompleterDataset: Identifiable, Equatable {
    var cityName: String
    var countryName: String
    var iata: String
    var countryCode: String
    var continent: String
    
    init(existingCity: CityCompleterDataset) {
        self.cityName = existingCity.cityName
        self.countryName = existingCity.countryName
        self.iata = existingCity.iata
        self.countryCode = existingCity.countryCode
        self.continent = existingCity.continent
    }
    
    init(cityName: String, countryName: String, iata: String, countryCode: String, continent: String) {
        self.cityName = cityName
        self.countryName = countryName
        self.iata = iata
        self.countryCode = countryCode
        self.continent = continent
    }
    
    init() {
        self.cityName = ""
        self.countryName = ""
        self.continent = ""
        self.countryCode = ""
        self.iata = ""
    }
    
    static func == (lhs: CityCompleterDataset, rhs: CityCompleterDataset) -> Bool {
        return lhs.cityName == rhs.cityName &&
        lhs.countryName == rhs.countryName &&
        lhs.iata == rhs.iata &&
        lhs.countryCode == rhs.countryCode &&
        lhs.continent == rhs.continent
    }
}
  
