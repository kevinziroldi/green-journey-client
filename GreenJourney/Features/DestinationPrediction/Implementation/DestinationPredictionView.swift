import SwiftData
import SwiftUI

struct DestinationPredictionView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @StateObject private var viewModel: DestinationPredictionViewModel
    private var confirm: ([CityCompleterDataset]) -> Void
    
    init(modelContext: ModelContext, confirm: @escaping ([CityCompleterDataset]) -> Void) {
        _viewModel = StateObject(wrappedValue: DestinationPredictionViewModel(modelContext: modelContext))
        self.confirm = confirm
    }
    
    var body: some View {
        if horizontalSizeClass == .compact {
            // iOS
            
            Button(action: {
                viewModel.getRecommendation()
                confirm(viewModel.predictedCities)
                
            }){
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.linearGradient(Gradient(colors: [.green, .blue]), startPoint: .bottomLeading, endPoint: .topTrailing), lineWidth: 3)
                        .fill(.linearGradient(Gradient(colors: [.green.opacity(0.2), .blue.opacity(0.2)]), startPoint: .bottomLeading, endPoint: .topTrailing))
                    HStack {
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
                .frame( height: 60)
            }
            .accessibilityIdentifier("getRecommendationButton")
        } else {
            // iPadOS
            
            Button(action: {
                viewModel.getRecommendation()
                confirm(viewModel.predictedCities)
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.linearGradient(Gradient(colors: [.green, .blue]), startPoint: .bottomLeading, endPoint: .topTrailing), lineWidth: 3)
                        .fill(.linearGradient(Gradient(colors: [.green.opacity(0.2), .blue.opacity(0.2)]), startPoint: .bottomLeading, endPoint: .topTrailing))
                    
                    Text("Don't know where to go? Ask AI.")
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .multilineTextAlignment(.center)
                        .padding(5)

                    HStack {
                        Spacer()
                        Image(systemName: "apple.intelligence")
                            .font(.title)
                            .clipShape(Circle())
                            .foregroundStyle(.linearGradient(Gradient(colors: [.blue, .green]), startPoint: .bottomLeading, endPoint: .topTrailing))
                    }
                    .padding(5)
                    .padding(.horizontal, 5)
                }
                .frame(height: 60)
            }
            .accessibilityIdentifier("getRecommendationButton")
        }
    }
}
