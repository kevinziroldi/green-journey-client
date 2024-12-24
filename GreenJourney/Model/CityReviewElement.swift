class CityReviewElement: Codable {
    var reviews: [Review]
    var averageLocalTransportRating: Float64
    var averageGreenSpacesRating: Float64
    var averageWasteBinsRating: Float64

    init(reviews: [Review], averageLocalTransportRating: Float64, averageGreenSpacesRating: Float64, averageWasteBinsRating: Float64) {
        self.reviews = reviews
        self.averageLocalTransportRating = averageLocalTransportRating
        self.averageGreenSpacesRating = averageGreenSpacesRating
        self.averageWasteBinsRating = averageWasteBinsRating
    }
    
    init() {
        self.reviews = []
        self.averageLocalTransportRating = 0.0
        self.averageGreenSpacesRating = 0.0
        self.averageWasteBinsRating = 0.0
    }
    
    enum CodingKeys: String, CodingKey {
        case reviews = "reviews"
        case averageLocalTransportRating = "average_local_transport_rating"
        case averageGreenSpacesRating = "average_green_spaces_rating"
        case averageWasteBinsRating = "average_waste_bins_rating"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.reviews = try container.decode([Review].self, forKey: .reviews)
        self.averageLocalTransportRating = try container.decode(Float64.self, forKey: .averageLocalTransportRating)
        self.averageGreenSpacesRating = try container.decode(Float64.self, forKey: .averageGreenSpacesRating)
        self.averageWasteBinsRating = try container.decode(Float64.self, forKey: .averageWasteBinsRating)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(reviews, forKey: .reviews)

        try container.encode(averageLocalTransportRating, forKey: .averageLocalTransportRating)
        try container.encode(averageGreenSpacesRating, forKey: .averageGreenSpacesRating)
        try container.encode(averageWasteBinsRating, forKey: .averageWasteBinsRating)
    }
    
    func getLastReviews() -> [Review] {
        return reviews.suffix(5)
    }
    func getAverageRating() -> Float64 {
        return (averageWasteBinsRating + averageGreenSpacesRating + averageLocalTransportRating)/3
    }
}
