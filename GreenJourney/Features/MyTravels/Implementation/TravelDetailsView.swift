import SwiftUI

struct TravelDetailsView: View {
    @ObservedObject var viewModel: MyTravelsViewModel
    @Binding var navigationPath: NavigationPath
    
    var body : some View {
        VStack {
            Text("From").font(.title)
            Text(viewModel.selectedTravel?.getDepartureSegment()?.departureCity ?? "unknown").font(.headline)
            
            Text("To").font(.title)
            Text(viewModel.selectedTravel?.getDestinationSegment()?.destinationCity ?? "unknown").font(.headline)
            
            Button ("COMPENSATION TRIAL") {
                viewModel.compensateCO2()
            }
        }
    }
}
