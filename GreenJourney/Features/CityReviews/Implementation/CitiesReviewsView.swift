import SwiftUI
import SwiftData

struct CitiesReviewsView: View {
    @StateObject var viewModel: CitiesReviewsViewModel
    @Environment(\.modelContext) private var modelContext
    private var serverService: ServerServiceProtocol
    private var firebaseAuthService: FirebaseAuthServiceProtocol
    
    @Binding var navigationPath: NavigationPath
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    @State private var searchTapped: Bool = false

    init(modelContext: ModelContext, navigationPath: Binding<NavigationPath>, serverService: ServerServiceProtocol, firebaseAuthService: FirebaseAuthServiceProtocol) {
        _viewModel = StateObject(wrappedValue: CitiesReviewsViewModel(modelContext: modelContext, serverService: serverService))
        _navigationPath = navigationPath
        self.serverService = serverService
        self.firebaseAuthService = firebaseAuthService
    }
    
    var body: some View {
        VStack {
            
            // header
            HStack {
                Text("City reviews")
                    .font(.title)
                    .padding()
                Spacer()
                
                NavigationLink(destination: UserPreferencesView(modelContext: modelContext, navigationPath: $navigationPath, serverService: serverService, firebaseAuthService: firebaseAuthService)) {
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
                    // for server call
                    viewModel.searchedCity = city
                    // for details view
                    viewModel.selectedCity = viewModel.searchedCity
                }
                )
            }
            
            Button(action: {
                Task {
                    await viewModel.getReviewsForSearchedCity()
                }
            }) {
                Text("Search")
                    .font(.title3)
                    .foregroundStyle(.white)
            }
            .disabled(viewModel.searchedCity.cityName == "")
            .buttonStyle(.borderedProminent)
            
            Spacer()
            // list of cities
            
            Text("Top Cities")
                .font(.title2)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 30)
            
            ForEach(viewModel.bestCities.indices, id: \.self) { index in
                BestCityView(city: viewModel.bestCities[index], cityReview: viewModel.bestCitiesReviewElements[index])
                    .padding(.horizontal)
                    .onTapGesture {
                        viewModel.selectedCity = viewModel.bestCities[index]
                        viewModel.selectedCityReviewElement = viewModel.bestCitiesReviewElements[index]
                        navigationPath.append(NavigationDestination.CityReviewsDetailsView(viewModel))
                    }
                
            }
            
            Spacer()
        }
        .onAppear {
            Task {
                await viewModel.getBestReviewedCities()
            }
        }
        .onChange(of: viewModel.searchedCityAvailable) {
            if viewModel.searchedCityAvailable {
                // append path of the inner view
                navigationPath.append(NavigationDestination.CityReviewsDetailsView(viewModel))
                viewModel.searchedCityAvailable = false
            }
        }
        .background(.green.opacity(0.1))
    }
}



struct BestCityView: View {
    var city: CityCompleterDataset
    var cityReview: CityReviewElement
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: .green.opacity(0.3), radius: 5, x: 0, y: 3)
            HStack {
                Text(city.cityName)
                    .font(.system(size: 17))
                    .fontWeight(.semibold)
                Spacer()
                Text(String(format: "%.1f", cityReview.getAverageRating()))
                    .fontWeight(.bold)
                FiveStarView(rating: cityReview.getAverageRating(), dim: 20, color: .yellow)
            }
            .padding()
            
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(.horizontal)
    }
}
