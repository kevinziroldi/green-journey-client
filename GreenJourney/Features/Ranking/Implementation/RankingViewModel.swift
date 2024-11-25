import Foundation

class RankingViewModel: ObservableObject {
    
    @Published var shortDistanceRanking: [User] = []
    @Published var longDistanceRanking: [User] = []
    
    
}

struct UserRanking {
    var id: Int
    var firstName: String
    var lastName: String
    var distance: Float64
    var scoreShortDistance: Float64
    var scoreLongDistance: Float64
    var totalTravelTime: Int
    var co2Emitted: Float64
    var co2Compensated: Float64
    var badges: [String]
}
