import SwiftData
import Testing

@testable import GreenJourney

struct CitiesReviewsViewModelTest {
    @MainActor private var mockModelContext: ModelContext
    private var viewModel: CitiesReviewsViewModel
    
    @MainActor
    init() throws {
        // create model context
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let mockContainer = try ModelContainer(for: User.self, Travel.self, Segment.self, CityFeatures.self, CityCompleterDataset.self, configurations: configuration)
        self.mockModelContext = mockContainer.mainContext
        
        // create view model
        self.viewModel = CitiesReviewsViewModel(modelContext: self.mockModelContext)
        
        // add some cities to SwiftData
        try addCitiesToSwiftData()
        
        let result = try mockModelContext.fetch(FetchDescriptor<CityCompleterDataset>())
        print(result)
    }
    @MainActor
    private func addCitiesToSwiftData() throws {
        let cityBerlin = CityCompleterDataset(
            cityName: "Berlin",
            countryName: "Germany",
            iata: "BER",
            countryCode: "DE",
            continent: "Europe"
        )
        let cityParis = CityCompleterDataset(
            cityName: "Paris",
            countryName: "France",
            iata: "PAR",
            countryCode: "FR",
            continent: "Europe"
        )
        let cityRome = CityCompleterDataset(
            cityName: "Roma",
            countryName: "Italy",
            iata: "ROM",
            countryCode: "IT",
            continent: "Europe"
        )
        
        self.mockModelContext.insert(cityBerlin)
        self.mockModelContext.insert(cityParis)
        self.mockModelContext.insert(cityRome)
        try self.mockModelContext.save()
    }
    
    @Test
    func testGetReviewsForSearchedCity() async {
        viewModel.searchedCity = CityCompleterDataset(
            cityName: "Paris",
            countryName: "France",
            iata: "PAR",
            countryCode: "FR",
            continent: "Europe"
        )
        
        await viewModel.getReviewsForSearchedCity()
        
        #expect(viewModel.searchedCityAvailable == true)
        #expect(viewModel.searchedCityReviewElement != nil)
        
        let reviewElement = viewModel.searchedCityReviewElement!
        #expect(reviewElement.averageWasteBinsRating >= 0 && reviewElement.averageWasteBinsRating <= 5)
        #expect(reviewElement.averageGreenSpacesRating >= 0 && reviewElement.averageGreenSpacesRating <= 5)
        #expect(reviewElement.averageLocalTransportRating >= 0 && reviewElement.averageLocalTransportRating <= 5)
        #expect(reviewElement.countWasteBinsRating >= 0)
        #expect(reviewElement.countGreenSpacesRating >= 0)
        #expect(reviewElement.countLocalTransportRating >= 0)
    
        for review in reviewElement.reviews {
            #expect(review.localTransportRating >= 0 && review.localTransportRating <= 5)
            #expect(review.greenSpacesRating >= 0 && review.greenSpacesRating <= 5)
            #expect(review.wasteBinsRating >= 0 && review.wasteBinsRating <= 5)
            #expect(review.cityIata == viewModel.searchedCity.iata)
            #expect(review.countryCode == viewModel.searchedCity.countryCode)
            #expect(review.scoreShortDistance >= 0)
            #expect(review.scoreLongDistance >= 0)
        }
    }
    
    // TODO: se uso il model context creato nell'init non funziona! Errore a runtime!
    @Test
    @MainActor
    func testGetBestReviewedCities() async throws {
        // create model context
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let mockContainer = try ModelContainer(for: User.self, Travel.self, Segment.self, CityFeatures.self, CityCompleterDataset.self, configurations: configuration)
        let mockModelContext = mockContainer.mainContext
        
        let viewModel = CitiesReviewsViewModel(modelContext: mockModelContext)
        
        let cityBerlin = CityCompleterDataset(
            cityName: "Berlin",
            countryName: "Germany",
            iata: "BER",
            countryCode: "DE",
            continent: "Europe"
        )
        let cityParis = CityCompleterDataset(
            cityName: "Paris",
            countryName: "France",
            iata: "PAR",
            countryCode: "FR",
            continent: "Europe"
        )
        let cityRome = CityCompleterDataset(
            cityName: "Roma",
            countryName: "Italy",
            iata: "ROM",
            countryCode: "IT",
            continent: "Europe"
        )
        mockModelContext.insert(cityBerlin)
        mockModelContext.insert(cityParis)
        mockModelContext.insert(cityRome)
        try mockModelContext.save()
     
        // check cities present
        let citiesSwiftData = try mockModelContext.fetch(FetchDescriptor<CityCompleterDataset>())
        #expect(citiesSwiftData.count == 3)
        
        await viewModel.getBestReviewedCities()
        
        #expect(viewModel.bestCitiesReviewElements.count <= 5)
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
