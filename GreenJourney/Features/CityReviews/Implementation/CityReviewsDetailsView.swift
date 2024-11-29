import SwiftUI

struct CityReviewsDetailsView: View {
    @ObservedObject var viewModel: CitiesReviewsViewModel
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        VStack {
            if let selectedCityIndex = viewModel.selectedCityIndex {
                if selectedCityIndex < 0 {
                    Text(viewModel.searchedCity.cityName)
                } else {
                    VStack {
                        Text(viewModel.bestCities[selectedCityIndex].cityName)
                        Text(String(viewModel.bestCitiesReviewElements[selectedCityIndex].averageLocalTransportRating))
                        Text(String(viewModel.bestCitiesReviewElements[selectedCityIndex].averageGreenSpacesRating))
                        Text(String(viewModel.bestCitiesReviewElements[selectedCityIndex].averageWasteBinsRating))
                    }
                }
            }
            
        }
    }
}
