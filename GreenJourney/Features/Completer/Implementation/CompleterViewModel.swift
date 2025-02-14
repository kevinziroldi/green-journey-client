import Foundation
import SwiftData
import SwiftUI
import Combine

class CompleterViewModel: ObservableObject {
    var modelContext: ModelContext
    
    @Published var suggestions: [CityCompleterDataset] = []
    @Published var searchText: String {
        didSet {
            search()
        }
    }
    private var continent: String = ""
    private var country: String = ""
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.searchText = ""
        self.continent = findContinent()
        self.country = findCountry()
        search()
    }
    
    private func search() {
        guard !searchText.isEmpty else {
            suggestions = []
            return
        }
        
        var fetchRequest = FetchDescriptor<CityCompleterDataset>(
            predicate: #Predicate { cityCompleter in
                cityCompleter.cityName.localizedStandardContains(searchText)
            })
        fetchRequest.fetchLimit = 300
        
        do {
            let result = try modelContext.fetch(fetchRequest)
            
            let sortedResults = result.sorted { city1, city2 in
                let city1Score = matchScore(for: city1, query: searchText)
                let city2Score = matchScore(for: city2, query: searchText)
                //print(city1.cityName, city1.countryName, city1.continent, city1Score)
                // order by decreasing score
                if city1Score != city2Score {
                    return city1Score > city2Score
                }
                
                // alphabetical order
                return city1.cityName.localizedStandardCompare(city2.cityName) == .orderedAscending
            }
            suggestions = Array(sortedResults.prefix(10))
            for city in suggestions {
                print(city.cityName, city.countryCode, city.continent, matchScore(for: city, query: searchText))
            }
        } catch {
            print("Error during fetch: \(error)")
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
            print("Error while finding continent: \(error.localizedDescription)")
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
            return 0.3 + (Double(lowerQuery.count) / Double(lowerSource.count)) * 0.7
        }
        return 0
        
    }
}
