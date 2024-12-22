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
                    .stroke(.gray)
                HStack{
                    Text("Don't know where to go? Ask AI.")
                        .foregroundColor(.gray)
                        //.padding()
                    Spacer()
                    Image(systemName: "apple.intelligence")
                        .font(.title)
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .foregroundStyle(.linearGradient(Gradient(colors: [.blue, .green]), startPoint: .bottomLeading, endPoint: .topTrailing))
                }
                .padding(5)
            }
            .fixedSize()
        }
    }
}
