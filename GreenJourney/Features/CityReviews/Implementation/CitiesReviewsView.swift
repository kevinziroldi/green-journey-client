import SwiftUI
import SwiftData

struct CitiesReviewsView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
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
            if horizontalSizeClass == .compact {
                // iOS
                
                ScrollView {
                    // header
                    HStack {
                        // title
                        CitiesReviewsTitleView()
                        
                        Spacer()
                        
                        // user preferences button
                        UserPreferencesButtonView(navigationPath: $navigationPath, serverService: serverService, firebaseAuthService: firebaseAuthService)
                    }
                    .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                    
                    // city search
                    CitySearchView(viewModel: viewModel, searchTapped: $searchTapped)
                    
                    // cities the user has visited
                    ReviewableCitiesView(viewModel: viewModel)
                    
                    // best cities
                    BestCitiesTitle()
                    BestCitiesView(viewModel: viewModel, navigationPath: $navigationPath)
                }
            } else {
                // iPadOS
                
                ScrollView {
                    // header
                    CitiesReviewsTitleView()
                        .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                    
                    VStack {
                        // city search
                        CitySearchView(viewModel: viewModel, searchTapped: $searchTapped)
                        
                        Spacer()
                        
                        ReviewableCitiesView(viewModel: viewModel)
                        
                        Spacer()
                        
                        // best cities
                        BestCitiesTitle()
                        BestCitiesView(viewModel: viewModel, navigationPath: $navigationPath)
                    }
                    .frame(maxWidth: 800)
                    .padding(.horizontal)
                }
            }
        }
        .background(colorScheme == .dark ? AppColors.backColorDark : AppColors.backColorLight)
        .onChange(of: viewModel.searchedCityAvailable) {
            if viewModel.searchedCityAvailable {
                // append path of the inner view
                navigationPath.append(NavigationDestination.CityReviewsDetailsView(viewModel))
                viewModel.searchedCityAvailable = false
            }
        }
        .onAppear {
            Task {
                await viewModel.getBestReviewedCities()
                await viewModel.getReviewableCities()
            }
        }
    }
}

private struct CitiesReviewsTitleView: View {
    var body: some View {
        Text("Reviews")
            .font(.system(size: 32).bold())
            .padding()
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityIdentifier("citiesReviewsTitle")
    }
}

private struct CitySearchView: View {
    @ObservedObject var viewModel: CitiesReviewsViewModel
    @Binding var searchTapped: Bool
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        VStack {
            Text("Select a city")
                .font(.title)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 30)
                .accessibilityIdentifier("selectCityText")
            
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(AppColors.mainColor, lineWidth: 6)
                    .fill(Color(uiColor: .systemBackground))
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
            .padding(EdgeInsets(top: 0, leading: 30, bottom: 15, trailing: 30))
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
                    await viewModel.getSelectedCityReviewElement(reload: false)
                    searchTapped = false
                }
            },
                          departure: false
            )
        }
    }
}

struct ReviewableCitiesView: View {
    @ObservedObject var viewModel: CitiesReviewsViewModel
    var body: some View {
        VStack (spacing: 0) {
            Text ("Reviewable Cities")
                .font(.title)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 30)
                .accessibilityIdentifier("reviewableCitiesTitle")
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(viewModel.reviewableCities) { city in
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color(uiColor: .systemBackground))
                                .shadow(color: AppColors.mainColor.opacity(0.2), radius: 5, x: 0, y: 1)
                            VStack {
                                Text(city.cityName)
                                    .font(.headline)
                                    .scaledToFit()
                                    .minimumScaleFactor(0.6)
                                    .lineLimit(1)
                                Text(city.countryName)
                                    .fontWeight(.light)
                                    .scaledToFit()
                                    .minimumScaleFactor(0.6)
                                    .lineLimit(1)
                            }
                            .padding()
                        }
                        .onTapGesture {
                            Task {
                                viewModel.selectedCity = city
                                await viewModel.getSelectedCityReviewElement(reload: false)
                            }
                        }
                        .padding(.top, 15)
                        .padding(.horizontal, 5)
                        .padding(.bottom, 15)
                        .frame(width: 150, height: 100)
                        .overlay(Color.clear.accessibilityIdentifier("reviewableCityView_\(city.iata)_\(city.countryCode)"))
                    }
                }
                
            }
            .padding(.horizontal)
        }
    }
}

