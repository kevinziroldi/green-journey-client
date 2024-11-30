import SwiftUI

struct CityReviewsDetailsView: View {
    @ObservedObject var viewModel: CitiesReviewsViewModel
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        VStack {
            if let selectedCity = viewModel.selectedCity {
                if let selectedCityReviewElement = viewModel.selectedCityReviewElement {
                    VStack {
                        Text(selectedCity.cityName)
                        Text(String(selectedCityReviewElement.averageLocalTransportRating))
                        Text(String(selectedCityReviewElement.averageGreenSpacesRating))
                        Text(String(selectedCityReviewElement.averageWasteBinsRating))
                    }
                }
            }
        }
    }
}
