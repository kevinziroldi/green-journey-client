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
                Text("Reviews")
                    .font(.system(size: 32).bold())
                    .padding()
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityIdentifier("citiesReviewsTitle")
                
                Spacer()
                
                NavigationLink(destination: UserPreferencesView(modelContext: modelContext, navigationPath: $navigationPath, serverService: serverService, firebaseAuthService: firebaseAuthService)) {
                    Image(systemName: "person")
                        .font(.title)
                        .foregroundStyle(AppColors.mainGreen)
                }
                .accessibilityIdentifier("userPreferencesButton")
            }
            .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
            ScrollView {
                // city search
                VStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(colorScheme == .dark ? Color.white.opacity(0.6) : Color.black.opacity(0.6), lineWidth: 3)
                            .frame(height: 50)
                        
                        Button(action: {
                            searchTapped = true
                        }) {
                            Text("Search city")
                                .foregroundColor(.secondary)
                                .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 0))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.title2)
                                .fontWeight(.light)
                        }
                        .accessibilityIdentifier("searchCityReviews")
                    }
                    .background(colorScheme == .dark ? Color(red: 48/255, green: 48/255, blue: 48/255) : Color.white)
                    .cornerRadius(10)
                    .padding(EdgeInsets(top: 0, leading: 30, bottom: 50, trailing: 30))
                }
                .fullScreenCover(isPresented: $searchTapped ) {
                    CompleterView(modelContext: modelContext, searchText: "",
                                  onBack: {
                        searchTapped = false
                    },
                                  onClick: { city in
                        Task {
                            // for server call
                            viewModel.selectedCity = city
                            // for details view
                            viewModel.selectedCity = viewModel.selectedCity
                            await viewModel.getReviewsForSearchedCity()
                            searchTapped = false
                        }
                    },
                                  departure: false
                    )
                }
                
                Spacer()
                
                // list of cities
                Text("Top Cities")
                    .font(.title)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 30)
                    .accessibilityIdentifier("topCitiesTitle")
                if viewModel.bestCities.isEmpty {
                    CircularProgressView()
                }
                else {
                    ForEach(viewModel.bestCities.indices, id: \.self) { index in
                        BestCityView(city: viewModel.bestCities[index], cityReview: viewModel.bestCitiesReviewElements[index], pos: index+1)
                            .padding(.horizontal)
                            .onTapGesture {
                                viewModel.selectedCity = viewModel.bestCities[index]
                                viewModel.selectedCityReviewElement = viewModel.bestCitiesReviewElements[index]
                                navigationPath.append(NavigationDestination.CityReviewsDetailsView(viewModel))
                            }
                            .overlay(Color.clear.accessibilityIdentifier("bestCityView_\(index)"))
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
        }
    }
}



struct BestCityView: View {
    var city: CityCompleterDataset
    var cityReview: CityReviewElement
    let pos: Int
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: .green.opacity(0.3), radius: 5, x: 0, y: 3)
            HStack {
                
                ZStack {
                    Circle()
                        .fill(AppColors.mainGreen.opacity(0.3))
                        .frame(width: 45, height: 45)
                    Text("\(pos)")
                        .foregroundStyle(AppColors.mainGreen)
                        .font(.system(size: 24))
                        .fontWeight(.semibold)
                }
                VStack {
                    Text(city.cityName + ", " + city.countryName)
                        .font(.system(size: 18))
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    HStack {
                        Text(String(format: "%.1f", cityReview.getAverageRating()))
                            .fontWeight(.bold)
                        FiveStarView(rating: cityReview.getAverageRating(), dim: 20, color: .yellow)
                        Spacer()
                    }
                    Spacer()
                }
                .padding(.leading, 30)
            }
            .padding()
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(.horizontal)
    }
}
