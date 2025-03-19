class CityReviewElement: Codable {
    var reviews: [Review]
    var averageLocalTransportRating: Float64
    var averageGreenSpacesRating: Float64
    var averageWasteBinsRating: Float64
    var hasPrevious: Bool
    var hasNext: Bool
    var numReviews: Int
    
    init() {
        self.reviews = []
        self.averageLocalTransportRating = 0.0
        self.averageGreenSpacesRating = 0.0
        self.averageWasteBinsRating = 0.0
        self.hasPrevious = false
        self.hasNext = false
        self.numReviews = 0
    }
    
    init(reviews: [Review], averageLocalTransportRating: Float64, averageGreenSpacesRating: Float64, averageWasteBinsRating: Float64, hasPrevious: Bool, hasNext: Bool, numReviews: Int) {
        self.reviews = reviews
        self.averageLocalTransportRating = averageLocalTransportRating
        self.averageGreenSpacesRating = averageGreenSpacesRating
        self.averageWasteBinsRating = averageWasteBinsRating
        self.hasPrevious = hasPrevious
        self.hasNext = hasNext
        self.numReviews = numReviews
    }
    
    enum CodingKeys: String, CodingKey {
        case reviews = "reviews"
        case averageLocalTransportRating = "average_local_transport_rating"
        case averageGreenSpacesRating = "average_green_spaces_rating"
        case averageWasteBinsRating = "average_waste_bins_rating"
        case hasPrevious = "has_previous"
        case hasNext = "has_next"
        case numReviews = "num_reviews"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.reviews = try container.decode([Review].self, forKey: .reviews)
        self.averageLocalTransportRating = try container.decode(Float64.self, forKey: .averageLocalTransportRating)
        self.averageGreenSpacesRating = try container.decode(Float64.self, forKey: .averageGreenSpacesRating)
        self.averageWasteBinsRating = try container.decode(Float64.self, forKey: .averageWasteBinsRating)
        self.hasPrevious = try container.decode(Bool.self, forKey: .hasPrevious)
        self.hasNext = try container.decode(Bool.self, forKey: .hasNext)
        self.numReviews = try container.decode(Int.self, forKey: .numReviews)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(reviews, forKey: .reviews)
        try container.encode(averageLocalTransportRating, forKey: .averageLocalTransportRating)
        try container.encode(averageGreenSpacesRating, forKey: .averageGreenSpacesRating)
        try container.encode(averageWasteBinsRating, forKey: .averageWasteBinsRating)
        try container.encode(hasPrevious, forKey: .hasPrevious)
        try container.encode(hasNext, forKey: .hasNext)
        try container.encode(numReviews, forKey: .numReviews)
    }
    
    func getFirstReviews(num: Int) -> [Review] {
        return Array(reviews.prefix(num))
    }
    func getAverageRating() -> Float64 {
        return (averageWasteBinsRating + averageGreenSpacesRating + averageLocalTransportRating)/3
    }
}
