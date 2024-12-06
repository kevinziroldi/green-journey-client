import SwiftUI
import SwiftData

class PersistenceHandler {
    static let shared = PersistenceHandler()
    let container: ModelContainer

    init() {
        // specify the model types you want to persist
        container = try! ModelContainer(for: User.self, Travel.self, Segment.self, CityFeatures.self, CityCompleterDataset.self)
    }
}

