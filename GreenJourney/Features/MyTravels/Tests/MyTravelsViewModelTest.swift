import Foundation
import SwiftData
import Testing

@testable import GreenJourney

@MainActor
final class MyTravelsViewModelTest {
    private var viewModel: MyTravelsViewModel
    private var mockModelContainer: ModelContainer
    private var mockModelContext: ModelContext
    private var mockServerService: MockServerService
    private var mockFirebaseAuthService: MockFirebaseAuthService
    
    init() throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: User.self, Travel.self, Segment.self, CityFeatures.self, CityCompleterDataset.self, configurations: configuration)
        self.mockModelContainer = container
        self.mockModelContext = container.mainContext
        self.mockServerService = MockServerService()
        self.mockFirebaseAuthService = MockFirebaseAuthService()
        self.viewModel = MyTravelsViewModel(modelContext: container.mainContext, serverService: mockServerService)
    }
    
    @Test
    func testGetUserTravelsError() async throws {
        self.mockServerService.shouldSucceed = false
        
        await viewModel.getUserTravels()
        let travels = try mockModelContext.fetch(FetchDescriptor<Travel>())
        let segments = try mockModelContext.fetch(FetchDescriptor<Segment>())
        #expect(travels.isEmpty)
        #expect(segments.isEmpty)
        #expect(viewModel.travelDetailsList.isEmpty)
    }
    
    @Test
    func testGetUserTravels() async throws {
        self.mockServerService.shouldSucceed = true
        
        await viewModel.getUserTravels()
        let travels = try mockModelContext.fetch(FetchDescriptor<Travel>())
        let segments = try mockModelContext.fetch(FetchDescriptor<Segment>())
        #expect(travels.count > 0)
        #expect(segments.count > 0)
        #expect(viewModel.travelDetailsList.count > 0)
    }
    
    @Test
    func testShowRequestedTravelsCompleted() async {
        // load travels from mock server
        self.mockServerService.shouldSucceed = true
        await viewModel.getUserTravels()
        
        viewModel.showCompleted = true
        for travelDetails in viewModel.filteredTravelDetailsList {
            #expect(isTravelInPast(travelDetails: travelDetails))
        }
    }
    
    @Test
    func testShowRequestedTravelsNotCompleted() async {
        // load travels from mock server
        self.mockServerService.shouldSucceed = true
        await viewModel.getUserTravels()
        
        viewModel.showCompleted = false
        for travelDetails in viewModel.filteredTravelDetailsList {
            #expect(!isTravelInPast(travelDetails: travelDetails))
        }
    }
    
    private func isTravelInPast(travelDetails: TravelDetails) -> Bool {
        let currentDate = Date()
        let lastSegment = travelDetails.getLastSegment()
        if let lastSegment = lastSegment {
            let durationSeconds = Double(lastSegment.duration) / 1_000_000_000
            let departureDateLastSegment = lastSegment.dateTime
            let arrivalDate = departureDateLastSegment.addingTimeInterval(durationSeconds)
            return arrivalDate <= currentDate
        }
        return false
    }
    
    @Test
    func testShowRequestedTravelsSortedByDepartureDate() async {
        // load travels from mock server
        self.mockServerService.shouldSucceed = true
        await viewModel.getUserTravels()
        
        // sort by decreasing departure date
        viewModel.sortOption = .departureDate
        viewModel.showRequestedTravels()
        
        let tdList = viewModel.filteredTravelDetailsList
        for (current, next) in zip(tdList, tdList.dropFirst()) {
            if let currDate = current.getDepartureSegment()?.dateTime {
                if let nextDate = next.getDepartureSegment()?.dateTime {
                    #expect(currDate >= nextDate)
                }
            }
        }
    }
    
    @Test
    func testShowRequestedTravelsSortedByCo2Emitted() async {
        // load travels from mock server
        self.mockServerService.shouldSucceed = true
        await viewModel.getUserTravels()
        
        // sort by decreasing Co2 emitted
        viewModel.sortOption = .co2Emitted
        viewModel.showRequestedTravels()
        
        let tdList = viewModel.filteredTravelDetailsList
        for (current, next) in zip(tdList, tdList.dropFirst()) {
            var currCo2Emitted = 0.0
            for segment in current.segments {
                currCo2Emitted += segment.co2Emitted
            }
            var nextCo2Emitted = 0.0
            for segment in next.segments {
                nextCo2Emitted += segment.co2Emitted
            }
            #expect(currCo2Emitted >= nextCo2Emitted)
        }
    }
    
    @Test
    func testShowRequestedTravelsSortedByCo2CompensationRate() async {
        // load travels from mock server
        self.mockServerService.shouldSucceed = true
        await viewModel.getUserTravels()
        
        // sort by increasing co2 compensated / co2 emitted
        viewModel.sortOption = .co2CompensationRate
        viewModel.showRequestedTravels()
        
        let tdList = viewModel.filteredTravelDetailsList
        for (current, next) in zip(tdList, tdList.dropFirst()) {
            var currCo2Emitted = 0.0
            for segment in current.segments {
                currCo2Emitted += segment.co2Emitted
            }
            var nextCo2Emitted = 0.0
            for segment in next.segments {
                nextCo2Emitted += segment.co2Emitted
            }
            let currCo2Rate: Double
            if currCo2Emitted == 0 {
                currCo2Rate = 0
            } else {
                let currCo2Compensated = current.travel.CO2Compensated
                currCo2Rate = currCo2Compensated/currCo2Emitted
            }
            let nextCo2Rate: Double
            if nextCo2Emitted == 0 {
                nextCo2Rate = 0
            } else {
                let nextCo2Compensated = next.travel.CO2Compensated
                nextCo2Rate = nextCo2Compensated/nextCo2Emitted
            }
            #expect(currCo2Rate <= nextCo2Rate)
        }
    }
    
    @Test
    func testShowRequestedTravelsSortedByPrice() async {
        // load travels from mock server
        self.mockServerService.shouldSucceed = true
        await viewModel.getUserTravels()
        
        // sort by decreasing price
        viewModel.sortOption = .price
        viewModel.showRequestedTravels()
        
        let tdList = viewModel.filteredTravelDetailsList
        for (current, next) in zip(tdList, tdList.dropFirst()) {
            var priceCurrent = 0.0
            for segment in current.segments {
                priceCurrent += segment.price
            }
            var priceNext = 0.0
            for segment in next.segments {
                priceNext += segment.price
            }
            #expect(priceCurrent >= priceNext)
        }
    }
    
    @Test
    func testCompensateCo2Successful() async {
        // initialize server and ViewModel
        self.mockServerService.shouldSucceed = true
        await viewModel.getUserTravels()
        viewModel.selectedTravel = viewModel.travelDetailsList.first!
        viewModel.compensatedPrice = 1
        
        let travelId = viewModel.selectedTravel?.travel.travelID!
        let co2Compensated = viewModel.selectedTravel!.travel.CO2Compensated
        let compensatedPrice = viewModel.compensatedPrice
        
        // compensate
        await viewModel.compensateCO2()
        
        // check co2 compensated
        for td in viewModel.travelDetailsList {
            if td.travel.travelID == travelId {
                let newCo2Compensated = co2CompensatedPerEuro * compensatedPrice
                #expect(td.travel.CO2Compensated == co2Compensated + newCo2Compensated)
            }
        }
    }
    
    @Test
    func testCompensateCo2Unsuccessful() async {
        // initialize server and ViewModel
        self.mockServerService.shouldSucceed = true
        await viewModel.getUserTravels()
        viewModel.selectedTravel = viewModel.travelDetailsList.first!
        viewModel.compensatedPrice = 1
        
        let travelId = viewModel.selectedTravel?.travel.travelID!
        let co2Compensated = viewModel.selectedTravel!.travel.CO2Compensated
        
        // initialize server and compensate co2
        self.mockServerService.shouldSucceed = false
        await viewModel.compensateCO2()
        
        // check co2 compensated
        for td in viewModel.travelDetailsList {
            if td.travel.travelID == travelId {
                #expect(td.travel.CO2Compensated == co2Compensated)
            }
        }
    }
    
    @Test
    func testConfirmTravelSuccessful() async {
        // initialize server and ViewModel
        self.mockServerService.shouldSucceed = true
        await viewModel.getUserTravels()
        let travel = viewModel.travelDetailsList.first!.travel
        #expect(travel.confirmed == false)
        
        // initialize server and compensate co2
        self.mockServerService.shouldSucceed = true
        await viewModel.confirmTravel(travel: travel)
        
        #expect(travel.confirmed == true)
    }
    
    @Test
    func testConfirmTravelUnsuccessful() async {
        // initialize server and ViewModel
        self.mockServerService.shouldSucceed = true
        await viewModel.getUserTravels()
        let travel = viewModel.travelDetailsList.first!.travel
        #expect(travel.confirmed == false)
        
        // initialize server and compensate co2
        self.mockServerService.shouldSucceed = false
        await viewModel.confirmTravel(travel: travel)
        
        #expect(travel.confirmed == false)
    }
    
    @Test
    func testDeleteTravelSuccessful() async {
        // initialize server and ViewModel
        self.mockServerService.shouldSucceed = true
        await viewModel.getUserTravels()
        let travel = viewModel.travelDetailsList.first!.travel
        
        // initialize server and delete travel
        self.mockServerService.shouldSucceed = true
        await viewModel.deleteTravel(travelToDelete: travel)
        
        // check travel not present anymore
        for td in viewModel.travelDetailsList {
            #expect(td.travel.travelID != travel.travelID)
        }
    }
    
    @Test
    func testDeleteTravelUnsuccessful() async {
        // initialize server and ViewModel
        self.mockServerService.shouldSucceed = true
        await viewModel.getUserTravels()
        let travel = viewModel.travelDetailsList.first!.travel
        
        // initialize server and delete travel
        self.mockServerService.shouldSucceed = false
        await viewModel.deleteTravel(travelToDelete: travel)
        
        // check travel not present anymore
        var foundTravel = false
        for td in viewModel.travelDetailsList {
            if td.travel.travelID == travel.travelID {
                foundTravel = true
            }
        }
        
        #expect(foundTravel)
    }
}
