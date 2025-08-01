import Foundation
import SwiftData
import SwiftUI
import Combine

@MainActor
class CompleterViewModel: ObservableObject {
    private var modelContext: ModelContext
    var departure: Bool
    private var logic: DestinationPredictionLogic
    @Published var suggestions: [CityCompleterDataset] = []
    @Published var searchText: String {
        didSet {
            search()
        }
    }
    private var continent: String = ""
    private var country: String = ""
    
    init(modelContext: ModelContext, departure: Bool) {
        self.modelContext = modelContext
        self.logic = DestinationPredictionLogic(modelContext: modelContext)
        self.departure = departure
        self.searchText = ""
        self.continent = findContinent()
        self.country = findCountry()
        search()
    }
    
    private func search() {
        if searchText.isEmpty {
            if self.departure {
                suggestions = getDepartureHistory()
                
            }
            else {
                suggestions = Array(logic.getRecommendation(predictionSize: 10)).suffix(5)
            }
            return
        }
        
        let searchedTextCopy = searchText
        var fetchRequest = FetchDescriptor<CityCompleterDataset>(
            predicate: #Predicate { cityCompleter in
                cityCompleter.cityName.localizedStandardContains(searchedTextCopy)
            })
        fetchRequest.fetchLimit = 150
        
        do {
            let result = try modelContext.fetch(fetchRequest)
            
            let sortedResults = result.sorted { city1, city2 in
                let city1Score = matchScore(for: city1, query: searchText)
                let city2Score = matchScore(for: city2, query: searchText)
                // order by decreasing score
                if city1Score != city2Score {
                    return city1Score > city2Score
                }
                
                // alphabetical order
                return city1.cityName.localizedStandardCompare(city2.cityName) == .orderedAscending
            }
            suggestions = Array(sortedResults.prefix(10))
        } catch {
            print("Error during fetch")
        }
    }
    
    
    // compute score for the match
    private func matchScore(for city: CityCompleterDataset, query: String) -> Double {
        var score = 0.0
        if city.continent == self.continent {
            score += 15
        }
        if city.countryCode == self.country {
            score += 2
        }
        
        let similarityScore = stringScore(city.cityName, query)
        score += (similarityScore * 100)
        
        return score
    }
    
    private func findContinent() -> String {
        let regionCode = findCountry()
        
        var fetchDescriptor = FetchDescriptor<CityCompleterDataset>(
            predicate: #Predicate<CityCompleterDataset> {
                $0.countryCode == regionCode }
        )
        fetchDescriptor.fetchLimit = 1
        
        do {
            let continent = try modelContext.fetch(fetchDescriptor).first?.continent ?? "Europe"
            return continent
        } catch {
            print("Error while finding continent")
            return ""
        }
    }
    
    private func findCountry() -> String {
        guard let regionCode = Locale.current.region?.identifier else {
            return "Europe"
        }
        return regionCode
    }
    
    private func stringScore(_ source: String, _ query: String) -> Double {
        let lowerSource = source.lowercased()
        let lowerQuery = query.lowercased()
        var score = 0.0
        // max score for exact match
        if lowerSource == lowerQuery {
            return 1.0
        }
        
        // high score for prefix match
        if lowerSource.hasPrefix(lowerQuery) {
            return 0.6 + (Double(lowerQuery.count) / Double(lowerSource.count)) * 0.4
        }
        
        // mid score for subtring match
        if lowerSource.contains(lowerQuery) {
            score = 0.3 + (Double(lowerQuery.count) / Double(lowerSource.count)) * 0.7
        }
        return score
    }
    
    private func getDepartureHistory() -> [CityCompleterDataset] {
        var history: [CityCompleterDataset] = []
        do {
            let travels = try modelContext.fetch(FetchDescriptor<Travel>())
            let segments = try modelContext.fetch(FetchDescriptor<Segment>())
            
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
            
            for travel in travelDetailsList {
                guard let country = travel.getDepartureSegment()?.departureCountry else {continue}
                guard let city = travel.getDepartureSegment()?.departureCity else {continue}
                var fetchDescriptor = FetchDescriptor<CityCompleterDataset>(
                    predicate: #Predicate<CityCompleterDataset> {
                        $0.countryName == country &&
                        $0.cityName == city }
                )
                fetchDescriptor.fetchLimit = 1
                
                if let cityHistory = try modelContext.fetch(fetchDescriptor).first {
                    if !history.contains(cityHistory) {
                        history.append(cityHistory)
                    }
                }
            }
        }
        catch {
            print("Error retrieving travels from SwiftData")
        }
        return history
    }
}
