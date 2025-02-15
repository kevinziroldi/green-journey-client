import Foundation
import SwiftData
import Testing

@testable import GreenJourney

@MainActor
final class CitiesReviewsViewModelTest {
    private var mockModelContext: ModelContext
    private var mockModelContainer: ModelContainer
    private var mockServerService: MockServerService
    private var viewModel: CitiesReviewsViewModel
    
    init() throws {
        // create model context
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let mockContainer = try ModelContainer(for: User.self, Travel.self, Segment.self, CityFeatures.self, CityCompleterDataset.self, configurations: configuration)
        self.mockModelContainer = mockContainer
        self.mockModelContext = mockContainer.mainContext
        self.mockServerService = MockServerService()
        
        // create view model
        self.viewModel = CitiesReviewsViewModel(modelContext: self.mockModelContext, serverService: self.mockServerService)
        
        // add some cities to SwiftData
        try addCitiesToSwiftData()
        try addUserToSwiftData()
        try addTravelsToSwiftData()
    }
    
    private func addUserToSwiftData() throws {
        let mockUser = User(
            userID: 53,
            firstName: "John",
            lastName: "Doe",
            firebaseUID: "firebase_uid",
            scoreShortDistance: 50,
            scoreLongDistance: 50
        )
        self.mockModelContext.insert(mockUser)
        try self.mockModelContext.save()
    }
    
    private func addCitiesToSwiftData() throws {
        let cityMilan = CityCompleterDataset(
            cityName: "Milan",
            countryName: "Italy",
            iata: "MIL",
            countryCode: "IT",
            continent: "Europe"
        )
        let cityParis = CityCompleterDataset(
            cityName: "Paris",
            countryName: "France",
            iata: "PAR",
            countryCode: "FR",
            continent: "Europe"
        )
        let cityBerlin = CityCompleterDataset(
            cityName: "Berlin",
            countryName: "Germany",
            iata: "BER",
            countryCode: "DE",
            continent: "Europe"
        )
        let cityRome = CityCompleterDataset(
            cityName: "Roma",
            countryName: "Italy",
            iata: "ROM",
            countryCode: "IT",
            continent: "Europe"
        )
        
        self.mockModelContext.insert(cityMilan)
        self.mockModelContext.insert(cityBerlin)
        self.mockModelContext.insert(cityParis)
        self.mockModelContext.insert(cityRome)
        try self.mockModelContext.save()
    }
    
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
    
    @Test
    func testGetReviewsForSearchedCitySuccessful() async {
        self.mockServerService.shouldSucceed = true
        
        viewModel.searchedCity = CityCompleterDataset(
            cityName: "Paris",
            countryName: "France",
            iata: "PAR",
            countryCode: "FR",
            continent: "Europe"
        )
        
        await viewModel.getReviewsForSearchedCity()
        
        #expect(viewModel.searchedCityAvailable == true)
        #expect(viewModel.selectedCityReviewElement != nil)
        #expect(viewModel.selectedCityReviewElement?.reviews.count == 2)
        
        let reviewElement = viewModel.selectedCityReviewElement!
        #expect(reviewElement.averageWasteBinsRating >= 0 && reviewElement.averageWasteBinsRating <= 5)
        #expect(reviewElement.averageGreenSpacesRating >= 0 && reviewElement.averageGreenSpacesRating <= 5)
        #expect(reviewElement.averageLocalTransportRating >= 0 && reviewElement.averageLocalTransportRating <= 5)
        
        for review in reviewElement.reviews {
            #expect(review.cityIata == viewModel.searchedCity.iata)
            #expect(review.countryCode == viewModel.searchedCity.countryCode)
            #expect(review.localTransportRating >= 0 && review.localTransportRating <= 5)
            #expect(review.greenSpacesRating >= 0 && review.greenSpacesRating <= 5)
            #expect(review.wasteBinsRating >= 0 && review.wasteBinsRating <= 5)
            #expect(review.cityIata == viewModel.searchedCity.iata)
            #expect(review.countryCode == viewModel.searchedCity.countryCode)
            #expect(review.scoreShortDistance >= 0)
            #expect(review.scoreLongDistance >= 0)
        }
    }
    
    @Test
    func testGetReviewsForSearchedCityUnsuccessful() async {
        self.mockServerService.shouldSucceed = false
        
        viewModel.searchedCity = CityCompleterDataset(
            cityName: "Paris",
            countryName: "France",
            iata: "PAR",
            countryCode: "FR",
            continent: "Europe"
        )
        
        await viewModel.getReviewsForSearchedCity()
        
        viewModel.selectedCityReviewElement = nil
        viewModel.searchedCityAvailable = false
    }
    
    @Test
    func testGetBestReviewedCitiesSuccessful() async throws {
        self.mockServerService.shouldSucceed = true
        
        await viewModel.getBestReviewedCities()
        
        #expect(viewModel.bestCitiesReviewElements.count == 3)
        #expect(viewModel.bestCitiesReviewElements.count == viewModel.bestCities.count)
        
        // all reviews for every review element same city
        for reviewElement in viewModel.bestCitiesReviewElements {
            if let firstReview = reviewElement.reviews.first {
                for review in reviewElement.reviews {
                    #expect(review.cityID == firstReview.cityID)
                    #expect(review.cityIata == firstReview.cityIata)
                    #expect(review.countryCode == firstReview.countryCode)
                }
            }
        }
        
        // for every city and every review element, same city (same for all review)
        for (i, city) in viewModel.bestCities.enumerated() {
            #expect(city.iata == viewModel.bestCitiesReviewElements[i].reviews.first!.cityIata)
            #expect(city.countryCode == viewModel.bestCitiesReviewElements[i].reviews.first!.countryCode)
        }
    }
    
