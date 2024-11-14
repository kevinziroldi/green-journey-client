import SwiftUI
import SwiftData

class PersistenceController {
    static let shared = PersistenceController()
    let container: ModelContainer

    init() {
        // specify the model types you want to persist
        container = try! ModelContainer(for: User.self, Travel.self, Segment.self, CityDataset.self)
    }
}

