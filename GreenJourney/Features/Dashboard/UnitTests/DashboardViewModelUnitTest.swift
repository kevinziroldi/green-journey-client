import Foundation
import SwiftData
import Testing

@testable import GreenJourney

@MainActor
final class DashboardViewModelUnitTest {
    private var mockModelContext: ModelContext
    private var mockModelContainer: ModelContainer
    private var mockServerService: MockServerService
    private var viewModel: DashboardViewModel
    
    init() throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: User.self, Travel.self, Segment.self, CityFeatures.self, CityCompleterDataset.self, configurations: configuration)
        self.mockModelContext = container.mainContext
        self.mockModelContainer = container
        
        self.mockServerService = MockServerService()
        self.viewModel = DashboardViewModel(modelContext: mockModelContext)
        
        try addUserToSwiftData()
        try addTravelsToSwiftData()
    }
    
     private func addUserToSwiftData() throws {
        let mockUser = User(
            userID: 1,
            firstName: "John",
            lastName: "Doe",
            gender: "male",
            firebaseUID: "john_doe_firebase_uid",
            zipCode: 19,
            city: "London",
            scoreShortDistance: 50,
            scoreLongDistance: 100,
            badges: [Badge.badgeDistanceLow, Badge.badgeEcologicalChoiceMid, Badge.badgeTravelsNumberHigh]
        )
        
        self.mockModelContext.insert(mockUser)
        try self.mockModelContext.save()
    }
    
    private func addTravelsToSwiftData() throws {
        let mockTravel = Travel(travelID: 1, userID: 1, confirmed: true)
        
        let mockSegment = Segment(
            segmentID: 1,
            departureID: 1,
            destinationID: 2,
            departureCity: "Milano",
            departureCountry: "Italy",
            destinationCity: "Paris",
            destinationCountry: "France",
            dateTime: Date.now,
            duration: 3 * 60 * 1000000000,
            vehicle: Vehicle.car,
            segmentDescription: "",
            price: 100,
            co2Emitted: 10,
            distance: 700,
            numSegment: 1,
            isOutward: true,
            travelID: 1
        )
        
        self.mockModelContext.insert(mockTravel)
        self.mockModelContext.insert(mockSegment)
        try self.mockModelContext.save()
    }
    
    @Test
    func testGetUserBadges() throws {
        viewModel.getUserBadges()
        
        // check bedges present
        #expect(viewModel.badges.count == 3)
        #expect(viewModel.badges.contains(Badge.badgeDistanceLow))
        #expect(viewModel.badges.contains(Badge.badgeEcologicalChoiceMid))
        #expect(viewModel.badges.contains(Badge.badgeTravelsNumberHigh))
    }
    
    @Test
    func testGetUserTravels() throws {
        viewModel.getUserTravels()
        
        // check values
        #expect(viewModel.co2Emitted == 10)
        #expect(viewModel.treesPlanted == 0)
        #expect(viewModel.co2Compensated == 0)
        #expect(viewModel.totalDistance == 700)
        #expect(viewModel.mostChosenVehicle == "car")
        #expect(viewModel.visitedContinents == 1)
        #expect(viewModel.totalDurationString == "0 h, 3 min")
        let currYear = Calendar.current.component(.year, from: Date())
        for distance in viewModel.distances {
            if distance.key < currYear {
                #expect(distance.value == 0)
            } else {
                #expect(distance.value == 700)
            }
        }
        for tripsMade in viewModel.tripsMade {
            if tripsMade.key < currYear {
                #expect(tripsMade.value == 0)
            } else {
                #expect(tripsMade.value == 1)
            }
        }
        #expect(viewModel.totalTripsMade == 1)
    }
    
    @Test
    func testKeysToString() {
        let strings = viewModel.keysToString(keys: [2022, 2023, 2024, 2025])
        #expect(strings == ["2022", "2023", "2024", "2025"])
    }
}
