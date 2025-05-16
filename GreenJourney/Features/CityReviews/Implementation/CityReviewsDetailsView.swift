import SwiftUI
import SwiftData
import Charts

struct CityReviewsDetailsView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    @Query var users: [User]
    @ObservedObject var viewModel: CitiesReviewsViewModel
    @Binding var navigationPath: NavigationPath
    @State var infoTapped = false
    @State var reviewTapped = false
    @State var isPresenting = false
    
    var body: some View {
        if let selectedCityReviewElement = viewModel.selectedCityReviewElement {
            VStack {
                if horizontalSizeClass == .compact {
                    // iOS
                    
                    ScrollView {
                        VStack {
                            VStack(spacing: 0) {
                                // title
                                CityReviewsTitleView(viewModel: viewModel)
                                    .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                                
                                // reviews average
                                ReviewsAverageView(selectedCityReviewElement: selectedCityReviewElement, viewModel: viewModel,  infoTapped: $infoTapped, navigationPath: $navigationPath, isPresenting: $isPresenting)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical)
                                
                                // button or user review
                                if viewModel.isReviewable() || viewModel.userReview != nil {
                                    InsertReviewButtonView(viewModel: viewModel, reviewTapped: $reviewTapped, isPresenting: $isPresenting)
                                        .padding(.horizontal)
                                        .padding(.vertical)
                                }
                                
                                // latest reviews, if present
                                LatestReviewsView(viewModel: viewModel, selectedCityReviewElement: selectedCityReviewElement, navigationPath: $navigationPath, isPresenting: $isPresenting)
                            }
                        }
                    }
                } else {
                    // iPadOS
                    
                    ScrollView {
                        HStack {
                            Spacer()
                            VStack {
                                VStack(spacing: 0) {
                                    // title
                                    CityReviewsTitleView(viewModel: viewModel)
                                        .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                                    
                                    // reviews average
                                    ReviewsAverageView(selectedCityReviewElement: selectedCityReviewElement, viewModel: viewModel,  infoTapped: $infoTapped, navigationPath: $navigationPath, isPresenting: $isPresenting)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical)
                                    
                                    // button or user review
                                    if viewModel.isReviewable() || viewModel.userReview != nil {
                                        InsertReviewButtonView(viewModel: viewModel, reviewTapped: $reviewTapped, isPresenting: $isPresenting)
                                            .padding(.horizontal)
                                            .padding(.vertical)
                                    }
                                    
                                    // latest reviews, if present
                                    LatestReviewsView(viewModel: viewModel, selectedCityReviewElement: selectedCityReviewElement, navigationPath: $navigationPath, isPresenting: $isPresenting)
                                }
                            }
                            .frame(maxWidth: 800)
                            Spacer()
                        }
                    }
                }
            }
            .alert(isPresented: $viewModel.errorOccurred) {
                Alert(
                    title: Text("Something went wrong 😞"),
                    message: Text("Try again later"),
                    dismissButton: .default(Text("Continue")) {viewModel.errorOccurred = false}
                )
            }
            .background(colorScheme == .dark ? AppColors.backColorDark : AppColors.backColorLight)
            .sheet(isPresented: $reviewTapped, onDismiss: {isPresenting = false}) {
                InsertReviewView(isPresented: $reviewTapped, viewModel: viewModel, isPresenting: $isPresenting)
                    .presentationDetents([.height(680)])
                    .presentationCornerRadius(15)
            }
            .sheet(isPresented: $infoTapped, onDismiss: {isPresenting = false}) {
                InfoReviewView(isPresented: $infoTapped)
                    .presentationDetents([.fraction(0.75)])
                    .presentationCornerRadius(15)
                    .overlay(Color.clear.accessibilityIdentifier("infoReviewView"))
            }
            .onAppear(){
                isPresenting = false
                Task {
                    viewModel.getUserReview(userID: users.first?.userID ?? -1)
                }
            }
        }
    }
}

private struct CityReviewsTitleView: View {
    var viewModel: CitiesReviewsViewModel
    
