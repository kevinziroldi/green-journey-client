import Foundation
import Testing

@testable import GreenJourney

struct TravelTest {
    @Test
    func testInitializerWithAttributesWithTravelID() {
        let travel = Travel(
            travelID: 1,
            userID: 100
        )
        #expect(travel.travelID == 1)
        #expect(travel.CO2Compensated == 0)
        #expect(travel.confirmed == false)
        #expect(travel.userID == 100)
    }
    
    @Test
    func testInitializerWithAttributesWithoutTravelID() {
        let travel = Travel(
            userID: 100
        )
        #expect(travel.travelID == nil)
        #expect(travel.CO2Compensated == 0)
        #expect(travel.confirmed == false)
        #expect(travel.userID == 100)
    }
    
    @Test
    func testCopyInitializer() {
        let originalTravel = Travel(
            travelID: 1,
            userID: 100
        )
        originalTravel.CO2Compensated = 20.2
        originalTravel.confirmed = true
        
        let copyTravel = Travel(travelCopy: originalTravel)
        #expect(originalTravel != copyTravel)
        #expect(copyTravel.travelID == originalTravel.travelID)
        #expect(copyTravel.CO2Compensated == originalTravel.CO2Compensated)
        #expect(copyTravel.confirmed == originalTravel.confirmed)
        #expect(copyTravel.userID == originalTravel.userID)
    }
    
    @Test
    func testEncodingDecoding() throws {
        let travel = Travel(travelID: 300, userID: 77)
        travel.CO2Compensated = 42.0
        travel.confirmed = true
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(travel)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decodedTravel = try decoder.decode(Travel.self, from: data)
        
        #expect(decodedTravel.travelID == travel.travelID)
        #expect(decodedTravel.CO2Compensated == travel.CO2Compensated)
        #expect(decodedTravel.confirmed == travel.confirmed)
        #expect(decodedTravel.userID == travel.userID)
    }
}
