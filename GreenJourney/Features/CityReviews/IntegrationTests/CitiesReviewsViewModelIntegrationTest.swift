import SwiftData
import SwiftUI
import Testing

@testable import GreenJourney

@MainActor
final class CitiesReviewsViewModelIntegrationTest {
    private var mockModelContext: ModelContext
    private var mockModelContainer: ModelContainer
    private var serverService: ServerService
    private var mockFirebaseAuthService: MockFirebaseAuthService
    private var viewModel: CitiesReviewsViewModel
    
    init() async throws {
        // create model context
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let mockContainer = try ModelContainer(for: User.self, Travel.self, Segment.self, CityFeatures.self, CityCompleterDataset.self, configurations: configuration)
        self.mockModelContainer = mockContainer
        self.mockModelContext = mockContainer.mainContext
        self.serverService = ServerService()
        self.mockFirebaseAuthService = MockFirebaseAuthService()
        
        // create view model
        self.viewModel = CitiesReviewsViewModel(modelContext: self.mockModelContext, serverService: self.serverService)
        
        // clean database
        try await serverService.resetTestDatabase()
    }
    
    private func loginUser() async throws {
        let authenticationViewModel = AuthenticationViewModel(modelContext: self.mockModelContext, serverService: self.serverService, firebaseAuthService: self.mockFirebaseAuthService)
        
        // signup - creates the user
        authenticationViewModel.email = "test@test.com"
        authenticationViewModel.password = "test_password"
        authenticationViewModel.repeatPassword = "test_password"
        authenticationViewModel.firstName = "test_name"
        authenticationViewModel.lastName = "test_name"
        
        // firebase auth should succeed
        self.mockFirebaseAuthService.shouldSucceed = true
        
        await authenticationViewModel.signUp()
        #expect(authenticationViewModel.errorMessage == nil)
        #expect(authenticationViewModel.isLogged == false)
        
        // check SwiftData has no user
        var users = try mockModelContext.fetch(FetchDescriptor<User>())
        #expect(users.count == 0)
        #expect(authenticationViewModel.isEmailVerificationActiveSignup == true)
        
        // verify email - already logs the user
        self.mockFirebaseAuthService.shouldSucceed = true
        self.mockFirebaseAuthService.emailVerified = true
        await authenticationViewModel.verifyEmail()
        #expect(authenticationViewModel.errorMessage == nil)
        
        #expect(authenticationViewModel.emailVerified == true)
        #expect(authenticationViewModel.isEmailVerificationActiveLogin == false)
        #expect(authenticationViewModel.isEmailVerificationActiveSignup == false)
        
        // check the user is in SwiftData
        users = try mockModelContext.fetch(FetchDescriptor<User>())
        #expect(users.count == 1)
    }
    
    @Test
    func testUploadReviewNoUser() async throws {
        // remove users if present
        let users = try self.mockModelContext.fetch(FetchDescriptor<User>())
        #expect(users.isEmpty)
        
        // call method
        await viewModel.uploadReview()
        
        // check error message not null
        #expect(viewModel.userReview == nil)
        #expect(viewModel.errorMessage != nil)
    }
    
    @Test
    func testUploadReview() async throws {
        // login a user
        try await loginUser()
        
        // select city
        viewModel.selectedCity = CityCompleterDataset(
            cityName: "Paris",
            countryName: "France",
            iata: "PAR",
            countryCode: "FR",
            continent: "Europe"
        )
        
        // set review data
        viewModel.reviewText = "text"
        viewModel.localTransportRating = 1
        viewModel.greenSpacesRating = 2
        viewModel.wasteBinsRating = 3
        
        // call method
        await viewModel.uploadReview()
        
        // check success
        #expect(viewModel.userReview != nil)
        #expect(viewModel.userReview?.reviewText == "text")
        #expect(viewModel.userReview?.localTransportRating == 1)
        #expect(viewModel.userReview?.greenSpacesRating == 2)
        #expect(viewModel.userReview?.wasteBinsRating == 3)
        #expect(viewModel.errorMessage == nil)
    }
    