    var body: some View {
        HStack {
            Text(viewModel.flag(country: viewModel.selectedCity.countryCode))
                .font(.system(size: 80))
                .foregroundColor(.blue)
            Text(viewModel.selectedCity.cityName + ", " + viewModel.selectedCity.countryName)
                .font(.system(size: 32).bold())
                .padding(.horizontal)
                .fontWeight(.semibold)
                .accessibilityIdentifier("selecteCityTitle")
            Spacer()
        }
    }
}

private struct ReviewsAverageView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var selectedCityReviewElement: CityReviewElement
    @ObservedObject var viewModel: CitiesReviewsViewModel
    @Binding var infoTapped: Bool
    @Binding var navigationPath: NavigationPath
    @Binding var isPresenting: Bool
    
    var body: some View {
        if horizontalSizeClass == .compact {
            // iOS
            
            VStack {
                HStack {
                    Text("Average Rating")
                        .font(.title)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Button(action: {
                        if !isPresenting{
                            isPresenting = true
                            infoTapped = true
                        }
                    }){
                        Image(systemName: "info.circle")
                            .font(.title3)
                    }
                    .accessibilityIdentifier("infoReviewButton")
                }
                
                HStack {
                    VStack (spacing: 10) {
                        HStack {
                            Text(String(format: "%.1f", selectedCityReviewElement.getAverageRating()))
                                .font(.system(size: 60).bold())
                                .fontWeight(.semibold)
                                .foregroundStyle(AppColors.mainColor)
                            Spacer()
                        }
                        
                        HStack {
                            FiveStarView(rating: selectedCityReviewElement.getAverageRating(), dim: 15, color: Color.yellow)
                            Spacer()
                        }
                        
                        HStack {
                            Button(action: {
                                if !isPresenting {
                                    isPresenting = true
                                    // reset reviews list
                                    viewModel.currentReviews = selectedCityReviewElement.reviews
                                    viewModel.hasPrevious = selectedCityReviewElement.hasPrevious
                                    viewModel.hasNext = selectedCityReviewElement.hasNext
                                    
                                    // navigate
                                    navigationPath.append(NavigationDestination.AllReviewsView(viewModel))
                                }
                            }) {
                                HStack {
                                    Text("\(selectedCityReviewElement.numReviews)")
                                        .bold()
                                        .foregroundStyle(Color.primary) +
                                    Text("\(selectedCityReviewElement.numReviews == 1 ? " review" : " reviews")")
                                        .foregroundStyle(Color.primary)
                                }
                            }
                            Spacer()
                        }
                    }
                    .fixedSize()
                    
                    VStack {
                        RatingBarRow(symbolName: "bus", rating: selectedCityReviewElement.averageLocalTransportRating)
                        RatingBarRow(symbolName: "tree", rating: selectedCityReviewElement.averageGreenSpacesRating)
                        RatingBarRow(symbolName: "trash", rating: selectedCityReviewElement.averageWasteBinsRating)
                    }
                    .padding(.leading, 30)
                }
            }
            .overlay(Color.clear.accessibilityIdentifier("averageRatingSection"))
            
        } else {
            // iPadOS
            
            VStack(spacing: 0) {
                HStack {
                    Text("Average Rating")
                        .font(.title)
                        .fontWeight(.semibold)
                    
                    Button(action: {
                        infoTapped = true
                    }){
                        Image(systemName: "info.circle")
                            .font(.title3)
                    }
                    .accessibilityIdentifier("infoReviewButton")
                    Spacer()
                }
                HStack (spacing: 30) {
                    Spacer()
                    
                    Text(String(format: "%.1f", selectedCityReviewElement.getAverageRating()))
                        .font(.system(size: 100).bold())
                        .fontWeight(.semibold)
                        .foregroundStyle(AppColors.mainColor)
                        .scaledToFit()
                        .minimumScaleFactor(0.7)
                    
                    VStack {
                        FiveStarView(rating: selectedCityReviewElement.getAverageRating(), dim: 35, color: Color.yellow)
                        Button(action: {
                            if !isPresenting {
                                isPresenting = true
                                // reset reviews list
                                viewModel.currentReviews = selectedCityReviewElement.reviews
                                viewModel.hasPrevious = selectedCityReviewElement.hasPrevious
                                viewModel.hasNext = selectedCityReviewElement.hasNext
                                
                                // navigate
                                navigationPath.append(NavigationDestination.AllReviewsView(viewModel))
                            }
                        }) {
                            Text("\(selectedCityReviewElement.numReviews)")
                                .bold()
                                .foregroundStyle(AppColors.mainColor) +
                            Text("\(selectedCityReviewElement.numReviews == 1 ? " review" : " reviews")")
                                .foregroundStyle(AppColors.mainColor)
                            
                        }
                    }
                    
                    Spacer()
                    
                    VStack {
                        RatingBarRow(symbolName: "bus", rating: selectedCityReviewElement.averageLocalTransportRating)
                        RatingBarRow(symbolName: "tree", rating: selectedCityReviewElement.averageGreenSpacesRating)
                        RatingBarRow(symbolName: "trash", rating: selectedCityReviewElement.averageWasteBinsRating)
                    }
                    .frame(maxWidth: 400)
                    
                    Spacer()
                }
                .padding(.vertical, 10)
                .padding(.top)
                .frame(maxWidth: .infinity, alignment: .leading)
                
            }
            .overlay(Color.clear.accessibilityIdentifier("averageRatingSection"))
        }
    }
}

