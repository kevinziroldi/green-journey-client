import SwiftData
import Testing

@testable import GreenJourney

struct CitiesReviewsViewModelTest {
    private var mockModelContext: ModelContext
    private var viewModel: CitiesReviewsViewModel
    
    @MainActor
    init() throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let mockContainer = try ModelContainer(for: User.self, Travel.self, Segment.self, CityFeatures.self, CityCompleterDataset.self, configurations: configuration)
        self.mockModelContext = mockContainer.mainContext
        self.viewModel = CitiesReviewsViewModel(modelContext: self.mockModelContext)
    }
    
    @Test
    func testGetReviewsForSearchedCity() async {
        viewModel.searchedCity = CityCompleterDataset(
            city: "Paris",
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
    
    // TODO problema non ho le città caricate
    // se uso il db vero, lo stroio 
    /*
    @Test
    func testGetBestReviewedCities() async {
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
    */
}
