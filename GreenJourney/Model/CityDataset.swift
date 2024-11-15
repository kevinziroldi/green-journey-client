import Foundation
import SwiftData

@Model
class CityDataset {
    var id: Int64
    var city: String
    var country: String
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
    
    init(id: Int64, city: String, country: String, population: Double, capital: Bool, averageTemperature: Double, continent: String, livingCost: Double, travelConnectivity: Double, safety: Double, healthcare: Double, education: Double, economy: Double, internetAccess: Double, outdoors: Double) {
        self.id = id
        self.city = city
        self.country = country
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
