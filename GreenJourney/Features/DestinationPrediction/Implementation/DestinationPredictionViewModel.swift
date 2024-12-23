import CoreML
import Foundation
import SwiftData

struct CityCountry: Hashable {
    let city: String
    let country: String
}

class DestinationPredictionViewModel: ObservableObject {
    var modelContext: ModelContext
    @Published var predictedCities: [CityCompleterDataset] = []
    let predictionSize: Int = 5
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func getRecommendation() {
        do {
            // fetch data from SwiftData
            let travels = try modelContext.fetch(FetchDescriptor<Travel>())
            let segments = try modelContext.fetch(FetchDescriptor<Segment>())
            let citiesDS = try modelContext.fetch(FetchDescriptor<CityFeatures>())
            
            // build travel details list
            let segmentsByTravelID = Dictionary(grouping: segments, by: { $0.travelID })
            let travelDetailsList = travels.compactMap { travel in
                if let travelID = travel.travelID {
                    if let travelSegments = segmentsByTravelID[travelID] {
                        return TravelDetails(travel: travel, segments: travelSegments)
                    } else {
                        return TravelDetails(travel: travel, segments: [])
                    }
                }
                return nil
            }

            // get visited cities
            var visitedCities = Set<CityCountry>()
            for travelDetails in travelDetailsList {
                if let departureSegment = travelDetails.getDepartureSegment() {
                    visitedCities.insert(CityCountry(city: departureSegment.destinationCity, country: departureSegment.destinationCountry))
                }
                if let destinationSegment = travelDetails.getDestinationSegment() {
                    visitedCities.insert(CityCountry(city: destinationSegment.destinationCity, country: destinationSegment.destinationCountry))
                }
            }
            
            // feature values
            var populationValues: [Double] = []
            var capitalValues: [Bool] = []
            var averageTemperatureValues: [Double] = []
            var continentValues: [String] = []
            var livingCostValues: [Double] = []
            var travelConnectivityValues: [Double] = []
            var safetyValues: [Double] = []
            var healthcareValues: [Double] = []
            var educationValues: [Double] = []
            var economyValues: [Double] = []
            var internetAccessValues: [Double] = []
            var outdoorsValues: [Double] = []
            
            // get cities in the dataset for visited cities (destination)
            for cityCountry in visitedCities {
                for cityDS in citiesDS {
                    if hasVisited(visitedCity: cityCountry.city, visitedCountry: cityCountry.country,
                                  cityNameDS: cityDS.cityName, countryNameDS: cityDS.countryName) {
                        populationValues.append(cityDS.population)
                        capitalValues.append(cityDS.capital)
                        averageTemperatureValues.append(cityDS.averageTemperature)
                        continentValues.append(cityDS.continent)
                        livingCostValues.append(cityDS.livingCost)
                        travelConnectivityValues.append(cityDS.travelConnectivity)
                        safetyValues.append(cityDS.safety)
                        healthcareValues.append(cityDS.healthcare)
                        educationValues.append(cityDS.education)
                        economyValues.append(cityDS.economy)
                        internetAccessValues.append(cityDS.internetAccess)
                        outdoorsValues.append(cityDS.outdoors)
                    }
                }
            }
            
            // compute feature values
            // var because I possibly need to make more predictions
            let population = calculateMedian(populationValues)
            
            var capital = false
            var numCapital = 0
            var numNotCapital = 0
            for capitalValue in capitalValues {
                if capitalValue {
                    numCapital += 1
                }else {
                    numNotCapital += 1
                }
            }
            if numCapital >= numNotCapital {
                capital = true
            }
            
            let averageTemperature = calculateMedian(averageTemperatureValues)
            
            var continentFrequency: [String: Int] = [:]
            for continent in continentValues {
                continentFrequency[continent, default: 0] += 1
            }
            
            let continent = continentFrequency.max(by: { $0.value < $1.value })?.key ?? randomContinent(citiesDS: citiesDS)
            
            let livingCost = calculateMedian(livingCostValues)
            let travelConnectivity = calculateMedian(travelConnectivityValues)
            let safety = calculateMedian(safetyValues)
            let healthcare = calculateMedian(healthcareValues)
            let education = calculateMedian(educationValues)
            let economy = calculateMedian(economyValues)
            let internetAccess = calculateMedian(internetAccessValues)
            let outdoors = calculateMedian(outdoorsValues)
            
            // use model to make a prediction
            let citiesIds = predictCities(population: population, capital: capital, averageTemperature: averageTemperature, continent: continent, livingCost: livingCost, travelConnectivity: travelConnectivity, safety: safety, healthcare: healthcare, education: education, economy: economy, internetAccess: internetAccess, outdoors: outdoors)
            
            // check which is the first non visited city
            // if all visited, return the first visited one (in time)
            for cityId in citiesIds {
                if let cityDS = citiesDS.first(where: { $0.id == cityId }) {
                    var newCity = true
                    for cityCountry in visitedCities {
                        if hasVisited(visitedCity: cityCountry.city, visitedCountry: cityCountry.country, cityNameDS: cityDS.cityName, countryNameDS: cityDS.countryName) {
                            newCity = false
                            break
                        }
                    }
                    if newCity {
                        predictedCities.append(CityCompleterDataset(city: cityDS.cityName, countryName: cityDS.countryName, iata: cityDS.iata, countryCode: cityDS.countryCode, continent: cityDS.continent))
                        
                        // return if predictionSize cities found
                        if predictedCities.count == predictionSize {
                            return
                        }
                        // else continue
                    }
                }
            }
            
            // if less than predictionSize found, check at least 1 found
            if predictedCities.count == 0 {
                // return the first predicted city (already visited)
                if let cityId = citiesIds.first {
                    if let firstCity = citiesDS.first(where: { $0.id == cityId }) {
                        predictedCities.append(CityCompleterDataset(city: firstCity.cityName, countryName: firstCity.countryName, iata: firstCity.iata, countryCode: firstCity.countryCode, continent: firstCity.continent))
                        return
                    }
                }
                
                // if not present, return a random one
                if let randomCity = randomCity(citiesDS: citiesDS) {
                    predictedCities.append(randomCity)
                    return
                }else {
                    // no real prediction, nor random city
                    print("Error getting a prediction")
                }
            } else {
                // if less than predictionSize, but > 0, return the found ones
                return
            }
        }catch {
            // no prediction will be made
            print("Error interacting with SwiftData")
            
        }
    }
    
