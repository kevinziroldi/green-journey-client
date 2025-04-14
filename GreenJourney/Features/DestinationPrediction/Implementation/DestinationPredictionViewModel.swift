import Foundation
import SwiftData

struct CityCountry: Hashable {
    let city: String
    let country: String
}

@MainActor
class DestinationPredictionViewModel: ObservableObject {
    private var modelContext: ModelContext
    @Published var predictedCities: [CityCompleterDataset] = []
    let predictionSize: Int = 5
    private let logic: DestinationPredictionLogic
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.logic = DestinationPredictionLogic(modelContext: modelContext)
    }
    
    func getRecommendation() {
        predictedCities = logic.getRecommendation(predictionSize: predictionSize)
    }
}
