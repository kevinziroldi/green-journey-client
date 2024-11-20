import SwiftData
import SwiftUI

struct DestinationPredictionView: View {
    @StateObject var viewModel: DestinationPredictionViewModel
    var confirm: (String, String, String) -> Void
    
    init(modelContext: ModelContext, confirm: @escaping (String, String, String) -> Void) {
        _viewModel = StateObject(wrappedValue: DestinationPredictionViewModel(modelContext: modelContext))
        self.confirm = confirm
    }
    
    var body: some View {
        Button (action: {
            withAnimation(.snappy(duration: 4)) {
                //TODO change
                //viewModel.destination = "Milan"
                viewModel.getRecommendation()
                
                confirm(viewModel.locode, viewModel.city, viewModel.country)
            }
        }){
            Text("Don't know where to go? Ask AI.")
                .foregroundColor(.gray)
                .padding()
            Spacer()
            Image(systemName: "apple.intelligence")
                .font(.title)
                .frame(width: 50, height: 50)
            //.background(.white)
                .clipShape(Circle())
                .padding(EdgeInsets(top: 0, leading: 5, bottom: 5, trailing: 5))
                .foregroundStyle(.linearGradient(Gradient(colors: [.blue, .pink]), startPoint: .bottomLeading, endPoint: .topTrailing))
            
        }
        .cornerRadius(10)
        .border(.gray, width: 1)
        .padding()
    }
}
