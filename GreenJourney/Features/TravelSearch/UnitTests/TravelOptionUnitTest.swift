import Foundation
import SwiftData
import Testing

@testable import GreenJourney

@MainActor
final class TravelOptionUnitTest {
    @Test
    func testComputeCo2EmittedNoSegments() async {
        let travelOption = TravelOption(segments: [])
        let co2Emitted = travelOption.getCo2Emitted()
        #expect(co2Emitted == 0)
    }
    
    @Test
    func testComputeCo2EmittedWithSegments() async {
        let segment = Segment(
            segmentID: 0,
            departureID: 264373,
            destinationID: 275549,
            departureCity: "Milano",
            departureCountry: "Italy",
            destinationCity: "Paris",
            destinationCountry: "France",
            dateTime: Date.now,
            duration: 31554000000000,
            vehicle: Vehicle.car,
            segmentDescription: "",
            price: 76.680000000000007,
            co2Emitted: 170.40000000000001,
            distance: 852.88099999999997,
            numSegment: 1,
            isOutward: true,
            travelID: -1
        )
        let travelOption = TravelOption(segments: [segment])
        
        let co2Emitted = travelOption.getCo2Emitted()
        #expect(co2Emitted == 170.40000000000001)
    }
    
    @Test
    func testComputeTotalPriceNoSegments() async {
        let travelOption = TravelOption(segments: [])
        let price = travelOption.getTotalPrice()
        #expect(price == 0)
    }
    
    @Test
    func testComputeTotalPriceBike() async {
        let segment = Segment(
            segmentID: 0,
            departureID: 264373,
            destinationID: 275549,
            departureCity: "Milano",
            departureCountry: "Italy",
            destinationCity: "Paris",
            destinationCountry: "France",
            dateTime: Date.now,
            duration: 165462000000000,
            vehicle: Vehicle.bike,
            segmentDescription: "",
            price: 0,
            co2Emitted: 0,
            distance: 864,
            numSegment: 1,
            isOutward: true,
            travelID: -1
        )
        let travelOption = TravelOption(segments: [segment])
        let price = travelOption.getTotalPrice()
        #expect(price == 0)
    }
   
