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
            }
        )
        
        do {
            let result = try modelContext.fetch(fetchRequest)
            suggestions = result // Salva i risultati trovati
        } catch {
            print("Errore durante il fetch: \(error)")
        }
    }
}
