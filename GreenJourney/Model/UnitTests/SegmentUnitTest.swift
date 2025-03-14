import Foundation
import Testing

@testable import GreenJourney

struct SegmentUnitTest {
    @Test
    func testInitializerWithAttributes() {
        let date = Date.now
        let segment = Segment(
            segmentID: 1,
            departureID: 10,
            destinationID: 11,
            departureCity: "Milan",
            departureCountry: "Italy",
            destinationCity: "Paris",
            destinationCountry: "France",
            dateTime: date,
            duration: 1000,
            vehicle: Vehicle.bike,
            segmentDescription: "segment description",
            price: 100.123,
            co2Emitted: 100.1234,
            distance: 10.1234,
            numSegment: 1,
            isOutward: true,
            travelID: 2
        )
        
        #expect(segment.segmentID == 1)
        #expect(segment.departureID == 10)
        #expect(segment.destinationID == 11)
        #expect(segment.departureCity == "Milan")
        #expect(segment.departureCountry == "Italy")
        #expect(segment.destinationCity == "Paris")
        #expect(segment.destinationCountry == "France")
        #expect(segment.dateTime == date)
        #expect(segment.duration == 1000)
        #expect(segment.vehicle == Vehicle.bike)
        #expect(segment.segmentDescription == "segment description")
        #expect(segment.price == 100.123)
        #expect(segment.co2Emitted == 100.1234)
        #expect(segment.distance == 10.1234)
        #expect(segment.numSegment == 1)
        #expect(segment.isOutward == true)
        #expect(segment.travelID == 2)
    }
    
    @Test
    func testEncodingDecoding() throws {
        let date = Date.now
        let segment = Segment(
            segmentID: 1,
            departureID: 10,
            destinationID: 11,
            departureCity: "Milan",
            departureCountry: "Italy",
            destinationCity: "Paris",
            destinationCountry: "France",
            dateTime: date,
            duration: 1000,
            vehicle: Vehicle.bike,
            segmentDescription: "segment description",
            price: 100.123,
            co2Emitted: 100.1234,
            distance: 10.1234,
            numSegment: 1,
            isOutward: true,
            travelID: 2
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(segment)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decodedSegment = try decoder.decode(Segment.self, from: data)
        
        #expect(decodedSegment.segmentID == segment.segmentID)
        #expect(decodedSegment.departureID == segment.departureID)
        #expect(decodedSegment.destinationID == segment.destinationID)
        #expect(decodedSegment.departureCity == segment.departureCity)
        #expect(decodedSegment.departureCountry == segment.departureCountry)
        #expect(decodedSegment.destinationCity == segment.destinationCity)
        #expect(decodedSegment.destinationCountry == segment.destinationCountry)
        #expect(decodedSegment.duration == segment.duration)
        #expect(decodedSegment.vehicle == segment.vehicle)
        #expect(decodedSegment.segmentDescription == segment.segmentDescription)
        #expect(decodedSegment.co2Emitted == segment.co2Emitted)
        #expect(decodedSegment.distance == segment.distance)
        #expect(decodedSegment.numSegment == segment.numSegment)
        #expect(decodedSegment.isOutward == segment.isOutward)
        #expect(decodedSegment.travelID == segment.travelID)
    }
    
    @Test
    func testGetArrivalDateTime() {
        let date = Date.now
        let segment = Segment(
            segmentID: 1,
            departureID: 10,
            destinationID: 11,
            departureCity: "Milan",
            departureCountry: "Italy",
            destinationCity: "Paris",
            destinationCountry: "France",
            dateTime: date,
            duration: 1000,
            vehicle: Vehicle.bike,
            segmentDescription: "segment description",
            price: 100.123,
            co2Emitted: 100.1234,
            distance: 10.1234,
            numSegment: 1,
            isOutward: true,
            travelID: 2
        )
        #expect(segment.getArrivalDateTime() == date.addingTimeInterval(TimeInterval(segment.duration/1000000000)))
    }
    
    @Test
    func testFindVehicleBicycle() {
        let date = Date.now
        let segment = Segment(
            segmentID: 1,
            departureID: 10,
            destinationID: 11,
            departureCity: "Milan",
            departureCountry: "Italy",
            destinationCity: "Paris",
            destinationCountry: "France",
            dateTime: date,
            duration: 1000,
            vehicle: Vehicle.bike,
            segmentDescription: "segment description",
            price: 100.123,
            co2Emitted: 100.1234,
            distance: 10.1234,
            numSegment: 1,
            isOutward: true,
            travelID: 2
        )
        
        #expect(segment.findVehicle() == "bicycle")
    }
}
