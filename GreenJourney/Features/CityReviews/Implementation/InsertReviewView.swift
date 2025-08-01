import SwiftUI

struct InsertReviewView: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme

    @Binding var isPresented: Bool
    @ObservedObject var viewModel: CitiesReviewsViewModel
    @State var editTapped: Bool = false
    @FocusState private var isFocused: Bool
    @State var showAlert: Bool = false
    @Binding var isPresenting: Bool
    
    var body: some View {
        ZStack {
            VStack(spacing: 10) {
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
                            isPresenting = false
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
                
                VStack {
                    Text(viewModel.userReview != nil ? "Your review" : "Leave a review")
                        .font(.system(size: 25).bold())
                        .accessibilityIdentifier("personalReviewTitle")
                    
                    
                    VStack {
                        ReviewStarRating(icon: "bus", color: colorScheme == .dark ? Color.white : Color.black, rating: $viewModel.localTransportRating, editTapped: (editTapped || (viewModel.userReview == nil )))
                        ReviewStarRating(icon: "tree",color:  colorScheme == .dark ? Color.white : Color.black, rating: $viewModel.greenSpacesRating, editTapped: (editTapped || (viewModel.userReview == nil )))
                        ReviewStarRating(icon: "trash", color:  colorScheme == .dark ? Color.white : Color.black, rating: $viewModel.wasteBinsRating, editTapped: (editTapped || (viewModel.userReview == nil )))
                    }
                    .overlay(Color.clear.accessibilityIdentifier("userRatings"))
                }
                .background(Color.clear.contentShape(Rectangle()).accessibilityIdentifier("overlayRating"))
                
                VStack {
                    TextField("Leave a review...", text: $viewModel.reviewText , axis: .vertical)
                        .padding()
                        .lineLimit(8, reservesSpace: true)
                        .focused($isFocused)
                        .background(colorScheme == .dark ? AppColors.blockColorDark: Color(.systemGray6))
                        .cornerRadius(10)
                        .disabled(!editTapped && viewModel.userReview != nil)
                        .accessibilityIdentifier("userText")
                }
                .padding(10)
                
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
                            .fill((viewModel.reviewText.isEmpty) || (viewModel.greenSpacesRating == 0) || (viewModel.localTransportRating == 0) || (viewModel.wasteBinsRating == 0)  ? Color.secondary.opacity(0.6) : AppColors.mainColor)
                        Text("Save review")
                            .fontWeight(.semibold)
                            .padding(10)
                            .foregroundColor(.white)
                    }
                    .fixedSize()
                }
                .disabled((viewModel.reviewText.isEmpty) || (viewModel.greenSpacesRating == 0) || (viewModel.localTransportRating == 0) || (viewModel.wasteBinsRating == 0))
                .accessibilityIdentifier("saveButton")
                
                Spacer()
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
            .padding(.horizontal, 15)
        }
        .onAppear() {
            viewModel.reviewText = viewModel.userReview?.reviewText ?? ""
            viewModel.wasteBinsRating = viewModel.userReview?.wasteBinsRating ?? 0
            viewModel.greenSpacesRating = viewModel.userReview?.greenSpacesRating ?? 0
            viewModel.localTransportRating = viewModel.userReview?.localTransportRating ?? 0
        }
        // dismiss keyboard on tap
        .onTapGesture {
            hideKeyboard()
        }
    }
}

private struct ReviewStarRating: View {
    let icon: String
    let color: Color
    @Binding var rating: Int
    let editTapped: Bool
    
    var body: some View {
        HStack (spacing: 15){
            Spacer()
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .foregroundColor(color)
            
            Spacer()
            HStack {
                ForEach(1..<6, id: \.self) { index in
                    Image(systemName: index <= rating ? "star.fill" : "star")
                        .foregroundColor(Color.yellow)
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
