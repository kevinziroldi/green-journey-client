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
    private func matchScore(for city: CityCompleterDataset, query: String) -> Double {
        var score = 0.0
        if city.continent == continent {
            score += 25
        }

        let similarityScore = stringScore(city.city, query)
        score += (similarityScore * 100)
        
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
    
    private func stringScore(_ source: String, _ query: String) -> Double {
        let lowerSource = source.lowercased()
        let lowerQuery = query.lowercased()
        
        // Punteggio massimo se è un match esatto
        if lowerSource == lowerQuery {
            return 1.0
        }
        
        // Bonus alto per corrispondenza del prefisso
        if lowerSource.hasPrefix(lowerQuery) {
            return 0.8 + (Double(lowerQuery.count) / Double(lowerSource.count)) * 0.2
        }
        
        // Bonus medio per substring match
        if lowerSource.contains(lowerQuery) {
            return 0.5 + (Double(lowerQuery.count) / Double(lowerSource.count)) * 0.5
        }
        
        // Penalità basata sulla distanza tra i caratteri
        let distance = levenshteinDistance(lowerSource, lowerQuery)
        let maxLen = max(lowerSource.count, lowerQuery.count)
        return 1.0 - (Double(distance) / Double(maxLen))
    }

    private func levenshteinDistance(_ s1: String, _ s2: String) -> Int {
        let a = Array(s1)
        let b = Array(s2)
        let m = a.count
        let n = b.count
        var matrix = [[Int]](repeating: [Int](repeating: 0, count: n + 1), count: m + 1)
        
        for i in 0...m {
            matrix[i][0] = i
        }
        for j in 0...n {
            matrix[0][j] = j
        }
        
        for i in 1...m {
            for j in 1...n {
                let cost = a[i - 1] == b[j - 1] ? 0 : 1
                matrix[i][j] = min(matrix[i - 1][j] + 1, min(matrix[i][j - 1] + 1, matrix[i - 1][j - 1] + cost))
            }
        }
        
        return matrix[m][n]
    }

}
