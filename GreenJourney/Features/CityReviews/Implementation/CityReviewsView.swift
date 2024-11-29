import SwiftUI
import SwiftData

struct CityReviewsView: View {
    @StateObject var viewModel: CityReviewsViewModel
    @Binding var navigationPath: NavigationPath
    @State private var searchTapped: Bool = false
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
    
    init(modelContext: ModelContext, navigationPath: Binding<NavigationPath>) {
        _viewModel = StateObject(wrappedValue: CityReviewsViewModel(modelContext: modelContext))
        _navigationPath = navigationPath
    }
    
    var body: some View {
        VStack {
            
            // header
            
            HStack {
                Text("City reviews")
                    .font(.title)
                    .padding()
                Spacer()
                
                Button(action: {
                    navigationPath.append(NavigationDestination.UserPreferencesView)
                }) {
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
                CompleterView(modelContext: modelContext, searchText: viewModel.searchedCity.cityName,
                              onBack: {
                    searchTapped = false
                },
                              onClick: { city in
                    searchTapped = false
                    viewModel.searchedCity = city
                }
                )
            }
            
            Button(action: {
                viewModel.getReviewsForSearchedCity()
                
                // TODO
                // append path of the next view
                //navigationPath.append(NavigationDestination.TravelOptionsView)
                
                }) {
                Text("Search")
                    .font(.title3)
                    .foregroundStyle(.white)
            }
            .buttonStyle(.borderedProminent)
             
            // list of cities
           
            List(viewModel.bestCities) { city in
                VStack(alignment: .leading) {
                    Text(city.cityName)
                        .font(.headline)
                }
            }
        }
        .onAppear {
            viewModel.getBestReviewedCities()
        }
    }
}
