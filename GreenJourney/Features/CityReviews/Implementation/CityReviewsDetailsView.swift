import SwiftUI

struct CityReviewsDetailsView: View {
    @ObservedObject var viewModel: CitiesReviewsViewModel
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        VStack {
            if let selectedCityIndex = viewModel.selectedCityIndex {
                // get city and cityReviewElement
                let (city, cityReviewElement) = getCityAndReviewElement(selectedCityIndex: selectedCityIndex)
                
                VStack {
                    Text(city.cityName)
                    Text(String(cityReviewElement.averageLocalTransportRating))
                    Text(String(cityReviewElement.averageGreenSpacesRating))
                    Text(String(cityReviewElement.averageWasteBinsRating))
                }
            }
        }
    }
    
    private func getCityAndReviewElement(selectedCityIndex: Int) -> (CityCompleterDataset, CityReviewElement) {
        if selectedCityIndex < 0 {
            return (viewModel.searchedCity, viewModel.searchedCityReviewElement ?? CityReviewElement())
        } else {
            return (viewModel.bestCities[selectedCityIndex], viewModel.bestCitiesReviewElements[selectedCityIndex])
        }
    }
}