    @Test
    func testGetBestReviewedCitiesUnsuccessful() async throws {
        self.mockServerService.shouldSucceed = false
        
        await viewModel.getBestReviewedCities()
        
        #expect(viewModel.bestCitiesReviewElements.count == 0)
        #expect(viewModel.bestCitiesReviewElements.count == viewModel.bestCities.count)
    }
    
    @Test
    func testGetUserReviewSuccessful() async throws {
        self.mockServerService.shouldSucceed = true
        
        // retrieve reviews for Paris
        viewModel.searchedCity = CityCompleterDataset(
            cityName: "Paris",
            countryName: "France",
            iata: "PAR",
            countryCode: "FR",
            continent: "Europe"
        )
        await viewModel.getReviewsForSearchedCity()
        
        // call ViewModel function
        let userID = try mockModelContext.fetch(FetchDescriptor<User>()).first!.userID!
        viewModel.getUserReview(userID: userID)
        
        #expect(viewModel.userReview != nil)
        #expect(viewModel.userReview?.userID == userID)
    }
    
    @Test
    func testGetUserReviewUnuccessful() async throws {
        self.mockServerService.shouldSucceed = false

        // retrieve reviews for Paris
        viewModel.searchedCity = CityCompleterDataset(
            cityName: "Paris",
            countryName: "France",
            iata: "PAR",
            countryCode: "FR",
            continent: "Europe"
        )
        await viewModel.getReviewsForSearchedCity()
        
        // call ViewModel function
        let userID = try mockModelContext.fetch(FetchDescriptor<User>()).first!.userID!
        viewModel.getUserReview(userID: userID)
        
        #expect(viewModel.userReview == nil)
    }
    
    @Test
    func testIsReviewableTrue() async throws {
        self.mockServerService.shouldSucceed = true
     
        let userID = try mockModelContext.fetch(FetchDescriptor<User>()).first!.userID!
        viewModel.getUserReview(userID: userID)
        
        // retrieve reviews for Paris
        viewModel.selectedCity = CityCompleterDataset(
            cityName: "Paris",
            countryName: "France",
            iata: "PAR",
            countryCode: "FR",
            continent: "Europe"
        )
        await viewModel.getReviewsForSearchedCity()
    
        // selected city = Paris, user has visited Paris
        #expect(viewModel.isReviewable(userID: userID) == true)
    }
    
    @Test
    func testIsReviewableFalse() async throws {
        self.mockServerService.shouldSucceed = true
     
        let userID = try mockModelContext.fetch(FetchDescriptor<User>()).first!.userID!
        viewModel.getUserReview(userID: userID)
        
        // retrieve reviews for Berlin
        viewModel.searchedCity = CityCompleterDataset(
            cityName: "Berlin",
            countryName: "Germany",
            iata: "BER",
            countryCode: "DE",
            continent: "Europe"
        )
        await viewModel.getReviewsForSearchedCity()
        
        // selected city = Berlin, user has NOT visited Paris
        #expect(viewModel.isReviewable(userID: userID) == false)
    }
    
    @Test
    func testGetNumPagesWithRest() async {
        self.mockServerService.shouldSucceed = true
        self.mockServerService.twoReviews = true
        self.mockServerService.tenReviews = false
        
        // retrieve reviews for Paris
        viewModel.searchedCity = CityCompleterDataset(
            cityName: "Paris",
            countryName: "France",
            iata: "PAR",
            countryCode: "FR",
            continent: "Europe"
        )
        await viewModel.getReviewsForSearchedCity()
        
        #expect(viewModel.getNumPages() == 1)
    }
    
    @Test
    func testGetNumPagesInteger() async {
        self.mockServerService.shouldSucceed = true
        self.mockServerService.twoReviews = false
        self.mockServerService.tenReviews = true
        
        // retrieve reviews for Paris
        viewModel.searchedCity = CityCompleterDataset(
            cityName: "Berlin",
            countryName: "Germany",
            iata: "BER",
            countryCode: "DE",
            continent: "Europe"
        )
        await viewModel.getReviewsForSearchedCity()
        
        #expect(viewModel.getNumPages() == 1)
    }
    
    @Test
    func testGetNumPagesUnsuccessful() async {
        self.mockServerService.shouldSucceed = false
        
        // retrieve reviews for Paris
        viewModel.searchedCity = CityCompleterDataset(
            cityName: "Paris",
            countryName: "France",
            iata: "PAR",
            countryCode: "FR",
            continent: "Europe"
        )
        await viewModel.getReviewsForSearchedCity()
        
        #expect(viewModel.getNumPages() == 0)
    }
   
    @Test
    func testValidatePageInputNotANumber() {
        // the server returns 2 reviews, 1 page
        self.mockServerService.shouldSucceed = true
        self.mockServerService.twoReviews = false
        self.mockServerService.tenReviews = true
        
        viewModel.pageInput = "notANumber"
        let oldPage = viewModel.page
        viewModel.validatePageInput()
        
        #expect(viewModel.page == oldPage)
    }
    
    @Test
    func testValidatePageInputNumberOutOfRange() {
        // the server returns 2 reviews, 1 page
        self.mockServerService.shouldSucceed = true
        self.mockServerService.twoReviews = false
        self.mockServerService.tenReviews = true
        
        viewModel.pageInput = "10"
        let oldPage = viewModel.page
        viewModel.validatePageInput()
        
        #expect(viewModel.page == oldPage)
    }
    
    @Test
    func testValidatePageInputNumberInRange() {
        // the server returns 2 reviews, 1 page
        self.mockServerService.shouldSucceed = true
        self.mockServerService.twoReviews = false
        self.mockServerService.tenReviews = true
        
        viewModel.pageInput = "1"
        viewModel.validatePageInput()
        
        #expect(viewModel.page == 0)
    }
    
}
