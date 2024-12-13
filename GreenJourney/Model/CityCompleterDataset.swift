import Foundation
import SwiftData

@Model
class CityCompleterDataset: Identifiable, Equatable {
    var cityName: String
    var countryName: String
    var iata: String
    var countryCode: String
    var continent: String
    
    init(city: String, countryName: String, iata: String, continent: String, countryCode: String) {
        self.cityName = city
        self.countryName = countryName
        self.iata = iata
        self.continent = continent
        self.countryCode = countryCode
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
  