private struct LatestReviewsView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var viewModel: CitiesReviewsViewModel
    var selectedCityReviewElement: CityReviewElement
    @Binding var navigationPath: NavigationPath
    @Binding var isPresenting: Bool
    
    var body: some View {
        VStack {
            if !selectedCityReviewElement.reviews.isEmpty {
                Text("Latest Reviews")
                    .font(.title)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityIdentifier("latestReviewsTitle")
                
                // latest reviews
                if horizontalSizeClass == .compact {
                    CarouselView(reviews: selectedCityReviewElement.getFirstReviews(num: 5))
                        .frame(height: 250)
                } else {
                    VStack {
                        ReviewsBlocksView(reviews: selectedCityReviewElement.getFirstReviews(num: 6))
                    }
                }
                
                // button to see all reviews
                Button(action: {
                    if !isPresenting {
                        isPresenting = true
                        // reset reviews list
                        viewModel.currentReviews = selectedCityReviewElement.reviews
                        viewModel.hasPrevious = selectedCityReviewElement.hasPrevious
                        viewModel.hasNext = selectedCityReviewElement.hasNext
                        
                        // navigate
                        navigationPath.append(NavigationDestination.AllReviewsView(viewModel))
                    }
                }){
                    Text("See all reviews")
                        .foregroundStyle(AppColors.mainColor)
                        .fontWeight(.semibold)
                        .padding(10)
                }
                .padding()
                .accessibilityIdentifier("allReviewsButton")
            }
            else {
                Text("There are no reviews yet for " + viewModel.selectedCity.cityName + ", " + viewModel.selectedCity.countryName + ".")
                    .font(.system(size: 15))
                    .fontWeight(.light)
                    .padding(.top, 40)
                    .accessibilityIdentifier("noReviewsText")
            }
        }
        .padding(.top, 5)
    }
}

private struct CarouselView: View {
    var reviews: [Review]
    let width: CGFloat = UIScreen.main.bounds.width * 0.7
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(reviews) { review in
                    CardView(review: review, width: width)
                        .containerRelativeFrame(.horizontal, count: 1, spacing: 15)
                        .scrollTransition{ content, phase in
                            content
                                .opacity(phase.isIdentity ? 1 : 0.8)
                        }
                        .overlay(Color.clear.accessibilityIdentifier("reviewElement_\(review.reviewID ?? -1)"))
                }
            }
            .scrollTargetLayout()
        }
        .contentMargins(50, for: .scrollContent)
        .scrollTargetBehavior(.viewAligned)
    }
}

private struct CardView: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    let review: Review
    let width: CGFloat
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(colorScheme == .dark ? AppColors.blockColorDark: Color(uiColor: .systemBackground))
                .shadow(radius: 3, x: 0, y: 3)
            
            VStack (spacing: 0){
                Text(review.firstName + " " + review.lastName)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.blue.opacity(0.8))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(review.dateTime.formatted(date: .numeric, time: .omitted))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 5)
                    .fontWeight(.light)
                    .font(.subheadline)
                HStack {
                    Text(String(format: "%.1f", review.computeRating()))
                        .font(.title3)
                        .fontWeight(.semibold)
                        .padding(EdgeInsets(top: 4, leading: 0, bottom: 0, trailing: 5))
                    FiveStarView(rating: review.computeRating(), dim: 20, color: Color.yellow)
                    Spacer()
                }
                .padding(.bottom, 5)
                
                Text(review.reviewText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.body)
                    .padding(.top, 5)
                Spacer()
                DetailedRatingsView(review: review)
            }
            .padding()
        }
        .frame(maxWidth: width, minHeight: 250)
    }
}

