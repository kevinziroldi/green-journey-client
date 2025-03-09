import Foundation
import SwiftData

@Model
class Review: Codable, Identifiable {
    var reviewID: Int?
    var cityID: Int?
    var userID: Int
    var reviewText: String
    var localTransportRating: Int
    var greenSpacesRating: Int
    var wasteBinsRating: Int
    var cityIata: String
    var countryCode: String
    var firstName: String
    var lastName: String
    var scoreShortDistance: Float64
    var scoreLongDistance: Float64
    var badges: [Badge]
    
    init(reviewID: Int?, cityID: Int?, userID: Int, reviewText: String, localTransportRating: Int, greenSpacesRating: Int, wasteBinsRating: Int, cityIata: String, countryCode: String, firstName: String, lastName: String, scoreShortDistance: Float64, scoreLongDistance: Float64, badges: [Badge]) {
        self.reviewID = reviewID
        self.cityID = cityID
        self.userID = userID
        self.reviewText = reviewText
        self.localTransportRating = localTransportRating
        self.greenSpacesRating = greenSpacesRating
        self.wasteBinsRating = wasteBinsRating
        self.cityIata = cityIata
        self.countryCode = countryCode
        self.firstName = firstName
        self.lastName = lastName
        self.scoreShortDistance = scoreShortDistance
        self.scoreLongDistance = scoreLongDistance
        self.badges = badges
    }
    
    enum CodingKeys: String, CodingKey {
        case reviewID = "review_id"
        case cityID = "city_id"
        case userID = "user_id"
        case reviewText = "review_text"
        case localTransportRating = "local_transport_rating"
        case greenSpacesRating = "green_spaces_rating"
        case wasteBinsRating = "waste_bins_rating"
        case cityIata = "city_iata"
        case countryCode = "country_code"
        case firstName = "first_name"
        case lastName = "last_name"
        case scoreShortDistance = "score_short_distance"
        case scoreLongDistance = "score_long_distance"
        case badges = "badges"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.reviewID = try container.decodeIfPresent(Int.self, forKey: .reviewID)
        self.cityID = try container.decode(Int.self, forKey: .cityID)
        self.userID = try container.decode(Int.self, forKey: .userID)
        self.reviewText = try container.decode(String.self, forKey: .reviewText)
        self.localTransportRating = try container.decode(Int.self, forKey: .localTransportRating)
        self.greenSpacesRating = try container.decode(Int.self, forKey: .greenSpacesRating)
        self.wasteBinsRating = try container.decode(Int.self, forKey: .wasteBinsRating)
        self.cityIata = try container.decode(String.self, forKey: .cityIata)
        self.countryCode = try container.decode(String.self, forKey: .countryCode)
        self.firstName = try container.decode(String.self, forKey: .firstName)
        self.lastName = try container.decode(String.self, forKey: .lastName)
        self.scoreShortDistance = try container.decode(Float64.self, forKey: .scoreShortDistance)
        self.scoreLongDistance = try container.decode(Float64.self, forKey: .scoreLongDistance)
        self.badges = try container.decode([Badge].self, forKey: .badges)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(reviewID, forKey: .reviewID)
        try container.encode(cityID, forKey: .cityID)
        try container.encode(userID, forKey: .userID)
        try container.encode(reviewText, forKey: .reviewText)
        try container.encode(localTransportRating, forKey: .localTransportRating)
        try container.encode(greenSpacesRating, forKey: .greenSpacesRating)
        try container.encode(wasteBinsRating, forKey: .wasteBinsRating)
        try container.encode(cityIata, forKey: .cityIata)
        try container.encode(countryCode, forKey: .countryCode)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(scoreShortDistance, forKey: .scoreShortDistance)
        try container.encode(scoreLongDistance, forKey: .scoreLongDistance)
        
        // send badges that are not base
        let filteredBadges = badges.filter {$0 != $0.baseBadge}
        try container.encode(filteredBadges, forKey: .badges)
    }
    
    func computeRating() -> Float64 {
        return Float64(wasteBinsRating + localTransportRating + greenSpacesRating) / 3
    }
}
