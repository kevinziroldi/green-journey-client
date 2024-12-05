import SwiftUI
import SwiftData

struct CitiesReviewsView: View {
    @EnvironmentObject var viewModel: CitiesReviewsViewModel
    @Binding var navigationPath: NavigationPath
    @State private var searchTapped: Bool = false
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            
            // header
            HStack {
                Text("City reviews")
                    .font(.title)
                    .padding()
                Spacer()
                
                NavigationLink(destination: UserPreferencesView(navigationPath: $navigationPath)) {
                    Image(systemName: "person")
                        .font(.title)
                }
            }
            .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
            
            // city search
            VStack {
                Text("Select a city")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(EdgeInsets(top: 10, leading: 50, bottom: 0, trailing: 50))
                    .frame(alignment: .top)
                    .font(.title)
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(colorScheme == .dark ? Color.white.opacity(0.6) : Color.black.opacity(0.6), lineWidth: 3)
                        .frame(height: 50)
                    
                    Button(action: {
                        searchTapped = true
                    }) {
                        Text(viewModel.searchedCity.cityName == "" ? "Search city" : viewModel.searchedCity.cityName)
                            .foregroundColor(viewModel.searchedCity.cityName == "" ? .secondary : .blue)
                            .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 0))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.title2)
                            .fontWeight(viewModel.searchedCity.cityName == "" ? .light : .semibold)
                    }
                }
                .background(colorScheme == .dark ? Color(red: 48/255, green: 48/255, blue: 48/255) : Color.white)
                .cornerRadius(10)
                .shadow(radius: 5)
                .padding(EdgeInsets(top: 0, leading: 50, bottom: 20, trailing: 50))
            }
            .fullScreenCover(isPresented: $searchTapped ) {
                CompleterView(searchText: viewModel.searchedCity.cityName,
                              onBack: {
                    searchTapped = false
                },
                              onClick: { city in
                    searchTapped = false
                    // for server call
                    viewModel.searchedCity = city
                    // for details view
                    viewModel.selectedCity = viewModel.searchedCity
                    viewModel.selectedCityReviewElement = viewModel.searchedCityReviewElement
                }
                )
            }
            
            Button(action: {
                viewModel.getReviewsForSearchedCity()
                
                // append path of the next view
                navigationPath.append(NavigationDestination.CityReviewsDetailsView)
                
                }) {
                Text("Search")
                    .font(.title3)
                    .foregroundStyle(.white)
            }
            .buttonStyle(.borderedProminent)
             
            // list of cities
            List(viewModel.bestCities.indices, id: \.self) { index in
                VStack(alignment: .leading) {
                    Text(viewModel.bestCities[index].cityName)
                        .font(.headline)
                        .onTapGesture {
                            viewModel.selectedCity = viewModel.bestCities[index]
                            viewModel.selectedCityReviewElement = viewModel.bestCitiesReviewElements[index]
                            navigationPath.append(NavigationDestination.CityReviewsDetailsView)
                        }
                }
            }
        }
        .onAppear {
            viewModel.searchedCity.cityName = ""
            viewModel.getBestReviewedCities()
        }
    }
}
