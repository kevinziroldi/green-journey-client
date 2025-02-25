import SwiftUI

struct AllReviewsView: View {
    @ObservedObject var viewModel: CitiesReviewsViewModel
    @Binding var navigationPath: NavigationPath
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack {
            if let selectedCity = viewModel.selectedCityReviewElement {
                Text(viewModel.selectedCity.cityName)
                    .font(.title)
                    .accessibilityIdentifier("cityName")
                
                Spacer()
                
                ReviewsListView(reviews: selectedCity.reviews, page: viewModel.page)
                
                HStack {
                    Spacer()
                    Button(action: {
                        viewModel.page = 0
                        viewModel.pageInput = viewModel.page + 1
                    }) {
                        Text("First")
                    }
                    .disabled(!(viewModel.page > 0))
                    .accessibilityIdentifier("buttonFirst")
                    
                    Spacer()
                    
                    Button(action: {
                        viewModel.page -= 1
                        viewModel.pageInput = viewModel.page + 1
                    }) {
                        Text("Previous")
                    }
                    .disabled(!(viewModel.page > 0))
                    .accessibilityIdentifier("buttonPrevious")
                    
                    Spacer()
                    
                    HStack (spacing: 0){
                        Text("Page")
                        TextField("", text: viewModel.binding(for: $viewModel.pageInput))
                            .frame(width: 20)
                            .multilineTextAlignment(.trailing)
                            .foregroundStyle(.blue)
                            .keyboardType(.numberPad)
                            .fontWeight(.semibold)
                            .focused($isFocused)
                            .toolbar {
                                ToolbarItemGroup(placement: .keyboard) {
                                    Spacer()
                                    Button("Done") {
                                        isFocused = false
                                        viewModel.validatePageInput()
                                    }
                                    .accessibilityIdentifier("doneButton")
                                }
                            }
                            .accessibilityIdentifier("pageTextField")
                        
                        Text("/\(viewModel.getNumPages())")
                            .foregroundStyle(.blue)
                            .fontWeight(.semibold)
                        
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        viewModel.page += 1
                        viewModel.pageInput = viewModel.page + 1
                    }) {
                        Text("Next")
                    }
                    .disabled(!(viewModel.page + 1 < viewModel.getNumPages()))
                    .accessibilityIdentifier("buttonNext")
                    
                    Spacer()
                    
                    Button(action: {
                        viewModel.page = viewModel.getNumPages() - 1
                        viewModel.pageInput = viewModel.page + 1
                    }) {
                        Text("Last")
                    }
                    .disabled(!(viewModel.page + 1 < viewModel.getNumPages()))
                    .accessibilityIdentifier("buttonLast")
                    
                    Spacer()
                }
                .padding(.top, 10)
                Spacer()
            }
        }
    }
}

struct ReviewsListView: View {
    var reviews: [Review]
    var page: Int = 0
    var paginatedReview: [Review] {
        let startIndex = page * 10
        let endIndex = min(startIndex + 10, reviews.count)
        return Array(reviews[startIndex..<endIndex])
    }
    var body: some View {
        ScrollView{
            VStack {
                ForEach (paginatedReview) { review in
                    SingleReviewView(review: review)
                        .overlay(Color.clear.accessibilityIdentifier("reviewView_\(review.reviewID ?? -1)"))
                }
            }
            .padding()
        }
        .scrollDismissesKeyboard(.interactively)
    }
    
}

struct SingleReviewView: View {
    let review: Review
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 3)
            
            VStack {
                HStack {
                    FiveStarView(rating: review.computeRating(), dim: 20, color: .yellow)
                    Text(review.firstName + ", " + review.lastName)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.blue.opacity(0.8))
                        .padding(EdgeInsets(top: 3, leading: 5, bottom: 0, trailing: 0))
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
                                .fill(.green.opacity(0.2))
                                .frame(width: 27, height: 27)
                            
                            Image(systemName: "bus")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 18, height: 18)
                                .foregroundColor(.green)
                        }
                        .padding(.trailing)
                        FiveStarView(rating: Float64(review.localTransportRating), dim: 15, color: .yellow.opacity(0.8))
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
                        FiveStarView(rating: Float64(review.greenSpacesRating), dim: 15, color: .yellow.opacity(0.8))
                    }
                    HStack {
                        ZStack {
                            Circle()
                                .fill(.green.opacity(0.2))
                                .frame(width: 27, height: 27)
                            
                            Image(systemName: "trash")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 18, height: 18)
                                .foregroundColor(.green)
                        }
                        .padding(.trailing)
                        FiveStarView(rating: Float64(review.wasteBinsRating), dim: 15, color: .yellow.opacity(0.8))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
        }
    }
}

