import SwiftUI

struct TravelsView: View {
    @ObservedObject var viewModel = TravelsViewModel()
    @AppStorage("loggedUserUID") var loggedUserUID: String?
    
    var body: some View {
            List(viewModel.travelDetails) { travelDetail in
                VStack(alignment: .leading) {
                    Text("Travel ID: \(travelDetail.travel.travelID)")
                }
            }
            .onAppear {
                viewModel.fetchTravels(for: 2)
            }
        }
}
