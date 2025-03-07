import SwiftUI
import SwiftData

struct CityReviewsDetailsView: View {
    @Query var users: [User]
    @ObservedObject var viewModel: CitiesReviewsViewModel
    @Binding var navigationPath: NavigationPath
    @State var infoTapped = false
    @State var reviewTapped = false
    
    var body: some View {
        if let selectedCityReviewElement = viewModel.selectedCityReviewElement {
                ScrollView {
                    VStack {
                        // title
                        CityReviewsTitleView(viewModel: viewModel)
                        
                        // reviews average
                        ReviewsAverageView(selectedCityReviewElement: selectedCityReviewElement)
                        
                        // button or user review
                        if viewModel.isReviewable(userID: users.first?.userID ?? -1) {
                            InsertReviewButtonView(viewModel: viewModel, reviewTapped: $reviewTapped)
                        }
                        
                        // latest reviews, if present
                        LatestReviewsView(viewModel: viewModel, selectedCityReviewElement: selectedCityReviewElement, navigationPath: $navigationPath)
                    }
                    .padding()
                }
                .sheet(isPresented: $reviewTapped) {
                    InsertReviewView(isPresented: $reviewTapped, viewModel: viewModel)
                        .presentationDetents([.height(680)])
                        .presentationCornerRadius(30)
                }
                .onAppear(){
                    Task {
                        viewModel.getUserReview(userID: users.first?.userID ?? -1)
                    }
                }
        }
    }
}

struct CityReviewsTitleView: View {
    var viewModel: CitiesReviewsViewModel
    
    var body: some View {
        Text(viewModel.selectedCity.cityName + ", " + viewModel.selectedCity.countryName)
            .font(.system(size: 32).bold())
            .padding()
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityIdentifier("selecteCityTitle")
    }
}