    @Test
    func testComputeTotalPriceMultipleSegments() async throws {
        let jsonData = """
        [
          {
            "description" : "RE80, Locarno - Chiasso - Como - Milano",
            "co2_emitted" : 2.6600000000000001,
            "vehicle" : "train",
            "distance" : 76.146000000000001,
            "destination_city" : "Lugano",
            "destination_country" : "Switzerland",
            "is_outward" : true,
            "departure_id" : 264373,
            "travel_id" : 0,
            "segment_id" : 0,
            "num_segment" : 1,
            "price" : 8.3599999999999994,
            "destination_id" : 261009,
            "departure_city" : "Milano",
            "departure_country" : "Italy",
            "date_time" : "2024-12-23T12:43:00+01:00",
            "duration" : 4500000000000
          },
          {
            "description" : "",
            "co2_emitted" : 0,
            "vehicle" : "walk",
            "distance" : 0.16400000000000001,
            "destination_city" : "",
            "destination_country" : "",
            "is_outward" : true,
            "departure_id" : 261009,
            "travel_id" : 0,
            "segment_id" : 0,
            "num_segment" : 2,
            "price" : 0,
            "destination_id" : 261009,
            "departure_city" : "",
            "departure_country" : "",
            "date_time" : "2024-12-23T13:59:16+01:00",
            "duration" : 164000000000
          },
          {
            "description" : "IC21, ",
            "co2_emitted" : 8.9250000000000007,
            "vehicle" : "train",
            "distance" : 255.066,
            "destination_city" : "Basel SBB",
            "destination_country" : "Switzerland",
            "is_outward" : true,
            "departure_id" : 261009,
            "travel_id" : 0,
            "segment_id" : 0,
            "num_segment" : 3,
            "price" : 28.050000000000001,
            "destination_id" : 313149,
            "departure_city" : "Lugano",
            "departure_country" : "Switzerland",
            "date_time" : "2024-12-23T14:02:00+01:00",
            "duration" : 10440000000000
          },
          {
            "description" : "",
            "co2_emitted" : 0,
            "vehicle" : "walk",
            "distance" : 0.17599999999999999,
            "destination_city" : "",
            "destination_country" : "",
            "is_outward" : true,
            "departure_id" : 313149,
            "travel_id" : 0,
            "segment_id" : 0,
            "num_segment" : 4,
            "price" : 0,
            "destination_id" : 313149,
            "departure_city" : "",
            "departure_country" : "",
            "date_time" : "2024-12-23T17:17:52+01:00",
            "duration" : 188000000000
          },
          {
            "description" : "TER, Strasbourg - Bale",
            "co2_emitted" : 4.9700000000000006,
            "vehicle" : "train",
            "distance" : 142.125,
            "destination_city" : "Strasbourg",
            "destination_country" : "France",
            "is_outward" : true,
            "departure_id" : 313149,
            "travel_id" : 0,
            "segment_id" : 0,
            "num_segment" : 5,
            "price" : 15.619999999999999,
            "destination_id" : 293977,
            "departure_city" : "Basel SBB",
            "departure_country" : "Switzerland",
            "date_time" : "2024-12-23T17:21:00+01:00",
            "duration" : 4680000000000
          },
          {
            "description" : "",
            "co2_emitted" : 0,
            "vehicle" : "walk",
            "distance" : 0,
            "destination_city" : "",
            "destination_country" : "",
            "is_outward" : true,
            "departure_id" : 293977,
            "travel_id" : 0,
            "segment_id" : 0,
            "num_segment" : 6,
            "price" : 0,
            "destination_id" : 293977,
            "departure_city" : "",
            "departure_country" : "",
            "date_time" : "2024-12-23T18:57:00+01:00",
            "duration" : 0
          },
          {
            "description" : "TGV INOUI, Paris - Bas-Rhin TGV",
            "co2_emitted" : 15.330000000000002,
            "vehicle" : "train",
            "distance" : 438.43700000000001,
            "destination_city" : "Paris",
            "destination_country" : "France",
            "is_outward" : true,
            "departure_id" : 293977,
            "travel_id" : 0,
            "segment_id" : 0,
            "num_segment" : 7,
            "price" : 48.18,
            "destination_id" : 275549,
            "departure_city" : "Strasbourg",
            "departure_country" : "France",
            "date_time" : "2024-12-23T18:57:00+01:00",
            "duration" : 6240000000000
          }
        ]
        """
        
        guard let jsonData = jsonData.data(using: .utf8) else {
            fatalError("Errore nella conversione della stringa in Data")
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let travelOptionsRaw = try decoder.decode([Segment].self, from: jsonData)
        let travelOption = TravelOption(segments: travelOptionsRaw)

        let price = travelOption.getTotalPrice()
        let expectedPrice = 8.3599999999999994 + 28.050000000000001 + 15.619999999999999 + 48.18
        #expect(price == expectedPrice)
    }
    
    @Test
    func testComputeTotalDurationNoSegments() async {
        let travelOption = TravelOption(segments: [])
        let totalDuration = travelOption.getTotalDuration()
        #expect(totalDuration == "0 h, 0 min")
    }
    
    @Test
    func testComputeTotalDurationOneSegment() async {
        let segment = Segment(
            segmentID: 0,
            departureID: 264373,
            destinationID: 275549,
            departureCity: "Milano",
            departureCountry: "Italy",
            destinationCity: "Paris",
            destinationCountry: "France",
            dateTime: Date.now,
            duration: 31554000000000,
            vehicle: Vehicle.car,
            segmentDescription: "",
            price: 76.680000000000007,
            co2Emitted: 170.40000000000001,
            distance: 852.88099999999997,
            numSegment: 1,
            isOutward: true,
            travelID: -1
        )
        let travelOption = TravelOption(segments: [segment])
        
        let duration = travelOption.getTotalDuration()
        let expectedDuration = "8 h, 45 min"
        #expect(duration == expectedDuration)
    }
    
    @Test
    func testComputeTotalDurationLongSegment() async {
        let segment = Segment(
            segmentID: 0,
            departureID: 264373,
            destinationID: 275549,
            departureCity: "Milano",
            departureCountry: "Italy",
            destinationCity: "Paris",
            destinationCountry: "France",
            dateTime: Date.now,
            duration: 510000000000000,
            vehicle: Vehicle.bus,
            segmentDescription: "AZ 352",
            price: 201.22,
            co2Emitted: 148.70588235294119,
            distance: 637.82560356753254,
            numSegment: 1,
            isOutward: true,
            travelID: -1
        )
        let travelOption = TravelOption(segments: [segment])
        let duration = travelOption.getTotalDuration()
        let expectedDuration = "5 d, 21 h"
        #expect(duration == expectedDuration)
    }
    
    @Test
    func testGetOptionDepartureNoSegments() async {
        let travelOption = TravelOption(segments: [])
        let departure = travelOption.getOptionDeparture()
        #expect(departure == "")
    }
    
    @Test
    func testGetOptionDeparture() async {
        let segment = Segment(
            segmentID: 0,
            departureID: 264373,
            destinationID: 275549,
            departureCity: "Milano",
            departureCountry: "Italy",
            destinationCity: "Paris",
            destinationCountry: "France",
            dateTime: Date.now,
            duration: 165462000000000,
            vehicle: Vehicle.bike,
            segmentDescription: "",
            price: 0,
            co2Emitted: 0,
            distance: 864,
            numSegment: 1,
            isOutward: true,
            travelID: -1
        )
        let travelOption = TravelOption(segments: [segment])
        let departure = travelOption.getOptionDeparture()
        let expectedDeparture = "Milano"
        #expect(departure == expectedDeparture)
    }
    
    @Test
    func testGetOptionDestinationNoSegments() async {
        let travelOption = TravelOption(segments: [])
        let destination = travelOption.getOptionDestination()
        #expect(destination == "")
    }
    
    @Test
    func testGetOptionDestination() async {
        let segment = Segment(
            segmentID: 0,
            departureID: 264373,
            destinationID: 275549,
            departureCity: "Milano",
            departureCountry: "Italy",
            destinationCity: "Paris",
            destinationCountry: "France",
            dateTime: Date.now,
            duration: 165462000000000,
            vehicle: Vehicle.bike,
            segmentDescription: "",
            price: 0,
            co2Emitted: 0,
            distance: 864,
            numSegment: 1,
            isOutward: true,
            travelID: -1
        )
        let travelOption = TravelOption(segments: [segment])
        
        let destination = travelOption.getOptionDestination()
        let expectedDestination = "Paris"
        #expect(destination == expectedDestination)
    }
    
    @Test
    func testGetVehicleCar() async {
        let segment = Segment(
            segmentID: 0,
            departureID: 264373,
            destinationID: 275549,
            departureCity: "Milano",
            departureCountry: "Italy",
            destinationCity: "Paris",
            destinationCountry: "France",
            dateTime: Date.now,
            duration: 31554000000000,
            vehicle: Vehicle.car,
            segmentDescription: "",
            price: 76.680000000000007,
            co2Emitted: 170.40000000000001,
            distance: 852.88099999999997,
            numSegment: 1,
            isOutward: true,
            travelID: -1
        )
        let travelOption = TravelOption(segments: [segment])
        
        let vehicle = travelOption.findVehicle()
        #expect(vehicle == "car")
    }
    
    @Test
    func testGetVehicleBike() async {
        let segment = Segment(
            segmentID: 0,
            departureID: 264373,
            destinationID: 275549,
            departureCity: "Milano",
            departureCountry: "Italy",
            destinationCity: "Paris",
            destinationCountry: "France",
            dateTime: Date.now,
            duration: 165462000000000,
            vehicle: Vehicle.bike,
            segmentDescription: "",
            price: 0,
            co2Emitted: 0,
            distance: 864,
            numSegment: 1,
            isOutward: true,
            travelID: -1
        )
        let travelOption = TravelOption(segments: [segment])
        
        let vehicle = travelOption.findVehicle()
        #expect(vehicle == "bicycle")
    }
    
    @Test
    func testGetVehicleTrain() async {
        let segment = Segment(
            segmentID: 0,
            departureID: 264373,
            destinationID: 261009,
            departureCity: "Milano",
            departureCountry: "Italy",
            destinationCity: "Lugano",
            destinationCountry: "Switzerland",
            dateTime: Date.now,
            duration: 4500000000000,
            vehicle: Vehicle.train,
            segmentDescription: "RE80, Locarno - Chiasso - Como - Milano",
            price: 8.3599999999999994,
            co2Emitted: 2.6600000000000001,
            distance: 76.146000000000001,
            numSegment: 1,
            isOutward: true,
            travelID: 0
        )
        let travelOption = TravelOption(segments: [segment])
        
        let vehicle = travelOption.findVehicle()
        #expect(vehicle == "tram")
    }
    
    @Test
    func testGetVehiclePlane() async {
        let segment = Segment(
            segmentID: 0,
            departureID: 261009,
            destinationID: 261009,
            departureCity: "",
            departureCountry: "",
            destinationCity: "Paris",
            destinationCountry: "France",
            dateTime: Date.now,
            duration: 164000000000,
            vehicle: Vehicle.plane,
            segmentDescription: "VY 8431",
            price: 0,
            co2Emitted: 148.70588235294119,
            distance: 590.79114377048302,
            numSegment: 2,
            isOutward: true,
            travelID: 0
        )
        let travelOption = TravelOption(segments: [segment])
       
        let vehicle = travelOption.findVehicle()
        #expect(vehicle == "airplane")
    }
    
    @Test
    func testGetVehicleBus() async {
        let segment = Segment(
            segmentID: 0,
            departureID: 264373,
            destinationID: 275549,
            departureCity: "Milano",
            departureCountry: "Italy",
            destinationCity: "Paris",
            destinationCountry: "France",
            dateTime: Date.now,
            duration: 510000000000000,
            vehicle: Vehicle.bus,
            segmentDescription: "AZ 352",
            price: 201.22,
            co2Emitted: 148.70588235294119,
            distance: 637.82560356753254,
            numSegment: 1,
            isOutward: true,
            travelID: -1
        )
        let travelOption = TravelOption(segments: [segment])
        
        let vehicle = travelOption.findVehicle()
        #expect(vehicle == "bus")
    }
    
    @Test
    func testGetVehicleNoSegments() async {
        let travelOption = TravelOption(segments: [])
        let vehicle = travelOption.findVehicle()
        #expect(vehicle == "")
    }
    
}
