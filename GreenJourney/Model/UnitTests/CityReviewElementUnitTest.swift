import Foundation
import Testing

@testable import GreenJourney

struct CityReviewElementUnitTest {
    @Test
    func testEmptyInitializer() {
        let city = CityReviewElement()
        
        #expect(city.reviews.isEmpty)
        #expect(city.averageLocalTransportRating == 0)
        #expect(city.averageGreenSpacesRating == 0)
        #expect(city.averageWasteBinsRating == 0)
    }
    
    @Test
    func testInitializerWithAttributes() {
        let review = Review(
            reviewID: 1,
            cityID: 10,
            userID: 1,
            reviewText: "review text",
            localTransportRating: 1,
            greenSpacesRating: 2,
            wasteBinsRating: 3,
            cityIata: "PAR",
            countryCode: "FR",
            firstName: "John",
            lastName: "Doe"
        )
        
        let city = CityReviewElement(
            reviews: [review],
            averageLocalTransportRating: 1.0,
            averageGreenSpacesRating: 2.0,
            averageWasteBinsRating: 3.0
        )
        
        #expect(city.reviews.count == 1)
        #expect(city.reviews[0].reviewID == 1)
        #expect(city.averageLocalTransportRating == 1.0)
        #expect(city.averageGreenSpacesRating == 2.0)
        #expect(city.averageWasteBinsRating == 3.0)
    }
    
    @Test
    func testEncodingDecoding() throws {
        let review = Review(
            reviewID: 1,
            cityID: 10,
            userID: 1,
            reviewText: "review text",
            localTransportRating: 1,
            greenSpacesRating: 2,
            wasteBinsRating: 3,
            cityIata: "PAR",
            countryCode: "FR",
            firstName: "John",
            lastName: "Doe"
        )
        
        let city = CityReviewElement(
            reviews: [review],
            averageLocalTransportRating: 1.0,
            averageGreenSpacesRating: 2.0,
            averageWasteBinsRating: 3.0
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(city)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decodedCity = try decoder.decode(CityReviewElement.self, from: data)
        
        #expect(decodedCity.reviews.count == 1)
        #expect(decodedCity.reviews[0].reviewID == 1)
        #expect(decodedCity.averageLocalTransportRating == city.averageLocalTransportRating)
        #expect(decodedCity.averageGreenSpacesRating == city.averageGreenSpacesRating)
        #expect(decodedCity.averageWasteBinsRating == city.averageWasteBinsRating)
    }
    
    @Test
    func testGetLastFiveReviewsNoReview() {
        let city = CityReviewElement(
            reviews: [],
            averageLocalTransportRating: 1.0,
            averageGreenSpacesRating: 2.0,
            averageWasteBinsRating: 3.0
        )
        
        let lastReviews = city.getFirstReviews(num: 5)
        
        #expect(lastReviews.isEmpty)
    }
    
    @Test
    func testGetLastFiveReviewsLessThanFive() {
        let review = Review(
            reviewID: 1,
            cityID: 10,
            userID: 1,
            reviewText: "review text",
            localTransportRating: 1,
            greenSpacesRating: 2,
            wasteBinsRating: 3,
            cityIata: "PAR",
            countryCode: "FR",
            firstName: "John",
            lastName: "Doe"
        )
        
        let city = CityReviewElement(
            reviews: [review],
            averageLocalTransportRating: 1.0,
            averageGreenSpacesRating: 2.0,
            averageWasteBinsRating: 3.0
        )
        
        let lastReviews = city.getFirstReviews(num: 5)
        
        #expect(lastReviews.count == 1)
        #expect(lastReviews[0].reviewID == 1)
    }
    
    @Test
    func testGetLastFiveReviewsMoreThanFive() {
        let review1 = Review(
            reviewID: 1,
            cityID: 10,
            userID: 1,
            reviewText: "review text",
            localTransportRating: 1,
            greenSpacesRating: 2,
            wasteBinsRating: 3,
            cityIata: "PAR",
            countryCode: "FR",
            firstName: "John",
            lastName: "Doe"
        )
        let review2 = Review(
            reviewID: 2,
            cityID: 10,
            userID: 1,
            reviewText: "review text",
            localTransportRating: 1,
            greenSpacesRating: 2,
            wasteBinsRating: 3,
            cityIata: "PAR",
            countryCode: "FR",
            firstName: "John",
            lastName: "Doe"
        )
        let review3 = Review(
            reviewID: 3,
            cityID: 10,
            userID: 1,
            reviewText: "review text",
            localTransportRating: 1,
            greenSpacesRating: 2,
            wasteBinsRating: 3,
            cityIata: "PAR",
            countryCode: "FR",
            firstName: "John",
            lastName: "Doe"
        )
        let review4 = Review(
            reviewID: 4,
            cityID: 10,
            userID: 1,
            reviewText: "review text",
            localTransportRating: 1,
            greenSpacesRating: 2,
            wasteBinsRating: 3,
            cityIata: "PAR",
            countryCode: "FR",
            firstName: "John",
            lastName: "Doe"
        )
        let review5 = Review(
            reviewID: 5,
            cityID: 10,
            userID: 1,
            reviewText: "review text",
            localTransportRating: 1,
            greenSpacesRating: 2,
            wasteBinsRating: 3,
            cityIata: "PAR",
            countryCode: "FR",
            firstName: "John",
            lastName: "Doe"
        )
        let review6 = Review(
            reviewID: 6,
            cityID: 10,
            userID: 1,
            reviewText: "review text",
            localTransportRating: 1,
            greenSpacesRating: 2,
            wasteBinsRating: 3,
            cityIata: "PAR",
            countryCode: "FR",
            firstName: "John",
            lastName: "Doe"
        )
        
        let city = CityReviewElement(
            reviews: [review1, review2, review3, review4, review5, review6],
            averageLocalTransportRating: 1.0,
            averageGreenSpacesRating: 2.0,
            averageWasteBinsRating: 3.0
        )
        
        let lastReviews = city.getFirstReviews(num: 5)
        
        #expect(lastReviews.count == 5)
        #expect(lastReviews[0].reviewID == 2)
        #expect(lastReviews[1].reviewID == 3)
        #expect(lastReviews[2].reviewID == 4)
        #expect(lastReviews[3].reviewID == 5)
        #expect(lastReviews[4].reviewID == 6)
    }
    
    @Test
    func testGetAverageRatingInteger() {
        let city = CityReviewElement(
            reviews: [],
            averageLocalTransportRating: 1.0,
            averageGreenSpacesRating: 2.0,
            averageWasteBinsRating: 3.0
        )
        
        let average = city.getAverageRating()
        
        #expect(average == 2.0)
    }
    
    @Test
    func testGetAverageRatingFractional() {
        let city = CityReviewElement(
            reviews: [],
            averageLocalTransportRating: 1.5,
            averageGreenSpacesRating: 0.0,
            averageWasteBinsRating: 3.0
        )
        
        let average = city.getAverageRating()
        
        #expect(average == 1.5)
    }
}
