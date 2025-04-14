import Foundation
import Testing

@testable import GreenJourney

struct TravelDetailsUnitTest {
    @Test
    func testInitializer() {
        let travel = Travel(
            travelID: 1,
            userID: 100
        )
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
        let travelDetails = TravelDetails(
            travel: travel,
            segments: [segment]
        )
        
        #expect(travelDetails.travel.travelID == 1)
        #expect(travelDetails.segments.count == 1)
        #expect(travelDetails.segments[0].segmentID == 1)
    }
    
    @Test
    func testGetDepartureSegmentEmpty() {
        let travel = Travel(
            travelID: 1,
            userID: 100
        )
        let travelDetails = TravelDetails(
            travel: travel,
            segments: []
        )
        
        #expect(travelDetails.getDepartureSegment() == nil)
    }
    
    @Test
    func testGetDepartureSegmentSorted() {
        let travel = Travel(
            travelID: 1,
            userID: 100
        )
        let date = Date.now
        let segment1 = Segment(
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
        let segment2 = Segment(
            segmentID: 2,
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
            numSegment: 2,
            isOutward: true,
            travelID: 2
        )
        let segment3 = Segment(
            segmentID: 3,
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
            numSegment: 3,
            isOutward: true,
            travelID: 2
        )
        let travelDetails = TravelDetails(
            travel: travel,
            segments: [segment1, segment2, segment3]
        )
        
        let firstSegment = travelDetails.getDepartureSegment()
        #expect(firstSegment == segment1)
    }
    
    @Test
    func testGetDepartureSegmentNotSorted() {
        let travel = Travel(
            travelID: 1,
            userID: 100
        )
        let date = Date.now
        let segment1 = Segment(
            segmentID: 3,
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
            numSegment: 3,
            isOutward: true,
            travelID: 2
        )
        let segment2 = Segment(
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
        let segment3 = Segment(
            segmentID: 2,
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
            numSegment: 2,
            isOutward: true,
            travelID: 2
        )
        let travelDetails = TravelDetails(
            travel: travel,
            segments: [segment1, segment2, segment3]
        )
        
        let firstSegment = travelDetails.getDepartureSegment()
        #expect(firstSegment == segment2)
    }
    
    @Test
    func testGetLastSegmentEmpty() {
        let travel = Travel(
            travelID: 1,
            userID: 100
        )
        let travelDetails = TravelDetails(
            travel: travel,
            segments: []
        )
        
        #expect(travelDetails.getLastSegment() == nil)
    }
    
    @Test
    func testGetLastSegmentSorted() {
        let travel = Travel(
            travelID: 1,
            userID: 100
        )
        let date = Date.now
        let segment1 = Segment(
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
        let segment2 = Segment(
            segmentID: 2,
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
            numSegment: 2,
            isOutward: true,
            travelID: 2
        )
        let segment3 = Segment(
            segmentID: 3,
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
            numSegment: 3,
            isOutward: true,
            travelID: 2
        )
        let travelDetails = TravelDetails(
            travel: travel,
            segments: [segment1, segment2, segment3]
        )
        
        let lastSegment = travelDetails.getLastSegment()
        #expect(lastSegment?.segmentID == segment3.segmentID)
    }
    
    @Test
    func testGetLastSegmentNotSorted() {
        let travel = Travel(
            travelID: 1,
            userID: 100
        )
        let date = Date.now
        let segment1 = Segment(
            segmentID: 3,
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
            numSegment: 3,
            isOutward: true,
            travelID: 2
        )
        let segment2 = Segment(
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
        let segment3 = Segment(
            segmentID: 2,
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
            numSegment: 2,
            isOutward: true,
            travelID: 2
        )
        let travelDetails = TravelDetails(
            travel: travel,
            segments: [segment1, segment2, segment3]
        )
        
        let lastSegment = travelDetails.getLastSegment()
        #expect(lastSegment?.segmentID == segment1.segmentID)
    }
    
    @Test
    func testGetDestinationSegmentEmpty() {
        let travel = Travel(
            travelID: 1,
            userID: 100
        )
        let travelDetails = TravelDetails(
            travel: travel,
            segments: []
        )
        
        #expect(travelDetails.getDestinationSegment() == nil)
    }
    
    @Test
    func testGetDestinationSegmentSortedTwoWays() {
        let travel = Travel(
            travelID: 1,
            userID: 100
        )
        let date = Date.now
        let segment1 = Segment(
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
        let segment2 = Segment(
            segmentID: 2,
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
            numSegment: 2,
            isOutward: true,
            travelID: 2
        )
        let segment3 = Segment(
            segmentID: 3,
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
            numSegment: 3,
            isOutward: false,
            travelID: 2
        )
        let travelDetails = TravelDetails(
            travel: travel,
            segments: [segment1, segment2, segment3]
        )
        
        let destinationSegment = travelDetails.getDestinationSegment()
        #expect(destinationSegment?.segmentID == segment2.segmentID)
    }
    
    @Test
    func testGetDestinationSegmentNotSortedTwoWays() {
        let travel = Travel(
            travelID: 1,
            userID: 100
        )
        let date = Date.now
        let segment1 = Segment(
            segmentID: 3,
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
            numSegment: 3,
            isOutward: false,
            travelID: 2
        )
        let segment2 = Segment(
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
        let segment3 = Segment(
            segmentID: 2,
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
            numSegment: 2,
            isOutward: false,
            travelID: 2
        )
        let travelDetails = TravelDetails(
            travel: travel,
            segments: [segment1, segment2, segment3]
        )
        
        let lastSegment = travelDetails.getDestinationSegment()
        #expect(lastSegment?.segmentID == segment2.segmentID)
    }
    
    @Test
    func testGetDestinationSegmentSortedOneWay() {
        let travel = Travel(
            travelID: 1,
            userID: 100
        )
        let date = Date.now
        let segment1 = Segment(
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
        let segment2 = Segment(
            segmentID: 2,
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
            numSegment: 2,
            isOutward: true,
            travelID: 2
        )
        let segment3 = Segment(
            segmentID: 3,
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
            numSegment: 3,
            isOutward: true,
            travelID: 2
        )
        let travelDetails = TravelDetails(
            travel: travel,
            segments: [segment1, segment2, segment3]
        )
        
        let destinationSegment = travelDetails.getDestinationSegment()
        #expect(destinationSegment?.segmentID == segment3.segmentID)
    }
    
    @Test
    func testGetDestinationSegmentNotSortedOneWay() {
        let travel = Travel(
            travelID: 1,
            userID: 100
        )
        let date = Date.now
        let segment1 = Segment(
            segmentID: 3,
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
            numSegment: 3,
            isOutward: true,
            travelID: 2
        )
        let segment2 = Segment(
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
        let segment3 = Segment(
            segmentID: 2,
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
            numSegment: 2,
            isOutward: true,
            travelID: 2
        )
        let travelDetails = TravelDetails(
            travel: travel,
            segments: [segment1, segment2, segment3]
        )
        
        let lastSegment = travelDetails.getDestinationSegment()
        #expect(lastSegment?.segmentID == segment1.segmentID)
    }
    
    @Test
    func testSortSegments() {
        let travel = Travel(
            travelID: 1,
            userID: 100
        )
        let date = Date.now
        let segment1 = Segment(
            segmentID: 3,
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
            numSegment: 3,
            isOutward: true,
            travelID: 2
        )
        let segment2 = Segment(
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
        let segment3 = Segment(
            segmentID: 2,
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
            numSegment: 2,
            isOutward: true,
            travelID: 2
        )
        let travelDetails = TravelDetails(
            travel: travel,
            segments: [segment1, segment2, segment3]
        )
        
        travelDetails.sortSegments()
        
        #expect(travelDetails.segments[0].numSegment == 1)
        #expect(travelDetails.segments[1].numSegment == 2)
        #expect(travelDetails.segments[2].numSegment == 3)
    }
    
    @Test
    func testComputeCo2Emitted() {
        let travel = Travel(
            travelID: 1,
            userID: 100
        )
        let date = Date.now
        let segment1 = Segment(
            segmentID: 3,
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
            co2Emitted: 100,
            distance: 10.1234,
            numSegment: 3,
            isOutward: true,
            travelID: 2
        )
        let segment2 = Segment(
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
            co2Emitted: 10,
            distance: 10.1234,
            numSegment: 1,
            isOutward: true,
            travelID: 2
        )
        let segment3 = Segment(
            segmentID: 2,
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
            co2Emitted: 20,
            distance: 10.1234,
            numSegment: 2,
            isOutward: true,
            travelID: 2
        )
        let travelDetails = TravelDetails(
            travel: travel,
            segments: [segment1, segment2, segment3]
        )
        
        let co2Emitted = travelDetails.computeCo2Emitted()
        
        #expect(co2Emitted == 130.0)
    }
    
    @Test
    func testComputeTotalPrice() {
        let travel = Travel(
            travelID: 1,
            userID: 100
        )
        let date = Date.now
        let segment1 = Segment(
            segmentID: 3,
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
            price: 10,
            co2Emitted: 100,
            distance: 10.1234,
            numSegment: 3,
            isOutward: true,
            travelID: 2
        )
        let segment2 = Segment(
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
            price: 50,
            co2Emitted: 10,
            distance: 10.1234,
            numSegment: 1,
            isOutward: true,
            travelID: 2
        )
        let segment3 = Segment(
            segmentID: 2,
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
            price: 20.50,
            co2Emitted: 20,
            distance: 10.1234,
            numSegment: 2,
            isOutward: true,
            travelID: 2
        )
        let travelDetails = TravelDetails(
            travel: travel,
            segments: [segment1, segment2, segment3]
        )
        
        let totalPrice = travelDetails.computeTotalPrice()
        
        #expect(totalPrice == 80.5)
    }
    
    @Test
    func testComputeTotalDistance() {
        let travel = Travel(
            travelID: 1,
            userID: 100
        )
        let date = Date.now
        let segment1 = Segment(
            segmentID: 3,
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
            price: 10,
            co2Emitted: 100,
            distance: 10.5,
            numSegment: 3,
            isOutward: true,
            travelID: 2
        )
        let segment2 = Segment(
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
            price: 50,
            co2Emitted: 10,
            distance: 9.5,
            numSegment: 1,
            isOutward: true,
            travelID: 2
        )
        let segment3 = Segment(
            segmentID: 2,
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
            price: 20.50,
            co2Emitted: 20,
            distance: 10,
            numSegment: 2,
            isOutward: true,
            travelID: 2
        )
        let travelDetails = TravelDetails(
            travel: travel,
            segments: [segment1, segment2, segment3]
        )
        
        let totalDistance = travelDetails.computeTotalDistance()
        
        #expect(totalDistance == 30)
    }
    
    @Test
    func computeTotalDuration() {
        let travel = Travel(
            travelID: 1,
            userID: 100
        )
        let date = Date.now
        let segment1 = Segment(
            segmentID: 1,
            departureID: 10,
            destinationID: 11,
            departureCity: "Milan",
            departureCountry: "Italy",
            destinationCity: "Paris",
            destinationCountry: "France",
            dateTime: date,
            // 1 hour, 5 minutes
            duration: 60 * 60 * 1000000000 + 5 * 60 * 1000000000,
            vehicle: Vehicle.bike,
            segmentDescription: "segment description",
            price: 10,
            co2Emitted: 100,
            distance: 10.5,
            numSegment: 1,
            isOutward: true,
            travelID: 2
        )
        let segment2 = Segment(
            segmentID: 2,
            departureID: 10,
            destinationID: 11,
            departureCity: "Milan",
            departureCountry: "Italy",
            destinationCity: "Paris",
            destinationCountry: "France",
            dateTime: date,
            // 1 hour, 5 minutes
            duration: 5 * 60 * 1000000000,
            vehicle: Vehicle.bike,
            segmentDescription: "segment description",
            price: 50,
            co2Emitted: 10,
            distance: 9.5,
            numSegment: 2,
            isOutward: true,
            travelID: 2
        )
        let travelDetails = TravelDetails(
            travel: travel,
            segments: [segment1, segment2]
        )
        
        let totalDuration = travelDetails.computeTotalDuration()
        
        #expect(totalDuration == "1 h, 10 m")
    }
    
    @Test
    func testIsOneWayTrue() {
        let travel = Travel(
            travelID: 1,
            userID: 100
        )
        let date = Date.now
        let segment1 = Segment(
            segmentID: 3,
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
            numSegment: 3,
            isOutward: true,
            travelID: 2
        )
        let segment2 = Segment(
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
        let segment3 = Segment(
            segmentID: 2,
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
            numSegment: 2,
            isOutward: true,
            travelID: 2
        )
        let travelDetails = TravelDetails(
            travel: travel,
            segments: [segment1, segment2, segment3]
        )
        
        let oneWay = travelDetails.isOneway()
        
        #expect(oneWay)
    }
    
    @Test
    func testIsOneWayFalse() {
        let travel = Travel(
            travelID: 1,
            userID: 100
        )
        let date = Date.now
        let segment1 = Segment(
            segmentID: 3,
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
            numSegment: 3,
            isOutward: false,
            travelID: 2
        )
        let segment2 = Segment(
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
        let segment3 = Segment(
            segmentID: 2,
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
            numSegment: 2,
            isOutward: false,
            travelID: 2
        )
        let travelDetails = TravelDetails(
            travel: travel,
            segments: [segment1, segment2, segment3]
        )
        
        let oneWay = travelDetails.isOneway()
        
        #expect(!oneWay)
    }
    
    @Test
    func testOutwardAndReturnSegments() {
        let travel = Travel(
            travelID: 1,
            userID: 100
        )
        let date = Date.now
        let segment1 = Segment(
            segmentID: 3,
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
            numSegment: 3,
            isOutward: false,
            travelID: 2
        )
        let segment2 = Segment(
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
        let segment3 = Segment(
            segmentID: 2,
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
            numSegment: 2,
            isOutward: false,
            travelID: 2
        )
        let travelDetails = TravelDetails(
            travel: travel,
            segments: [segment1, segment2, segment3]
        )
        
        let outwardSegments = travelDetails.getOutwardSegments()
        let returnSegments = travelDetails.getReturnSegments()
        
        #expect(outwardSegments.count == 1)
        #expect(returnSegments.count == 2)
        
        #expect(outwardSegments[0].segmentID == 1)
        
        #expect(returnSegments[0].segmentID == 2 || returnSegments[0].segmentID == 3)
        
        #expect(returnSegments[1].segmentID == 2 || returnSegments[1].segmentID == 3)
        
        #expect(returnSegments[0].segmentID != returnSegments[1].segmentID)
    }
    
    @Test
    func testFindVehicleFirstNotPresent() {
        let travel = Travel(
            travelID: 1,
            userID: 100
        )
        let date = Date.now
        let segment1 = Segment(
            segmentID: 3,
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
            numSegment: 3,
            isOutward: false,
            travelID: 2
        )
        let segment2 = Segment(
            segmentID: 1,
            departureID: 10,
            destinationID: 11,
            departureCity: "Milan",
            departureCountry: "Italy",
            destinationCity: "Paris",
            destinationCountry: "France",
            dateTime: date,
            duration: 1000,
            vehicle: Vehicle.car,
            segmentDescription: "segment description",
            price: 100.123,
            co2Emitted: 100.1234,
            distance: 10.1234,
            numSegment: 1,
            isOutward: true,
            travelID: 2
        )
        let segment3 = Segment(
            segmentID: 2,
            departureID: 10,
            destinationID: 11,
            departureCity: "Milan",
            departureCountry: "Italy",
            destinationCity: "Paris",
            destinationCountry: "France",
            dateTime: date,
            duration: 1000,
            vehicle: Vehicle.walk,
            segmentDescription: "segment description",
            price: 100.123,
            co2Emitted: 100.1234,
            distance: 10.1234,
            numSegment: 2,
            isOutward: false,
            travelID: 2
        )
        let travelDetails = TravelDetails(
            travel: travel,
            segments: [segment1, segment2, segment3]
        )
        
        let vehicleOutward = travelDetails.findVehicle(outwardDirection: true)
        let vehicleReturn = travelDetails.findVehicle(outwardDirection: false)
        
        #expect(vehicleOutward == "car")
        #expect(vehicleReturn == "bicycle")
    }
    
    @Test
    func testFindVehicleFirstPresentTrain() {
        let travel = Travel(
            travelID: 1,
            userID: 100
        )
        let date = Date.now
        let segment1 = Segment(
            segmentID: 1,
            departureID: 10,
            destinationID: 11,
            departureCity: "Milan",
            departureCountry: "Italy",
            destinationCity: "Paris",
            destinationCountry: "France",
            dateTime: date,
            duration: 1000,
            vehicle: Vehicle.train,
            segmentDescription: "segment description",
            price: 100.123,
            co2Emitted: 100.1234,
            distance: 10.1234,
            numSegment: 1,
            isOutward: true,
            travelID: 2
        )
        let travelDetails = TravelDetails(
            travel: travel,
            segments: [segment1]
        )
        
        let vehicleOutward = travelDetails.findVehicle(outwardDirection: true)
        
        #expect(vehicleOutward == "tram")
    }
    
    @Test
    func testFindVehicleFirstPresentAirplane() {
        let travel = Travel(
            travelID: 1,
            userID: 100
        )
        let date = Date.now
        let segment1 = Segment(
            segmentID: 1,
            departureID: 10,
            destinationID: 11,
            departureCity: "Milan",
            departureCountry: "Italy",
            destinationCity: "Paris",
            destinationCountry: "France",
            dateTime: date,
            duration: 1000,
            vehicle: Vehicle.plane,
            segmentDescription: "segment description",
            price: 100.123,
            co2Emitted: 100.1234,
            distance: 10.1234,
            numSegment: 1,
            isOutward: true,
            travelID: 2
        )
        let travelDetails = TravelDetails(
            travel: travel,
            segments: [segment1]
        )
        
        let vehicleOutward = travelDetails.findVehicle(outwardDirection: true)
        
        #expect(vehicleOutward == "airplane")
    }
    
    @Test
    func testFindVehicleFirstPresentBus() {
        let travel = Travel(
            travelID: 1,
            userID: 100
        )
        let date = Date.now
        let segment1 = Segment(
            segmentID: 1,
            departureID: 10,
            destinationID: 11,
            departureCity: "Milan",
            departureCountry: "Italy",
            destinationCity: "Paris",
            destinationCountry: "France",
            dateTime: date,
            duration: 1000,
            vehicle: Vehicle.bus,
            segmentDescription: "segment description",
            price: 100.123,
            co2Emitted: 100.1234,
            distance: 10.1234,
            numSegment: 1,
            isOutward: true,
            travelID: 2
        )
        let travelDetails = TravelDetails(
            travel: travel,
            segments: [segment1]
        )
        
        let vehicleOutward = travelDetails.findVehicle(outwardDirection: true)
        
        #expect(vehicleOutward == "bus")
    }
    
    @Test
    func testComputeGreenPrice() {
        let travel = Travel(
            travelID: 1,
            userID: 100
        )
        let date = Date.now
        let segment1 = Segment(
            segmentID: 1,
            departureID: 10,
            destinationID: 11,
            departureCity: "Milan",
            departureCountry: "Italy",
            destinationCity: "Paris",
            destinationCountry: "France",
            dateTime: date,
            duration: 1000,
            vehicle: Vehicle.bus,
            segmentDescription: "segment description",
            price: 100.123,
            co2Emitted: 75,
            distance: 10.1234,
            numSegment: 1,
            isOutward: true,
            travelID: 2
        )
        let travelDetails = TravelDetails(
            travel: travel,
            segments: [segment1]
        )
        
        #expect(travelDetails.computeGreenPrice() == travelDetails.segments[0].price + 2)
    }
    
    @Test
    func testCountChangesOne() {
        let travel = Travel(
            travelID: 1,
            userID: 100
        )
        let date = Date.now
        let segment1 = Segment(
            segmentID: 1,
            departureID: 10,
            destinationID: 11,
            departureCity: "Milan",
            departureCountry: "Italy",
            destinationCity: "Paris",
            destinationCountry: "France",
            dateTime: date,
            duration: 1000,
            vehicle: Vehicle.bus,
            segmentDescription: "segment description",
            price: 100.123,
            co2Emitted: 75,
            distance: 10.1234,
            numSegment: 1,
            isOutward: true,
            travelID: 2
        )
        let travelDetails = TravelDetails(
            travel: travel,
            segments: [segment1]
        )
        
        #expect(travelDetails.countChanges(outwardDirection: true) == 1)
    }
    
    @Test
    func testCountChangesZero() {
        let travel = Travel(
            travelID: 1,
            userID: 100
        )
        let date = Date.now
        let segment1 = Segment(
            segmentID: 1,
            departureID: 10,
            destinationID: 11,
            departureCity: "Milan",
            departureCountry: "Italy",
            destinationCity: "Paris",
            destinationCountry: "France",
            dateTime: date,
            duration: 1000,
            vehicle: Vehicle.walk,
            segmentDescription: "segment description",
            price: 100.123,
            co2Emitted: 75,
            distance: 10.1234,
            numSegment: 1,
            isOutward: true,
            travelID: 2
        )
        let travelDetails = TravelDetails(
            travel: travel,
            segments: [segment1]
        )
        
        #expect(travelDetails.countChanges(outwardDirection: false) == 0)
    }
    
    @Test
    func testGetYear() {
        let travel = Travel(
            travelID: 1,
            userID: 100
        )
        let date = Date.now
        let segment1 = Segment(
            segmentID: 1,
            departureID: 10,
            destinationID: 11,
            departureCity: "Milan",
            departureCountry: "Italy",
            destinationCity: "Paris",
            destinationCountry: "France",
            dateTime: date,
            duration: 1000,
            vehicle: Vehicle.walk,
            segmentDescription: "segment description",
            price: 100.123,
            co2Emitted: 75,
            distance: 10.1234,
            numSegment: 1,
            isOutward: true,
            travelID: 2
        )
        let travelDetails = TravelDetails(
            travel: travel,
            segments: [segment1]
        )
        
        #expect(travelDetails.getYear() == 2025)
    }
}
