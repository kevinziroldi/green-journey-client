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
    
    init(modelContext: ModelContext, searchText: String) {
        self.modelContext = modelContext
        self.searchText = searchText
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
        fetchRequest.fetchLimit = 30
        
        do {
            let result = try modelContext.fetch(fetchRequest)
            let sortedResults = result.sorted { city1, city2 in
                    let city1Name = city1.city.lowercased()
                    let city2Name = city2.city.lowercased()
                    
                let city1Score = matchScore(for: city1Name, query: searchText)
                let city2Score = matchScore(for: city2Name, query: searchText)
                    
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
    private func matchScore(for cityName: String, query: String) -> Int {
        if cityName == query {
            return 3 // Matching esatto
        } else if cityName.hasPrefix(query) {
            return 2 // Matching per prefisso
        } else if cityName.contains(query) {
            return 1 // Matching parziale
        } else {
            return 0 // Nessun matching (non necessario se i risultati sono filtrati)
        }
    }
}
