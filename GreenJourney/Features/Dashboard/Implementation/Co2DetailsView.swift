import SwiftUI

struct Co2DetailsView: View {
    @ObservedObject var viewModel: DashboardViewModel
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: .teal.opacity(0.3), radius: 5, x: 0, y: 3)
            VStack (spacing:0){
                Text("Co2 tracker")
                    .font(.title)
                    .foregroundStyle(.teal.opacity(0.8))
                    .padding(EdgeInsets(top: 15, leading: 15, bottom: 0, trailing: 0))
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                
                InfoRow(title: "Co2 emitted", value: String(format: "%.0f", viewModel.co2Emitted) + " Kg", icon: "carbon.dioxide.cloud", color: .red, imageValue: false, imageValueString: nil)
                
                InfoRow(title: "Co2 compensated", value: String(format: "%.0f", viewModel.co2Compensated) + " Kg", icon: "leaf", color: .green, imageValue: false, imageValueString: nil)
                
                InfoRow(title: "Trees planted", value: "\(viewModel.treesPlanted)", icon: "tree", color: Color(hue: 0.309, saturation: 1.0, brightness: 0.665), imageValue: false, imageValueString: nil)
            }
        }
        .padding(EdgeInsets(top: 7, leading: 15, bottom: 7, trailing: 15))

    }
}
