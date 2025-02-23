import SwiftUI
import SwiftData

struct CityReviewsDetailsView: View {
    @Query var users: [User]
    @StateObject var viewModel: CitiesReviewsViewModel
    @Binding var navigationPath: NavigationPath
    @State var infoTapped = false
    @State var editTapped = false
    var body: some View {
        if let selectedCityReviewElement = viewModel.selectedCityReviewElement {
            ZStack {
                VStack {
                    ScrollView {
                        VStack {
                            Text(viewModel.selectedCity.cityName + ", " + viewModel.selectedCity.countryName)
                                .font(.title)
                                .padding(.horizontal)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
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
                            VStack{
                                if viewModel.isReviewable(userID: users.first?.userID ?? -1) {
                                    VStack {
                                        if viewModel.userReview == nil {
                                            ZStack{
                                                RoundedRectangle(cornerRadius: 20)
                                                    .fill(Color.blue)
                                                    .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 3)
                                                HStack{
                                                    Button(action: {
                                                        editTapped = true
                                                    }) {
                                                        HStack{
                                                            Text("add your review for \(viewModel.selectedCity.cityName)")
                                                                .padding()
                                                                .foregroundStyle(.white)
                                                                .font(.system(size: 22).bold())
                                                        }
                                                    }
                                                    .padding(.horizontal)
                                                }
                                            }
                                        } else {
                                            if let userReview = viewModel.userReview {
                                                ZStack{
                                                    RoundedRectangle(cornerRadius: 20)
                                                        .fill(Color(uiColor: .systemBackground))
                                                        .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 3)
                                                    VStack {
                                                        Text("Your review")
                                                            .frame(maxWidth: .infinity, alignment: .leading)
                                                            .font(.title3)
                                                            .fontWeight(.semibold)
                                                        HStack {
                                                            FiveStarView(rating: userReview.computeRating(), dim: 20, color: .green.opacity(0.8))
                                                            Text(userReview.firstName + " " + userReview.lastName)
                                                                .font(.headline)
                                                                .fontWeight(.semibold)
                                                                .foregroundStyle(.green.opacity(0.6))
                                                                .padding(EdgeInsets(top: 3, leading: 5, bottom: 0, trailing: 0))
                                                            Spacer()
                                                        }
                                                        Text(userReview.reviewText)
                                                            .frame(maxWidth: .infinity, alignment: .leading)
                                                        Spacer()
                                                        HStack{
                                                            Spacer()
                                                            Button(action: {
                                                                editTapped = true
                                                            }) {
                                                                Text("Edit")
                                                            }
                                                        }
                                                        .padding(.horizontal)
                                                    }
                                                    .padding()
                                                }
                                                //.padding()
                                            }
                                        }
                                    }
                                    .padding(EdgeInsets(top: 5, leading: 20, bottom: 0, trailing: 20))
                                }
                                if !selectedCityReviewElement.reviews.isEmpty {
                                    Text("Latest Reviews for " + viewModel.selectedCity.cityName + ", " + viewModel.selectedCity.countryName)
                                        .font(.headline)
                                        .padding(.top, 5)
                                    
                                    
                                    CarouselView(cards: selectedCityReviewElement.getLastFiveReviews())
                                        .frame(height: 250)
                                    
                                    if selectedCityReviewElement.reviews.count > 5 {
                                        // Button to see all reviews
                                        Button (action: {
                                            navigationPath.append(NavigationDestination.AllReviewsView(viewModel))
                                        }){
                                            Text("See all reviews")
                                                .font(.headline)
                                                .padding(10)
                                                .background(Color.blue)
                                                .foregroundColor(.white)
                                                .cornerRadius(10)
                                        }
                                        .padding()
                                    }
                                }
                                else {
                                    Text("There are no reviews yet for " + viewModel.selectedCity.cityName + ", " + viewModel.selectedCity.countryName + ".")
                                        .font(.system(size: 15))
                                        .fontWeight(.light)
                                        .padding(.top, 40)
                                }
                            }
                            .padding(EdgeInsets(top: 5, leading: 10, bottom: 0, trailing: 10))
                        }
                        .padding()
                    }
                }
                .blur(radius: (editTapped || infoTapped) ? 5 : 0)
                .allowsHitTesting(!(editTapped || infoTapped))
                if editTapped {
                    InsertReviewView(isPresented: $editTapped, viewModel: viewModel)
                }
            }
            .onAppear(){
                viewModel.getUserReview(userID: users.first?.userID ?? -1)
            }
        }
    }
}



struct CarouselView: View {
    var cards: [Review]
    var body: some View {
        GeometryReader { reader in
            SnapperView(size: reader.size, cards: cards)
        }
    }
}

struct SnapperView: View {
    let size: CGSize
    let cards: [Review]
    private let padding: CGFloat
    private let cardWidth: CGFloat
    private let spacing: CGFloat = 15.0
    private let maxSwipeDistance: CGFloat
    
    @State private var currentCardIndex: Int = 1
    @State private var isDragging: Bool = false
    @State private var totalDrag: CGFloat = 0.0
    
    init(size: CGSize, cards: [Review]) {
        self.size = size
        self.cards = cards
        self.cardWidth = size.width * 0.85
        self.padding = (size.width - cardWidth) / 2.0
        self.maxSwipeDistance = cardWidth + spacing
    }
    
