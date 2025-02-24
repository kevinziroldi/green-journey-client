import SwiftUI

struct InsertReviewView: View {
    @Binding var isPresented: Bool
    @ObservedObject var viewModel: CitiesReviewsViewModel
    @State var editTapped: Bool = false
    @FocusState private var isFocused: Bool
    @State var showAlert: Bool = false
    
    var body: some View {
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
                                .padding(.top, 20)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        isPresented = false
                    }) {
                        Text("Cancel")
                            .padding(.top, 20)
                    }
                    
                }
            }
            
            Text(viewModel.userReview != nil ? "Your review" : "Leave a review")
                .font(.system(size: 25).bold())
            
            Spacer()
            
            ReviewStarRating(icon: "bus", color: Color.blue, rating: $viewModel.localTransportRating, editTapped: (editTapped || (viewModel.userReview == nil )))
            ReviewStarRating(icon: "tree",color: Color.green, rating: $viewModel.greenSpacesRating, editTapped: (editTapped || (viewModel.userReview == nil )))
            ReviewStarRating(icon: "trash", color: Color.orange, rating: $viewModel.wasteBinsRating, editTapped: (editTapped || (viewModel.userReview == nil )))
            VStack {
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
                Text("Save review")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
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
                        message: Text("you cannot undo this action"),
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
                                withAnimation(Animation.easeInOut(duration: 0.2)) {
                                    rating = index
                                }
                            }
                        }
                }
            }
            Spacer()
            Spacer()
            Spacer()
            
        }
        .padding(.vertical, 5)
    }
}
