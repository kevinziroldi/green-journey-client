import SwiftData
import SwiftUI

struct DestinationPredictionView: View {
    @StateObject var viewModel: DestinationPredictionViewModel
    var confirm: ([CityCompleterDataset]) -> Void
    
    
    init(modelContext: ModelContext, confirm: @escaping ([CityCompleterDataset]) -> Void) {
        _viewModel = StateObject(wrappedValue: DestinationPredictionViewModel(modelContext: modelContext))
        self.confirm = confirm
    }
    
    var body: some View {
        Button (action: {
            viewModel.getRecommendation()
            confirm(viewModel.predictedCities)
            
        }){
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(.linearGradient(Gradient(colors: [.green, .blue]), startPoint: .bottomLeading, endPoint: .topTrailing), lineWidth: 3)
                HStack{
                    Text("Don't know where to go? Ask AI.")
                        .foregroundColor(.gray)
                    Spacer()
                    Image(systemName: "apple.intelligence")
                        .font(.title)
                        .clipShape(Circle())
                        .foregroundStyle(.linearGradient(Gradient(colors: [.blue, .green]), startPoint: .bottomLeading, endPoint: .topTrailing))
                }
                .padding(5)
                .padding(.horizontal, 5)
            }
            .frame(width: 340, height: 60)
        }
        .accessibilityIdentifier("getRecommendationButton")
    }
}