    var body: some View {
        let offset: CGFloat = maxSwipeDistance - (maxSwipeDistance * CGFloat(currentCardIndex))
        LazyHStack(spacing: spacing) {
            ForEach(cards) { card in
                CardView(review: card, width: cardWidth)
                    .offset(x: isDragging ? totalDrag : 0)
                    //.animation(.bouncy(duration: 1.5), value: isDragging)
            }
        }
        .padding(.horizontal, padding)
        .offset(x: offset, y: 0)
        .gesture(
            DragGesture()
                .onChanged { value in
                    isDragging = true
                    totalDrag = value.translation.width
                }
                .onEnded { value in
                    totalDrag = 0.0
                    isDragging = false
                    
                    if (value.translation.width < -(cardWidth / 3.0) && self.currentCardIndex < cards.count) {
                        self.currentCardIndex = self.currentCardIndex + 1
                    }
                    if (value.translation.width > (cardWidth / 3.0) && self.currentCardIndex > 1) {
                        self.currentCardIndex = self.currentCardIndex - 1
                    }
                }
        )
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
                HStack {
                    FiveStarView(rating: review.computeRating(), dim: 20, color: .yellow)
                    Text(review.firstName + " " + review.lastName)
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
        .frame(width: width)
    }
}

struct InsertReviewView: View {
    @Binding var isPresented: Bool
    @ObservedObject var viewModel: CitiesReviewsViewModel
    @State private var offsetY: CGFloat = 0
    @State var editTapped: Bool = false
    @FocusState private var isFocused: Bool
    
    var body: some View {
        ZStack {
            if isPresented {
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation(.easeInOut) {
                            isPresented = false
                        }
                    }
                    .transition(.opacity)
                    .animation(.easeIn(duration: 0.2), value: isPresented)
            }

            VStack {
                Spacer()
                
                VStack(spacing: 15) {
                    Capsule()
                        .frame(width: 40, height: 5)
                        .foregroundColor(.gray)
                        .padding(.top, 8)
                    ZStack {
                        HStack {
                            Spacer()
                            if viewModel.userReview != nil {
                                if editTapped {
                                    Button(action: {
                                        editTapped = false
                                    }) {
                                        Text("Cancel")
                                    }
                                }
                                else {
                                    Button(action: {
                                        editTapped = true
                                    }) {
                                        Text("Edit")
                                    }
                                }
                            }
                        }
                        Text("Leave a review")
                            .font(.headline)
                            .padding(.top, 10)
                    }

                    ReviewStarRating(icon: "bus", color: Color.blue, rating: $viewModel.localTransportRating, editTapped: (editTapped || (viewModel.userReview == nil )))
                    ReviewStarRating(icon: "tree",color: Color.green, rating: $viewModel.greenSpacesRating, editTapped: (editTapped || (viewModel.userReview == nil )))
                    ReviewStarRating(icon: "trash", color: Color.orange, rating: $viewModel.wasteBinsRating, editTapped: (editTapped || (viewModel.userReview == nil )))

                    TextField("Leave a review...", text: $viewModel.reviewText , axis: .vertical)
                        .padding()
                        .lineLimit(8, reservesSpace: true)
                        .focused($isFocused)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .disabled(!editTapped && viewModel.userReview != nil)
                        .toolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                Spacer()
                                Button("Done") {
                                    isFocused = false
                                }
                            }
                        }
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.easeInOut) {
                            isPresented = false
                            if viewModel.userReview == nil {
                                Task {
                                    await viewModel.uploadReview()
                                }
                            }
                            else {
                                Task {
                                    await viewModel.modifyReview()
                                }
                            }
                        }
                    }) {
                        Text("Save review")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.bottom, 20)
                }
                .padding(.horizontal, 15)
                .frame(maxWidth: .infinity)
                .fixedSize(horizontal: false, vertical: true)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(radius: 10)
                .offset(y: offsetY)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            if gesture.translation.height > 0 {
                                offsetY = gesture.translation.height
                            }
                        }
                        .onEnded { gesture in
                            if gesture.translation.height > 150 {
                                withAnimation(.spring()) {
                                    isPresented = false
                                    offsetY = 0
                                }
                            } else {
                                withAnimation(.spring()) {
                                    offsetY = 0
                                }
                            }
                        }
                )
                .transition(.move(edge: .bottom))
            }
            .padding(.horizontal)
            .animation(.easeInOut, value: isPresented)
            
        }
        .onAppear() {
            viewModel.reviewText = viewModel.userReview?.reviewText ?? ""
            viewModel.wasteBinsRating = viewModel.userReview?.wasteBinsRating ?? 0
            viewModel.greenSpacesRating = viewModel.userReview?.greenSpacesRating ?? 0
            viewModel.localTransportRating = viewModel.userReview?.localTransportRating ?? 0
        }
    }
}

struct ReviewStarRating: View {
    let icon: String
    let color: Color
    @Binding var rating: Int
    let editTapped: Bool
    
    var body: some View {
        HStack (spacing: 15){
            Spacer()
            
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundColor(color)
            }
            Spacer()
            HStack {
                ForEach(1..<6, id: \.self) { index in
                    Image(systemName: index <= rating ? "star.fill" : "star")
                        .foregroundColor(.yellow)
                        .font(.title)
                        .onTapGesture {
                            if editTapped {
                                withAnimation(Animation.easeInOut(duration: 0.2)) {
                                    rating = index
                                }
                            }
                        }
                }
            }
            Spacer()
            
        }
        .padding(.vertical, 5)
    }
}
