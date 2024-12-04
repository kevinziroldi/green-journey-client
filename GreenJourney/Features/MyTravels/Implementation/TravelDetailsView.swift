import SwiftUI

struct TravelDetailsView: View {
    @ObservedObject var viewModel: MyTravelsViewModel
    @Binding var navigationPath: NavigationPath
    
    var body : some View {
        VStack {
            Spacer()
            
            Button(action: {
                viewModel.deleteSelectedTravel()
                
                if !navigationPath.isEmpty {
                    navigationPath.removeLast()
                }
            }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
            
            Spacer()
            
            Text("From").font(.title)
            Text(viewModel.selectedTravel?.getDepartureSegment()?.departureCity ?? "unknown").font(.headline)
            Text("To").font(.title)
            Text(viewModel.selectedTravel?.getDestinationSegment()?.destinationCity ?? "unknown").font(.headline)
            Text("Departure").font(.title)
            Text(viewModel.selectedTravel?.getDepartureSegment()?.dateTime.formatted(date: .numeric, time: .shortened) ?? "unknown").font(.headline)
            
            Spacer()
                        
            Button ("COMPENSATION TRIAL") {
                viewModel.compensateCO2()
            }
            
            Button ("UPLOAD REVIEW") {
                viewModel.reviewText = "review di prova"
                viewModel.localTransportRating = 1
                viewModel.greenSpacesRating = 1
                viewModel.wasteBinsRating = 1
                viewModel.uploadReview()
            }
            
            Spacer()
        }
    }
}