struct ReviewsAverageView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var selectedCityReviewElement: CityReviewElement
    @State var infoTapped = false
    
    var body: some View {
        if horizontalSizeClass == .compact {
            // iOS
            
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(uiColor: .systemBackground))
                    .shadow(color: .green.opacity(0.3), radius: 5, x: 0, y: 3)
                VStack{
                    HStack {
                        Text("Ratings")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text(String(format: "%.1f", selectedCityReviewElement.getAverageRating()))
                            .font(.title3)
                            .fontWeight(.semibold)
                            .padding(EdgeInsets(top: 4, leading: 15, bottom: 0, trailing: 5))
                        FiveStarView(rating: selectedCityReviewElement.getAverageRating(), dim: 25, color: .yellow)
                        Spacer()
                    }
                    .padding(EdgeInsets(top: 15, leading: 15, bottom: 0, trailing: 15))
                    
                    Spacer()
                    
                    ZStack{
                        VStack{
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(.blue.opacity(0.2))
                                        .frame(width: 40, height: 40)
                                    
                                    Image(systemName: "bus")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 25, height: 25)
                                        .foregroundColor(.blue)
                                }
                                .padding(.trailing)
                                Text(String(format: "%.1f", selectedCityReviewElement.averageLocalTransportRating))
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .padding(EdgeInsets(top: 4, leading: 0, bottom: 0, trailing: 10))
                                FiveStarView(rating: selectedCityReviewElement.averageLocalTransportRating, dim: 20, color: .blue.opacity(0.8))
                            }
                            
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(.green.opacity(0.2))
                                        .frame(width: 40, height: 40)
                                    
                                    Image(systemName: "tree")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 25, height: 25)
                                        .foregroundColor(.green)
                                }
                                .padding(.trailing)
                                Text(String(format: "%.1f", selectedCityReviewElement.averageGreenSpacesRating))
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .padding(EdgeInsets(top: 4, leading: 0, bottom: 0, trailing: 10))
                                FiveStarView(rating: selectedCityReviewElement.averageGreenSpacesRating, dim: 20, color: .green.opacity(0.8))
                            }
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(.orange.opacity(0.2))
                                        .frame(width: 40, height: 40)
                                    
                                    Image(systemName: "trash")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 25, height: 25)
                                        .foregroundColor(.orange)
                                }
                                .padding(.trailing)
                                Text(String(format: "%.1f", selectedCityReviewElement.averageWasteBinsRating))
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .padding(EdgeInsets(top: 4, leading: 0, bottom: 0, trailing: 10))
                                FiveStarView(rating: selectedCityReviewElement.averageWasteBinsRating, dim: 20, color: .orange.opacity(0.8))
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 10))
                        HStack{
                            Spacer()
                            Button (action: {
                                infoTapped = true
                            }){
                                Image(systemName: "info.circle")
                                    .font(.title3)
                            }
                        }
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 20))
                    }
                }
            }
            .fixedSize()
            .padding(EdgeInsets(top: 5, leading: 10, bottom: 0, trailing: 10))
            .overlay(Color.clear.accessibilityIdentifier("averageRatingSection"))
        } else {
            // iPadOS
            
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(uiColor: .systemBackground))
                    .shadow(color: .green.opacity(0.3), radius: 5, x: 0, y: 3)
                
                VStack {
                    HStack {
                        Text("Ratings")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Button (action: {
                            infoTapped = true
                        }){
                            Image(systemName: "info.circle")
                                .font(.title3)
                        }
                    }
                    .padding(EdgeInsets(top: 15, leading: 15, bottom: 0, trailing: 15))
                    
                    VStack {
                        HStack {
                            Text(String(format: "%.1f", selectedCityReviewElement.getAverageRating()))
                                .font(.title3)
                                .fontWeight(.semibold)
                                .padding(EdgeInsets(top: 4, leading: 15, bottom: 0, trailing: 5))
                            FiveStarView(rating: selectedCityReviewElement.getAverageRating(), dim: 25, color: .yellow)
                            
                            Text("\(selectedCityReviewElement.reviews.count) \(selectedCityReviewElement.reviews.count == 1 ? "review" : "reviews")")
                                .padding(.leading, 30)
                            
                            Spacer()
                        }
                    }
                    
                    Spacer()
                    
                    ZStack{
                        VStack{
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(.blue.opacity(0.2))
                                        .frame(width: 40, height: 40)
                                    
                                    Image(systemName: "bus")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 25, height: 25)
                                        .foregroundColor(.blue)
                                }
                                .padding(.trailing)
                                
                                Text("Local transport rating")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Text(String(format: "%.1f", selectedCityReviewElement.averageLocalTransportRating))
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .padding(EdgeInsets(top: 4, leading: 50, bottom: 0, trailing: 10))
                                FiveStarView(rating: selectedCityReviewElement.averageLocalTransportRating, dim: 20, color: .blue.opacity(0.8))
                            }
                            
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(.green.opacity(0.2))
                                        .frame(width: 40, height: 40)
                                    
                                    Image(systemName: "tree")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 25, height: 25)
                                        .foregroundColor(.green)
                                }
                                .padding(.trailing)
                                
                                Text("Green spaces rating")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Text(String(format: "%.1f", selectedCityReviewElement.averageGreenSpacesRating))
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .padding(EdgeInsets(top: 4, leading: 50, bottom: 0, trailing: 10))
                                FiveStarView(rating: selectedCityReviewElement.averageGreenSpacesRating, dim: 20, color: .green.opacity(0.8))
                            }
                            
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(.orange.opacity(0.2))
                                        .frame(width: 40, height: 40)
                                    
                                    Image(systemName: "trash")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 25, height: 25)
                                        .foregroundColor(.orange)
                                }
                                .padding(.trailing)
                                
                                Text("Cleanliness rating")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Text(String(format: "%.1f", selectedCityReviewElement.averageWasteBinsRating))
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .padding(EdgeInsets(top: 4, leading: 50, bottom: 0, trailing: 10))
                                FiveStarView(rating: selectedCityReviewElement.averageWasteBinsRating, dim: 20, color: .orange.opacity(0.8))
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 10))
                    }
                }
            }
            .fixedSize()
            .padding(EdgeInsets(top: 5, leading: 10, bottom: 0, trailing: 10))
            .overlay(Color.clear.accessibilityIdentifier("averageRatingSection"))
        }
    }
}

