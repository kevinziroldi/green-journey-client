import SwiftUI

struct InsertReviewButtonView: View {
    @ObservedObject var viewModel: CitiesReviewsViewModel
    @Binding var reviewTapped: Bool
    var city: String?
    var country: String?
    
    var body: some View {
        VStack {
            if viewModel.userReview == nil {
                ZStack{
                    RoundedRectangle(cornerRadius: 20)
                        .fill(AppColors.mainColor)
                        .shadow(color: AppColors.mainColor.opacity(0.3), radius: 5, x: 0, y: 3)
                    HStack{
                        Button(action: {
                            reviewTapped = true
                        }) {
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(AppColors.mainColor)
                                
                                HStack (spacing: 3) {
                                    Spacer()
                                    Image(systemName: "pencil.and.scribble")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                        .fontWeight(.light)
                                        .foregroundStyle(.white)
                                    Spacer()
                                    Text("Leave a review")
                                        .foregroundStyle(.white)
                                        .fontWeight(.semibold)
                                    Spacer()
                                }
                                .padding(10)
                            }
                            .fixedSize()
                        }
                        .padding(.horizontal)
                        .accessibilityIdentifier("addReviewButton")
                    }
                }
            } else {
                if let userReview = viewModel.userReview {
                    ZStack{
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(uiColor: .systemBackground))
                            .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 3)
                        VStack {
                            HStack {
                                Text("Your review")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .accessibilityIdentifier("yourReviewTitle")
                                
                                Spacer()
                                
                                FiveStarView(rating: userReview.computeRating(), dim: 20, color: .green.opacity(0.8))
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
                    .onTapGesture() {
                        reviewTapped = true
                    }
                }
            }
        }
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
