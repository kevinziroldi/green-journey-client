import SwiftUI

struct AllReviewsView: View {
    @ObservedObject var viewModel: CitiesReviewsViewModel
    @Binding var navigationPath: NavigationPath
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack {
            HStack {
                Text(viewModel.flag(country: viewModel.selectedCity.countryCode))
                                    .font(.system(size: 80))
                                    .foregroundColor(.blue)
                Text(viewModel.selectedCity.cityName + ", " + viewModel.selectedCity.countryName)
                    .font(.system(size: 32).bold())
                    .padding()
                    .fontWeight(.semibold)
                    .accessibilityIdentifier("cityName")
                Spacer()
            }
            .padding(.horizontal)
            
            Spacer()
            
            ReviewsListView(reviews: viewModel.currentReviews)
            
            HStack {
                Spacer()
                Button(action: {
                    Task {
                        await viewModel.getFirstReviewsForSearchedCity()
                    }
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: 50, height: 40)
                            .foregroundStyle(viewModel.hasPrevious ? AppColors.mainColor : Color.black.opacity(0.3))
                        Image(systemName: "arrow.left.to.line")
                            .foregroundStyle(.white)
                            .font(.title2)
                    }
                }
                .disabled(!viewModel.hasPrevious)
                .accessibilityIdentifier("buttonFirst")
                
                Spacer()
                
                Button(action: {
                    Task {
                        await viewModel.getPreviousReviewsForSearchedCity()
                    }
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: 115 ,height: 40)
                            .foregroundStyle(viewModel.hasPrevious ? AppColors.mainColor : Color.black.opacity(0.3))
                        
                        HStack {
                            Image(systemName: "arrow.left")
                                .foregroundStyle(.white)
                                .font(.title3)
                            Text("Previous")
                                .foregroundStyle(.white)
                                .font(.system(size: 18).bold())
                        }
                    }
                }
                .disabled(!viewModel.hasPrevious)
                .accessibilityIdentifier("buttonPrevious")
                
                Spacer()
                
                Spacer()
                
                Button(action: {
                    Task {
                        await viewModel.getNextReviewsForSearchedCity()
                    }
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: 115 ,height: 40)
                            .foregroundStyle(viewModel.hasNext ? AppColors.mainColor : Color.black.opacity(0.3))
                        HStack {
                            Text("Next")
                                .foregroundStyle(.white)
                                .font(.system(size: 18).bold())
                            Image(systemName: "arrow.right")
                                .foregroundStyle(.white)
                                .font(.title3)
                        }
                    }
                    
                }
                .disabled(!viewModel.hasNext)
                .accessibilityIdentifier("buttonNext")
                
                Spacer()
                
                Button(action: {
                    Task {
                        await viewModel.getLastReviewsForSearchedCity()
                    }
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: 50, height: 40)
                            .foregroundStyle(viewModel.hasNext ? AppColors.mainColor : Color.black.opacity(0.3))
                        Image(systemName: "arrow.right.to.line")
                            .foregroundStyle(.white)
                            .font(.title2)
                    }
                }
                .disabled(!viewModel.hasNext)
                .accessibilityIdentifier("buttonLast")
                
                Spacer()
            }
            .padding(.top, 10)
            Spacer()
        }
        .background(colorScheme == .dark ? AppColors.backColorDark : AppColors.backColorLight)
    }
}

private struct ReviewsListView: View {
    var reviews: [Review]
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack {
                    ForEach(reviews) { review in
                        SingleReviewView(review: review)
                            .id(review.reviewID)
                            .overlay(Color.clear.accessibilityIdentifier("reviewView_\(review.reviewID ?? -1)"))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: reviews) {
                // scroll to the top 
                if let firstReview = reviews.first {
                    withAnimation {
                        proxy.scrollTo(firstReview.reviewID, anchor: .top)
                    }
                }
            }
        }
    }
}

private struct SingleReviewView: View {
    let review: Review
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 3)
            
            VStack {
                HStack {
                    Text(review.firstName + " " + review.lastName)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.blue.opacity(0.8))
                    Spacer()
                    Text(review.dateTime.formatted(date: .numeric, time: .omitted))
                        .foregroundStyle(.primary.opacity(0.8))
                        .font(.subheadline)
                }
                
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
                DetailedRatingsView(review: review)
            }
            .padding()
        }
        .frame(maxWidth: 800)
    }
}

