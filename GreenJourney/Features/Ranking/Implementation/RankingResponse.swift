struct RankingResponse: Decodable {
    var shortDistanceRanking: [RankingElement]
    var longDistanceRanking: [RankingElement]
    
    init() {
        self.shortDistanceRanking = []
        self.longDistanceRanking = []
    }
    
    enum CodingKeys: String, CodingKey {
        case shortDistanceRanking = "short_distance_ranking"
        case longDistanceRanking = "long_distance_ranking"
    }
}

struct RankingElement: Decodable {
    var userID: Int
    var firstName: String
    var lastName: String
    var totalDistance: Float64
    var score: Float64
    var totalDuration: Int
    var totalCo2Emitted: Float64
    var totalCo2Compensated: Float64
    var badges: [Badge]
    
    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case firstName = "first_name"
        case lastName = "last_name"
        case totalDistance = "total_distance"
        case score = "score"
        case totalDuration = "total_duration"
        case totalCo2Emitted = "total_co_2_emitted"
        case totalCo2Compensated = "total_co_2_compensated"
        case badges = "badges"
    }
}
