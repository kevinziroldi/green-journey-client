import SwiftUI

struct InsertReviewButtonView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @ObservedObject var viewModel: CitiesReviewsViewModel
    @Binding var reviewTapped: Bool
    var city: String?
    var country: String?
    @Binding var isPresenting: Bool
    
    var body: some View {
        VStack {
            if viewModel.userReview == nil {
                Button(action: {
                    if !isPresenting {
                        isPresenting = true
                        reviewTapped = true
                    }
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(AppColors.mainColor)
                            .shadow(color: AppColors.mainColor.opacity(0.3), radius: 5, x: 0, y: 3)
                        HStack {
                            Text("Leave a review")
                                .foregroundStyle(.white)
                                .fontWeight(.semibold)
                        }
                        .padding(10)
                    }
                    .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal)
                .accessibilityIdentifier("addReviewButton")
                
                
            } else {
                if let userReview = viewModel.userReview {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(uiColor: .systemBackground))
                            .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 3)
                        if horizontalSizeClass == .compact {
                            // iOS
                            VStack {
                                HStack {
                                    YourReviewTitle()
                                    
                                    Spacer()
                                    
                                    FiveStarView(rating: userReview.computeRating(), dim: 20, color: Color.yellow)
                                        .overlay(Color.clear.accessibilityIdentifier("userReviewRating"))
                                    
                                    Spacer()
                                    Spacer()
                                    Spacer()
                                }
                                
                                Text(userReview.reviewText)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .accessibilityIdentifier("userReviewText")
                                
                                Spacer()
                            }
                            .padding()
                        }
                        else {
                            // iPadOS
                            VStack {
                                HStack {
                                    YourReviewTitle()
                                    Spacer()
                                }
                                HStack {
                                    HStack {
                                        Text(String(format: "%.1f", userReview.computeRating()))
                                            .font(.system(size: 45))
                                            .fontWeight(.bold)
                                        FiveStarView(rating: userReview.computeRating(), dim: 20, color: Color.yellow)
                                            .overlay(Color.clear.accessibilityIdentifier("userReviewRating"))
                                    }
                                    .frame(maxWidth: 270)
                                    
                                    Text(userReview.reviewText)
                                        .font(.system(size: 18))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                            .padding()
                        }
                    }
                    .frame(maxHeight: 200)
                    .onTapGesture() {
                        if !isPresenting {
                            isPresenting = true
                            reviewTapped = true
                        }
                    }
                }
            }
        }
        .frame(maxWidth: 800)
        .padding(EdgeInsets(top: 5, leading: 20, bottom: 0, trailing: 20))
        .onAppear {
            if let city = city {
                if let country = country {
                    viewModel.getDestinationCity(city: city, country: country)
                }
            }
        }
    }
}

private struct YourReviewTitle: View {
    var body: some View {
        Text("Your Review")
            .font(.title3)
            .fontWeight(.semibold)
            .accessibilityIdentifier("yourReviewTitle")
    }
}
