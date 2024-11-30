import SwiftUI

struct TravelDetailsView: View {
    @ObservedObject var viewModel: MyTravelsViewModel
    @Binding var navigationPath: NavigationPath
    
    var body : some View {
        VStack {
            Text(viewModel.selectedTravel?.segments.first?.departureCity ?? "unknown")
        }
    }
}