    @Test
    func testModifyReviewNoReview() async {
        // no review present
        #expect(viewModel.userReview == nil)
        
        // call method
        await viewModel.modifyReview()
        
        // check failure
        #expect(viewModel.userReview == nil)
        #expect(viewModel.errorMessage != nil)
    }
    
    @Test
    func testModifyReview() async throws {
        // login a user
        try await loginUser()
        
        // select city
        viewModel.selectedCity = CityCompleterDataset(
            cityName: "Paris",
            countryName: "France",
            iata: "PAR",
            countryCode: "FR",
            continent: "Europe"
        )
        
        // set review data
        viewModel.reviewText = "text"
        viewModel.localTransportRating = 1
        viewModel.greenSpacesRating = 2
        viewModel.wasteBinsRating = 3
        
        // call method
        await viewModel.uploadReview()
        
        // check success
        #expect(viewModel.userReview != nil)
        #expect(viewModel.userReview?.reviewText == "text")
        #expect(viewModel.userReview?.localTransportRating == 1)
        #expect(viewModel.userReview?.greenSpacesRating == 2)
        #expect(viewModel.userReview?.wasteBinsRating == 3)
        #expect(viewModel.errorMessage == nil)
        
        // initially set userReview values
        viewModel.reviewText = viewModel.userReview!.reviewText
        viewModel.localTransportRating = viewModel.userReview!.localTransportRating
        viewModel.greenSpacesRating = viewModel.userReview!.greenSpacesRating
        viewModel.wasteBinsRating = viewModel.userReview!.wasteBinsRating
        
        // modify review
        viewModel.reviewText = "modified text"
        
        // call method
        await viewModel.modifyReview()
        
        // check success
        #expect(viewModel.userReview != nil)
        #expect(viewModel.userReview?.reviewText == "modified text")
        #expect(viewModel.userReview?.localTransportRating == 1)
        #expect(viewModel.userReview?.greenSpacesRating == 2)
        #expect(viewModel.userReview?.wasteBinsRating == 3)
        #expect(viewModel.errorMessage == nil)
    }
    
    @Test
    func testDeleteReviewNoReview() async {
        // no review present
        #expect(viewModel.userReview == nil)
        
        // call method
        await viewModel.deleteReview()
        
        // check failure
        #expect(viewModel.userReview == nil)
        #expect(viewModel.errorMessage != nil)
    }
    
    @Test
    func testDeleteReview() async throws {
        // login a user
        try await loginUser()
        
        // select city
        viewModel.selectedCity = CityCompleterDataset(
            cityName: "Paris",
            countryName: "France",
            iata: "PAR",
            countryCode: "FR",
            continent: "Europe"
        )
        
        // set review data
        viewModel.reviewText = "text"
        viewModel.localTransportRating = 1
        viewModel.greenSpacesRating = 2
        viewModel.wasteBinsRating = 3
        
        // call method
        await viewModel.uploadReview()
        
        // check success
        #expect(viewModel.userReview != nil)
        #expect(viewModel.userReview?.reviewText == "text")
        #expect(viewModel.userReview?.localTransportRating == 1)
        #expect(viewModel.userReview?.greenSpacesRating == 2)
        #expect(viewModel.userReview?.wasteBinsRating == 3)
        #expect(viewModel.errorMessage == nil)
        
        // call method
        await viewModel.deleteReview()
        
        // check deletion
        #expect(viewModel.userReview == nil)
        #expect(viewModel.errorMessage == nil)
    }
    
    @Test
    func testGetReviewsForSearchedCityUnsuccessful() async {
        // no review present
        
        viewModel.selectedCity = CityCompleterDataset(
            cityName: "Paris",
            countryName: "France",
            iata: "PAR",
            countryCode: "FR",
            continent: "Europe"
        )
        
        await viewModel.getSelectedCityReviewElement(reload: true)
        
        viewModel.selectedCityReviewElement = nil
        viewModel.searchedCityAvailable = false
    }
    