private struct ReviewsBlocksView: View {
    var reviews: [Review]
    @State private var availableWidth: CGFloat = 0
    
    var body: some View {
        LazyVGrid(
            columns: Array(
                repeating: GridItem(.flexible(), spacing: 10),
                count: availableWidth > 750 ? 3 : 2
            ),
            spacing: 10
        ) {
            ForEach(reviews.prefix(6), id: \.id) { review in
                let spacing: CGFloat = 10
                let columnsCount = availableWidth > 750 ? 3 : 2
                let cardWidth = (availableWidth - 40 - spacing * CGFloat(columnsCount)) / CGFloat(columnsCount)
                // ternary operator needed because at start width is 0
                CardView(review: review, width: cardWidth > 0 ? cardWidth : 1)
                    .frame(maxHeight: 270)
                    .overlay(Color.clear.accessibilityIdentifier("reviewElement_\(review.reviewID ?? -1)"))
            }
        }
        .padding(.horizontal, 20)
        .background(
            GeometryReader { geo in
                Color.clear
                    .onAppear {
                        availableWidth = geo.size.width
                    }
                    .onChange(of: geo.size.width) {
                        availableWidth = geo.size.width
                    }
            }
        )
    }
}

private struct InfoReviewView: View {
    @Binding var isPresented: Bool
    var body: some View {
        HStack {
            Spacer()
            Button(action: {
                isPresented = false
            }) {
                Text("Done")
                    .fontWeight(.bold)
            }
            .accessibilityIdentifier("infoReviewCloseButton")
        }
        .padding(.top)
        .padding(.horizontal)
        
        ScrollView {
            VStack {
                HStack {
                    Image(systemName: "bus")
                        .resizable()
                        .frame(width: 30, height: 30)
                    Text("Public Transport Efficiency")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .scaledToFit()
                        .lineLimit(1)
                    Spacer()
                }
                .padding(.bottom, 5)
                Text("This score evaluates the availability and effectiveness of public transport in reducing Co2 emissions. A well-connected and eco-friendly transit system makes the city more sustainable.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack {
                    Image(systemName: "tree")
                        .resizable()
                        .frame(width: 30, height: 30)
                    Text("Green Spaces")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .scaledToFit()
                        .lineLimit(1)
                    Spacer()
                }
                .padding(.top, 30)
                .padding(.bottom, 5)
                Text("This rating reflects the quantity and quality of parks, gardens, and other green areas in the city. More green spaces mean a healthier environment and a better urban experience.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack {
                    Image(systemName: "trash")
                        .resizable()
                        .frame(width: 30, height: 30)
                    Text("Cleanliness & Recycling")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .scaledToFit()
                        .lineLimit(1)
                    Spacer()
                }
                .padding(.top, 30)
                .padding(.bottom, 5)
                Text("This rating measures the presence of recycling bins and the overall cleanliness of the city. A well-maintained urban environment contributes to a greener and more pleasant place to live and visit.")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.bottom)
            .padding(.horizontal)
            .overlay(Color.clear.accessibilityIdentifier("infoReviewContent"))
        }
    }
}

private struct RatingBarRow: View {
    let symbolName: String
    let rating: Double
    
    var body: some View {
        HStack {
            Image(systemName: symbolName)
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .foregroundColor(.primary)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 15)
                        .cornerRadius(10)
                    
                    Rectangle()
                        .fill(AppColors.mainColor)
                        .frame(width: CGFloat(rating / 5.0) * geometry.size.width, height: 15)
                        .cornerRadius(10)
                }
            }
            .frame(height: 15)
            .padding(.horizontal, 5)
            
            Text(String(format: "%.1f", rating))
                .font(.title3)
                .fontWeight(.regular)
            
            Spacer()
        }
        .frame(height: 40)
    }
}
