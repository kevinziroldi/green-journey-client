class CityReviewElement: Codable {
    var reviews: [Review]
    var averageLocalTransportRating: Float64
    var averageGreenSpacesRating: Float64
    var averageWasteBinsRating: Float64

    init() {
        self.reviews = []
        self.averageLocalTransportRating = 0.0
        self.averageGreenSpacesRating = 0.0
        self.averageWasteBinsRating = 0.0
    }
    
    init(reviews: [Review], averageLocalTransportRating: Float64, averageGreenSpacesRating: Float64, averageWasteBinsRating: Float64) {
        self.reviews = reviews
        self.averageLocalTransportRating = averageLocalTransportRating
        self.averageGreenSpacesRating = averageGreenSpacesRating
        self.averageWasteBinsRating = averageWasteBinsRating
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
    
    func getLastFiveReviews() -> [Review] {
        return reviews.suffix(5)
    }
    func getAverageRating() -> Float64 {
        return (averageWasteBinsRating + averageGreenSpacesRating + averageLocalTransportRating)/3
    }
    func addUserReview(userReview: Review) {
        self.reviews.append(userReview)
        self.averageWasteBinsRating = (self.averageWasteBinsRating + Double(userReview.wasteBinsRating)) / Double(self.reviews.count)
        self.averageLocalTransportRating = (self.averageLocalTransportRating + Double(userReview.localTransportRating)) / Double(self.reviews.count)
        self.averageGreenSpacesRating = (self.averageGreenSpacesRating + Double(userReview.greenSpacesRating)) / Double(self.reviews.count)
    }
    func deleteReviewUser(userReview: Review) {
        if let index = self.reviews.firstIndex(where: { $0.id == userReview.id }) {
            self.reviews.remove(at: index)
            
            if !self.reviews.isEmpty {
                self.averageWasteBinsRating = (self.averageWasteBinsRating - Double(userReview.wasteBinsRating)) / Double(self.reviews.count)
                self.averageLocalTransportRating = (self.averageLocalTransportRating - Double(userReview.localTransportRating)) / Double(self.reviews.count)
                self.averageGreenSpacesRating = (self.averageGreenSpacesRating - Double(userReview.greenSpacesRating)) / Double(self.reviews.count)
            }
            else {
                self.averageWasteBinsRating = 0.0
                self.averageLocalTransportRating = 0.0
                self.averageGreenSpacesRating = 0.0
            }
        }
    }
    func modifyUserReview(oldReview: Review, newReview: Review) {
        if let index = self.reviews.firstIndex(where: { $0.id == oldReview.id }) {
            self.reviews.remove(at: index)
            
            if !self.reviews.isEmpty {
                self.averageWasteBinsRating = (self.averageWasteBinsRating - Double(oldReview.wasteBinsRating)) / Double(self.reviews.count)
                self.averageLocalTransportRating = (self.averageLocalTransportRating - Double(oldReview.localTransportRating)) / Double(self.reviews.count)
                self.averageGreenSpacesRating = (self.averageGreenSpacesRating - Double(oldReview.greenSpacesRating)) / Double(self.reviews.count)
            }
            else {
                self.averageWasteBinsRating = 0.0
                self.averageLocalTransportRating = 0.0
                self.averageGreenSpacesRating = 0.0
            }
            self.addUserReview(userReview: newReview)
        }
    }
}
