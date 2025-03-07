import SwiftUI

struct InsertReviewView: View {
    @Binding var isPresented: Bool
    @ObservedObject var viewModel: CitiesReviewsViewModel
    @State var editTapped: Bool = false
    @FocusState private var isFocused: Bool
    @State var showAlert: Bool = false
    
    var body: some View {
        VStack(spacing: 10) {
            GeometryReader { geometry in
                ZStack {
                    Capsule()
                        .frame(width: 40, height: 5)
                        .foregroundColor(.gray)
                    HStack {
                        if (!editTapped && (viewModel.userReview != nil)) {
                            Button(action: {
                                editTapped = true
                            }) {
                                Text("Edit")
                                    .font(.headline)
                                    .padding(.top, 20)
                            }
                            .accessibilityIdentifier("editButton")
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            isPresented = false
                        }) {
                            Text("Cancel")
                                .font(.headline)
                                .padding(.top, 20)
                        }
                        .accessibilityIdentifier("cancelButton")
                    }
                    .padding(.horizontal, 5)
                }
                .position(x: geometry.size.width/2, y: 15)
                
                
                Text(viewModel.userReview != nil ? "Your review" : "Leave a review")
                    .font(.system(size: 25).bold())
                    .position(x: geometry.size.width/2, y: 50)
                    .accessibilityIdentifier("personalReviewTitle")
                
                VStack {
                    ReviewStarRating(icon: "bus", color: Color.blue, rating: $viewModel.localTransportRating, editTapped: (editTapped || (viewModel.userReview == nil )))
                    ReviewStarRating(icon: "tree",color: Color.green, rating: $viewModel.greenSpacesRating, editTapped: (editTapped || (viewModel.userReview == nil )))
                    ReviewStarRating(icon: "trash", color: Color.orange, rating: $viewModel.wasteBinsRating, editTapped: (editTapped || (viewModel.userReview == nil )))
                }
                .position(x: geometry.size.width/2, y: 190)
                .overlay(Color.clear.accessibilityIdentifier("userRatings"))
                
                VStack {
                    TextField("Leave a review...", text: $viewModel.reviewText , axis: .vertical)
                        .padding()
                        .lineLimit(8, reservesSpace: true)
                        .focused($isFocused)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .disabled(!editTapped && viewModel.userReview != nil)
                        .accessibilityIdentifier("userText")
                }
                .padding(10)
                .position(x: geometry.size.width/2, y: 400)
                
                Spacer()
                
                //save review button
                Button(action: {
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
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill((viewModel.reviewText.isEmpty) || (viewModel.greenSpacesRating == 0) || (viewModel.localTransportRating == 0) || (viewModel.wasteBinsRating == 0) ? .black.opacity(0.3): AppColors.mainColor)
                        Text("Save review")
                            .padding(10)
                            .foregroundColor(.white)
                    }
                    .fixedSize()
                }
                .disabled((viewModel.reviewText.isEmpty) || (viewModel.greenSpacesRating == 0) || (viewModel.localTransportRating == 0) || (viewModel.wasteBinsRating == 0))
                .position(x: geometry.size.width/2, y: 580)
                .accessibilityIdentifier("saveButton")
                
                //delete button
                if viewModel.userReview != nil {
                    Button(action: {
                        showAlert = true
                    }) {
                        Text("Delete")
                            .foregroundStyle(.red)
                            .font(.headline)
                            .padding(.bottom, 20)
                    }
                    .position(x: geometry.size.width/2, y: 660)
                    .alert(isPresented: $showAlert) {
                        Alert(
                            title: Text("Delete this review?"),
                            message: Text("You cannot undo this action"),
                            primaryButton: .cancel(Text("Cancel")) {},
                            secondaryButton: .destructive(Text("Delete")) {
                                //delete review
                                isPresented = false
                                Task {
                                    await viewModel.deleteReview()
                                }
                            }
                        )
                    }
                    .accessibilityIdentifier("deleteButton")
                }
            }
        }
        .padding(.horizontal, 15)
        .background(Color.white)
        .onAppear() {
            viewModel.reviewText = viewModel.userReview?.reviewText ?? ""
            viewModel.wasteBinsRating = viewModel.userReview?.wasteBinsRating ?? 0
            viewModel.greenSpacesRating = viewModel.userReview?.greenSpacesRating ?? 0
            viewModel.localTransportRating = viewModel.userReview?.localTransportRating ?? 0
        }
        .onTapGesture {
            hideKeyboard()
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
                        .font(.title2)
                        .onTapGesture {
                            if editTapped {
                                    rating = index
                            }
                        }
                        .accessibilityIdentifier("star_\(index)")
                }
            }
            Spacer()
            Spacer()
            Spacer()
            
        }
        .padding(.vertical, 5)
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
