import Foundation
import Testing

@testable import GreenJourney

struct ReviewTest {
    @Test
    func testInitializerWithAllAttributes() {
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
            lastName: "Doe",
            scoreShortDistance: 50,
            scoreLongDistance: 100,
            badges: []
        )
        
        #expect(review.reviewID == 1)
        #expect(review.cityID == 10)
        #expect(review.userID == 1)
        #expect(review.reviewText == "review text")
        #expect(review.localTransportRating == 1)
        #expect(review.greenSpacesRating == 2)
        #expect(review.wasteBinsRating == 3)
        #expect(review.cityIata == "PAR")
        #expect(review.countryCode == "FR")
        #expect(review.firstName == "John")
        #expect(review.lastName == "Doe")
        #expect(review.scoreShortDistance == 50)
        #expect(review.scoreLongDistance == 100)
        #expect(review.badges.isEmpty)
        
    }
    
    @Test
    func testInitializerWithMainAttributes() {
        let review = Review(
            reviewID: 1,
            cityID: 10,
            userID: 1,
            reviewText: "review text",
            localTransportRating: 1,
            greenSpacesRating: 2,
            wasteBinsRating: 3
        )
        
        // manually initialized attributes
        #expect(review.reviewID == 1)
        #expect(review.cityID == 10)
        #expect(review.userID == 1)
        #expect(review.reviewText == "review text")
        #expect(review.localTransportRating == 1)
        #expect(review.greenSpacesRating == 2)
        #expect(review.wasteBinsRating == 3)
        
        // automatically initialized attributes
        #expect(review.cityIata == "")
        #expect(review.countryCode == "")
        #expect(review.firstName == "")
        #expect(review.lastName == "")
        #expect(review.scoreShortDistance == 0)
        #expect(review.scoreLongDistance == 0)
        #expect(review.badges == [])
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
            lastName: "Doe",
            scoreShortDistance: 50,
            scoreLongDistance: 100,
            badges: []
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(review)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decodedReview = try decoder.decode(Review.self, from: data)
        
        #expect(decodedReview.reviewID == review.reviewID)
        #expect(decodedReview.cityID == review.cityID)
        #expect(decodedReview.userID == review.userID)
        #expect(decodedReview.reviewText == review.reviewText)
        #expect(decodedReview.localTransportRating == review.localTransportRating)
        #expect(decodedReview.greenSpacesRating == review.greenSpacesRating)
        #expect(decodedReview.wasteBinsRating == review.wasteBinsRating)
        #expect(decodedReview.cityIata == review.cityIata)
        #expect(decodedReview.countryCode == review.countryCode)
        #expect(decodedReview.firstName == review.firstName)
        #expect(decodedReview.lastName == review.lastName)
        #expect(decodedReview.scoreShortDistance == review.scoreShortDistance)
        #expect(decodedReview.scoreLongDistance == review.scoreLongDistance)
        #expect(decodedReview.badges.isEmpty)
    }
    
    @Test
    func testComputeRatingInteger() {
        let review = Review(
            reviewID: 1,
            cityID: 10,
            userID: 1,
            reviewText: "review text",
            localTransportRating: 1,
            greenSpacesRating: 2,
            wasteBinsRating: 3
        )
        
        let average = review.computeRating()
        
        #expect(average == 2.0)
    }
    
    @Test
    func testComputeRatingZero() {
        let review = Review(
            reviewID: 1,
            cityID: 10,
            userID: 1,
            reviewText: "review text",
            localTransportRating: 0,
            greenSpacesRating: 0,
            wasteBinsRating: 0
        )
        
        let average = review.computeRating()
        
        
        #expect(average == 0)
    }

}