private struct BestCitiesTitle: View {
    var body: some View {
        Text("Top Cities")
            .font(.title)
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 30)
            .accessibilityIdentifier("topCitiesTitle")
    }
}

private struct BestCitiesView: View {
    @ObservedObject var viewModel: CitiesReviewsViewModel
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        // list of cities
        if viewModel.bestCities.isEmpty {
            CircularProgressView()
        }
        else {
            ForEach(viewModel.bestCities.indices, id: \.self) { index in
                BestCityView(city: viewModel.bestCities[index], cityReview: viewModel.bestCitiesReviewElements[index], pos: index+1, viewModel: viewModel)
                    .padding(.horizontal)
                    .onTapGesture {
                        viewModel.selectedCity = viewModel.bestCities[index]
                        viewModel.selectedCityReviewElement = viewModel.bestCitiesReviewElements[index]
                        viewModel.currentReviews = viewModel.bestCitiesReviewElements[index].reviews
                        viewModel.hasPrevious = viewModel.bestCitiesReviewElements[index].hasPrevious
                        viewModel.hasNext = viewModel.bestCitiesReviewElements[index].hasNext
                        
                        navigationPath.append(NavigationDestination.CityReviewsDetailsView(viewModel))
                    }
                    .overlay(Color.clear.accessibilityIdentifier("bestCityView_\(index)"))
            }
        }
    }
}

private struct BestCityView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var city: CityCompleterDataset
    var cityReview: CityReviewElement
    let pos: Int
    
    @ObservedObject var viewModel: CitiesReviewsViewModel
    @Query var users: [User]
    
    var body: some View {
        if horizontalSizeClass == .compact {
            // iOS
            
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(uiColor: .systemBackground))
                    .shadow(color: AppColors.mainColor.opacity(0.3), radius: 5, x: 0, y: 3)
                
                HStack {
                    ZStack {
                        Circle()
                            .fill(AppColors.mainColor.opacity(0.3))
                            .frame(width: 45, height: 45)
                        Text("\(pos)")
                            .foregroundStyle(AppColors.mainColor)
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
        } else {
            // iPadOS
            
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(uiColor: .systemBackground))
                    .shadow(color: AppColors.mainColor.opacity(0.3), radius: 5, x: 0, y: 3)
                
                HStack {
                    ZStack {
                        Circle()
                            .fill(AppColors.mainColor.opacity(0.3))
                            .frame(width: 45, height: 45)
                        Text("\(pos)")
                            .foregroundStyle(AppColors.mainColor)
                            .font(.system(size: 24))
                            .fontWeight(.semibold)
                    }
                    
                    VStack {
                        Text(city.cityName + ", " + city.countryName)
                            .font(.system(size: 18))
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.leading, 30)
                    
                    VStack {
                        HStack {
                            Text(String(format: "%.1f", cityReview.getAverageRating()))
                                .fontWeight(.bold)
                            FiveStarView(rating: cityReview.getAverageRating(), dim: 20, color: .yellow)
                            Spacer()
                        }
                        
                        Text("\(cityReview.numReviews) \(cityReview.numReviews == 1 ? "review" : "review")")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    Spacer()
                    
                    VStack {
                        if viewModel.hasVisited(city: city) {
                            Image(systemName: "mappin.and.ellipse.circle")
                                .foregroundColor(AppColors.mainColor)
                                .font(.system(size: 25))
                        }
                    }
                    
                }
                .padding()
            }
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: 800)
        }
    }
}