    @Test
    func testGetReviewsForSearchedCitySuccessful() async throws {
        // add review for Paris
        
        // login a user
        try await loginUser()
        
        // select city
        let cityParis = CityCompleterDataset(
            cityName: "Paris",
            countryName: "France",
            iata: "PAR",
            countryCode: "FR",
            continent: "Europe"
        )
        viewModel.selectedCity = cityParis
        
        // set review data
        viewModel.reviewText = "text"
        viewModel.localTransportRating = 1
        viewModel.greenSpacesRating = 2
        viewModel.wasteBinsRating = 3
        
        // call method
        await viewModel.uploadReview()
        
        // check success
        #expect(viewModel.userReview != nil)
        #expect(viewModel.userReview?.reviewText == "text")
        #expect(viewModel.userReview?.localTransportRating == 1)
        #expect(viewModel.userReview?.greenSpacesRating == 2)
        #expect(viewModel.userReview?.wasteBinsRating == 3)
        #expect(viewModel.errorMessage == nil)
        
        viewModel.selectedCity = cityParis
        
        await viewModel.getSelectedCityReviewElement(reload: false)
        
        #expect(viewModel.searchedCityAvailable == true)
        #expect(viewModel.selectedCityReviewElement != nil)
        #expect(viewModel.selectedCityReviewElement?.reviews.count == 1)
        
        let reviewElement = viewModel.selectedCityReviewElement!
        #expect(reviewElement.averageWasteBinsRating >= 0 && reviewElement.averageWasteBinsRating <= 5)
        #expect(reviewElement.averageGreenSpacesRating >= 0 && reviewElement.averageGreenSpacesRating <= 5)
        #expect(reviewElement.averageLocalTransportRating >= 0 && reviewElement.averageLocalTransportRating <= 5)
        
        let review = reviewElement.reviews.first!
        #expect(review.cityIata == viewModel.selectedCity.iata)
        #expect(review.countryCode == viewModel.selectedCity.countryCode)
        #expect(review.localTransportRating >= 0 && review.localTransportRating <= 5)
        #expect(review.greenSpacesRating >= 0 && review.greenSpacesRating <= 5)
        #expect(review.wasteBinsRating >= 0 && review.wasteBinsRating <= 5)
        #expect(review.cityIata == viewModel.selectedCity.iata)
        #expect(review.countryCode == viewModel.selectedCity.countryCode)
    }
    
    @Test
    func testGetBestReviewedCitiesSuccessful() async throws {
        // add review for Paris
        
        // login a user
        try await loginUser()
        
        // select city
        let cityParis = CityCompleterDataset(
            cityName: "Paris",
            countryName: "France",
            iata: "PAR",
            countryCode: "FR",
            continent: "Europe"
        )
        viewModel.selectedCity = cityParis
        
        // set review data
        viewModel.reviewText = "text"
        viewModel.localTransportRating = 1
        viewModel.greenSpacesRating = 2
        viewModel.wasteBinsRating = 3
        
        // call method
        await viewModel.uploadReview()
        
        // check success
        #expect(viewModel.userReview != nil)
        #expect(viewModel.userReview?.reviewText == "text")
        #expect(viewModel.userReview?.localTransportRating == 1)
        #expect(viewModel.userReview?.greenSpacesRating == 2)
        #expect(viewModel.userReview?.wasteBinsRating == 3)
        #expect(viewModel.errorMessage == nil)
        
        // add Paris city to SwiftData
        self.mockModelContext.insert(cityParis)
        try mockModelContext.save()
        
        // call method
        await viewModel.getBestReviewedCities()
        
        #expect(viewModel.bestCitiesReviewElements.count == 1)
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
    
}
