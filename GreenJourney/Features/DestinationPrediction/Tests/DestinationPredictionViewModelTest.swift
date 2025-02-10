import Foundation
import SwiftData
import Testing

@testable import GreenJourney

struct DestinationPredictionViewModelTest {
    private var viewModel: DestinationPredictionViewModel
    private var mockModelContext: ModelContext
    private var mockModelContainer: ModelContainer
    
    @MainActor
    init() throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: User.self, Travel.self, Segment.self, CityFeatures.self, CityCompleterDataset.self, configurations: configuration)
        self.viewModel = DestinationPredictionViewModel(modelContext: container.mainContext)
        self.mockModelContainer = container
        self.mockModelContext = container.mainContext
        
        try addTravelsToSwiftData()
    }
    
    @MainActor
    private func addVisitedCitiesFeaturesToSwiftData() throws {
        let cityFeatureParis = CityFeatures(
            id: 55,
            iata: "PAR",
            countryCode: "FR",
            cityName: "Paris",
            countryName: "France",
            population: 11060000.0,
            capital: true,
            averageTemperature: 22.0219696969697,
            continent: "Europe",
            livingCost: 3.664,
            travelConnectivity: 10.0,
            safety: 6.2465,
            healthcare: 8.207666666666666,
            education: 7.085,
            economy: 4.2045,
            internetAccess: 9.716,
            outdoors: 4.433
        )
        
        self.mockModelContext.insert(cityFeatureParis)
        try self.mockModelContext.save()
    }
    
    @MainActor
    private func addNewCitiesFeaturesToSwiftData() throws {
        let cityFeatureRome = CityFeatures(
            id: 69,
            iata: "ROM",
            countryCode: "IT",
            cityName: "Rome",
            countryName: "Italy",
            population: 2748109.0,
            capital: true,
            averageTemperature: 30.3587786259542,
            continent: "Europe",
            livingCost: 5.323,
            travelConnectivity: 6.4335,
            safety: 6.604500000000001,
            healthcare: 7.863666666666665,
            education: 4.157000000000001,
            economy: 3.3625,
            internetAccess: 4.491,
            outdoors: 6.396000000000001
        )
        let cityFeatureVienna = CityFeatures(
            id: 71,
            iata: "VIE",
            countryCode: "AT",
            cityName: "Vienna",
            countryName: "Austria",
            population: 2223236.0,
            capital: true,
            averageTemperature: 25.450381679389317,
            continent: "Europe",
            livingCost: 5.111,
            travelConnectivity: 8.0315,
            safety: 8.5965,
            healthcare: 8.198,
            education: 4.854500000000001,
            economy: 4.663,
            internetAccess: 6.173,
            outdoors: 5.294499999999999
        )
        let cityFeatureLondon = CityFeatures(
            id: 51,
            iata: "LON",
            countryCode: "GB",
            cityName: "London",
            countryName: "United Kingdom",
            population: 11262000.0,
            capital: true,
            averageTemperature: 19.955384615384613,
            continent: "Europe",
            livingCost: 3.94,
            travelConnectivity: 9.4025,
            safety: 7.243500000000001,
            healthcare: 8.017999999999999,
            education: 9.027,
            economy: 5.438,
            internetAccess: 5.8455,
            outdoors: 5.374499999999999
        )
        self.mockModelContext.insert(cityFeatureRome)
        self.mockModelContext.insert(cityFeatureVienna)
        self.mockModelContext.insert(cityFeatureLondon)
        try self.mockModelContext.save()
    }
    
    @MainActor
    private func addTravelsToSwiftData() throws {
        let mockTravel = Travel(travelID: 1, userID: 53)
        let mockSegment = Segment(
            segmentID: 1,
            departureID: 1,
            destinationID: 2,
            departureCity: "Milano",
            departureCountry: "Italy",
            destinationCity: "Paris",
            destinationCountry: "France",
            dateTime: Date.now,
            duration: 0,
            vehicle: Vehicle.car,
            segmentDescription: "",
            price: 0,
            co2Emitted: 0,
            distance: 0,
            numSegment: 1,
            isOutward: true,
            travelID: 1
        )
        
        self.mockModelContext.insert(mockTravel)
        self.mockModelContext.insert(mockSegment)
        try self.mockModelContext.save()
    }
    
    @MainActor
    @Test
    func testPredictionAllVisited() throws {
        // add only visited cities
        try addVisitedCitiesFeaturesToSwiftData()
        
        viewModel.getRecommendation()
        #expect(viewModel.predictedCities.count > 0)
    }
    
    @MainActor
    @Test
    func testPredictionSomeNotVisited() throws {
        // add both visited and non visited cities
        try addVisitedCitiesFeaturesToSwiftData()
        try addNewCitiesFeaturesToSwiftData()
        
        viewModel.getRecommendation()
        #expect(viewModel.predictedCities.count > 0)
    }
    
    @Test
    func testPredictionNoCities() {
        viewModel.getRecommendation()
        #expect(viewModel.predictedCities.count == 0)
    }
}
