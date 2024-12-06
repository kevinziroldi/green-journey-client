import SwiftUI

struct TravelDetailsView: View {
    @EnvironmentObject var viewModel: MyTravelsViewModel
    @Binding var navigationPath: NavigationPath
    
    var body : some View {
        if let selectedTravel = viewModel.selectedTravel {
            VStack {
                Spacer()
                
                Button(action: {
                    viewModel.deleteTravel(travelToDelete: selectedTravel.travel)
                    
                    if !navigationPath.isEmpty {
                        print("removing last element from navigationpath")
                        navigationPath.removeLast()
                    }else {
                        print("navigationPath is empty")
                        print(navigationPath)
                    }
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                
                Spacer()
                
                Text("From").font(.title)
                Text(selectedTravel.getDepartureSegment()?.departureCity ?? "unknown").font(.headline)
                Text("To").font(.title)
                Text(selectedTravel.getDestinationSegment()?.destinationCity ?? "unknown").font(.headline)
                Text("Departure").font(.title)
                Text(selectedTravel.getDepartureSegment()?.dateTime.formatted(date: .numeric, time: .shortened) ?? "unknown").font(.headline)
                
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
}
