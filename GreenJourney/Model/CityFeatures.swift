import Foundation
import SwiftData

@Model
class CityFeatures {
    var id: Int64
    var iata: String
    var countryCode: String
    var cityName: String
    var countryName: String
    var population: Double
    var capital: Bool
    var averageTemperature: Double
    var continent: String
    var livingCost: Double
    var travelConnectivity: Double
    var safety: Double
    var healthcare: Double
    var education: Double
    var economy: Double
    var internetAccess: Double
    var outdoors: Double
    
    init(id: Int64, iata: String, countryCode: String, cityName: String, countryName: String, population: Double, capital: Bool, averageTemperature: Double, continent: String, livingCost: Double, travelConnectivity: Double, safety: Double, healthcare: Double, education: Double, economy: Double, internetAccess: Double, outdoors: Double) {
        self.id = id
        self.iata = iata
        self.countryCode = countryCode
        self.cityName = cityName
        self.countryName = countryName
        self.population = population
        self.capital = capital
        self.averageTemperature = averageTemperature
        self.continent = continent
        self.livingCost = livingCost
        self.travelConnectivity = travelConnectivity
        self.safety = safety
        self.healthcare = healthcare
        self.education = education
        self.economy = economy
        self.internetAccess = internetAccess
        self.outdoors = outdoors
    }
}