struct LatestReviewsView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var viewModel: CitiesReviewsViewModel
    var selectedCityReviewElement: CityReviewElement
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        VStack {
            if !selectedCityReviewElement.reviews.isEmpty {
                Text("Latest reviews for " + viewModel.selectedCity.cityName + ", " + viewModel.selectedCity.countryName)
                    .font(.headline)
                    .padding(.top, 5)
                    .accessibilityIdentifier("latestReviewsTitle")
                
                // latest reviews
                if horizontalSizeClass == .compact {
                    CarouselView(reviews: selectedCityReviewElement.getLastReviews(num: 5))
                        .frame(height: 250)
                } else {
                    VStack {
                        ReviewsBlocksView(reviews: selectedCityReviewElement.getLastReviews(num: 6))
                    }
                }
                 
                // button to see all reviews
                Button (action: {
                    navigationPath.append(NavigationDestination.AllReviewsView(viewModel))
                }){
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(AppColors.mainColor)
                        
                        HStack (spacing: 3) {
                            Spacer()
                            Image(systemName: "arrowshape.forward.circle")
                                .font(.title3)
                                .fontWeight(.light)
                                .foregroundStyle(.white)
                            Spacer()
                            Text("See all reviews")
                                .foregroundStyle(.white)
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        .padding(10)
                    }
                    .fixedSize()
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
        .padding(EdgeInsets(top: 5, leading: 10, bottom: 0, trailing: 10))
    }
}

struct CarouselView: View {
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
                }
            }
            .scrollTargetLayout()
        }
        .contentMargins(30, for: .scrollContent)
        .scrollTargetBehavior(.viewAligned)
    }
}

struct CardView: View {
    let review: Review
    let width: CGFloat
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 3)
            
            VStack {
                Text(review.firstName + " " + review.lastName)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.blue.opacity(0.8))
                    .frame(maxWidth: .infinity, alignment: .leading)
                HStack {
                    Text(String(format: "%.1f", review.computeRating()))
                        .font(.title3)
                        .fontWeight(.semibold)
                        .padding(EdgeInsets(top: 4, leading: 0, bottom: 0, trailing: 5))
                    FiveStarView(rating: review.computeRating(), dim: 20, color: .yellow)
                    Spacer()
                }
                .padding(.bottom, 5)
                
                Text(review.reviewText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.body)
                Spacer()
                VStack{
                    HStack {
                        ZStack {
                            Circle()
                                .fill(.blue.opacity(0.2))
                                .frame(width: 27, height: 27)
                            
                            Image(systemName: "bus")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 18, height: 18)
                                .foregroundColor(.blue)
                        }
                        .padding(.trailing)
                        FiveStarView(rating: Float64(review.localTransportRating), dim: 15, color: .blue.opacity(0.8))
                    }
                    HStack {
                        ZStack {
                            Circle()
                                .fill(.green.opacity(0.2))
                                .frame(width: 27, height: 27)
                            
                            Image(systemName: "tree")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 18, height: 18)
                                .foregroundColor(.green)
                        }
                        .padding(.trailing)
                        FiveStarView(rating: Float64(review.greenSpacesRating), dim: 15, color: .green.opacity(0.8))
                    }
                    HStack {
                        ZStack {
                            Circle()
                                .fill(.orange.opacity(0.2))
                                .frame(width: 27, height: 27)
                            
                            Image(systemName: "trash")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 18, height: 18)
                                .foregroundColor(.orange)
                        }
                        .padding(.trailing)
                        FiveStarView(rating: Float64(review.wasteBinsRating), dim: 15, color: .orange.opacity(0.8))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
        }
        .frame(maxWidth: width)
    }
}

struct ReviewsBlocksView: View {
    var reviews: [Review]
    @State private var availableWidth: CGFloat = 0

    var body: some View {
        LazyVGrid(
            columns: Array(
                repeating: GridItem(.flexible(), spacing: 10),
                count: availableWidth > 800 ? 3 : 2
            ),
            spacing: 10
        ) {
            ForEach(reviews.prefix(6), id: \.id) { review in
                let spacing: CGFloat = 10
                let columnsCount = availableWidth > 800 ? 3 : 2
                let cardWidth = (availableWidth - 40 - spacing * CGFloat(columnsCount)) / CGFloat(columnsCount)
                // ternary operator needed because at start width is 0
                CardView(review: review, width: cardWidth > 0 ? cardWidth : 1)
                    .frame(maxHeight: 270)
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
