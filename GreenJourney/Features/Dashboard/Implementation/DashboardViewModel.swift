import Foundation
import SwiftData

class DashboardViewModel: ObservableObject {
    var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
}
