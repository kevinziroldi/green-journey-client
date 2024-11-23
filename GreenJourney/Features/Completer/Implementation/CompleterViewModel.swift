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
    
    init(modelContext: ModelContext, searchText: String) {
        self.modelContext = modelContext
        self.searchText = searchText
        self.continent = findContinent()
        search()
    }
    
    private func search() {
        guard !searchText.isEmpty else {
            suggestions = []
            return
        }
        
        var fetchRequest = FetchDescriptor<CityCompleterDataset>(
            predicate: #Predicate { cityCompleter in
                cityCompleter.city.localizedStandardContains(searchText)
            })
        fetchRequest.fetchLimit = 40
        
        do {
            let result = try modelContext.fetch(fetchRequest)
            let sortedResults = result.sorted { city1, city2 in
                    
                let city1Score = matchScore(for: city1, query: searchText)
                let city2Score = matchScore(for: city2, query: searchText)
                    
                    // Ordinamento decrescente per punteggio
                    if city1Score != city2Score {
                        return city1Score > city2Score
                    }
                    
                    // Fallback a ordinamento alfabetico
                    return city1.city.localizedStandardCompare(city2.city) == .orderedAscending
                }
            suggestions = Array(sortedResults.prefix(10)) // Salva i risultati trovati
            } catch {
            print("Errore durante il fetch: \(error)")
        }
    }
    
    
    // Funzione che assegna un punteggio di pertinenza
    private func matchScore(for city: CityCompleterDataset, query: String) -> Int {
        var score = 0
        if city.continent == continent {
            score += 5
        }
        if city.city == query {
           score += 8
        } else {
            if city.city.hasPrefix(query) {
                score += 5
            }
            else {
                if city.city.contains(query) {
                    score += 3
                }
            }
        }
        return score
    }
    
    private func findContinent() -> String {
        guard let regionCode = Locale.current.region?.identifier else {
                return "Europe"
            }
            
            // Costruisci il FetchDescriptor con un Predicate valido
            var fetchDescriptor = FetchDescriptor<CityCompleterDataset>(
                predicate: #Predicate<CityCompleterDataset> {
                    $0.countryCode == regionCode }
            )
            fetchDescriptor.fetchLimit = 1
            
            do {
                let continent = try modelContext.fetch(fetchDescriptor).first?.continent ?? "Europe"
                return continent
            } catch {
                // Gestione errori
                print("Error while finding continent: \(error.localizedDescription)")
                return ""
            }
        
    }
}