    // hasVisited returns true if the two cities have same
    // countryName and the visited city name is a substring
    // of the city name (preceeded and followed) by
    // non-alphanumeric characters
    private func hasVisited(visitedCity: String, visitedCountry: String,
                            cityNameDS: String, countryNameDS: String) -> Bool {
        if visitedCountry == countryNameDS {
            // build regex pattern
            let regexPattern = "\\b\(NSRegularExpression.escapedPattern(for: cityNameDS))\\b"
            // verify
            if let _ = visitedCity.range(of: regexPattern, options: .regularExpression) {
                return true
            }
        }
        return false
    }
    
    private func calculateMedian(_ values: [Double]) -> Double {
        // if no values, return
        if values.isEmpty {
            return 0
        }

        // else, sort
        let sortedValues = values.sorted()
        if sortedValues.count % 2 == 0 {
            // if even, mean of the central values
            return (sortedValues[sortedValues.count / 2 - 1] + sortedValues[sortedValues.count / 2]) / 2
        } else {
            // if odd, central value
            return sortedValues[sortedValues.count / 2]
        }
    }
    
    private func randomCity(citiesDS: [CityFeatures]) -> CityCompleterDataset? {
        if let randomCity = citiesDS.randomElement() {
            return CityCompleterDataset(
                city: randomCity.cityName,
                countryName: randomCity.countryName, iata: randomCity.iata, countryCode: randomCity.countryCode, continent: randomCity.continent
            )
        }
        // if random element not found
        return nil
    }
    
    private func randomContinent(citiesDS: [CityFeatures]) -> String {
        if let randomCity = randomCity(citiesDS: citiesDS) {
            return randomCity.continent
        } else {
            // fallback
            return "Europe"
        }
    }
    
    private func predictCities(population: Double, capital: Bool, averageTemperature: Double, continent: String, livingCost: Double, travelConnectivity: Double, safety: Double, healthcare: Double, education: Double, economy: Double, internetAccess: Double, outdoors: Double) -> [Int64] {
        
        do {
            let config = MLModelConfiguration()
            let model = try GreenJourneyMLModel(configuration: config)
            let prediction = try model.prediction(
                population: population,
                capital: Int64(capital),
                average_temperature:averageTemperature,
                continent:continent,
                living_cost:livingCost,
                travel_connectivity:travelConnectivity,
                safety:safety,
                healthcare:healthcare,
                education:education,
                economy:economy,
                internet_access:internetAccess,
                outdoors:outdoors
            )
            
            let maxDepth = 30
            let cityProbabilities = prediction.idProbability
            let sortedProbabilities = cityProbabilities.sorted(by: { $0.value > $1.value })
            let topProbabilities = sortedProbabilities.prefix(maxDepth)
            var citiesId: [Int64] = []
            for probability in topProbabilities {
                citiesId.append(probability.key)
            }
            
            return citiesId
        }catch{
            return ([])
        }
    }
}

extension Int64 {
    init(_ bool: Bool) {
        if bool {
            self = 1
        }
        self = 0
    }
}
