import SwiftData
import SwiftUI

struct DestinationPredictionView: View {
    @EnvironmentObject var viewModel: DestinationPredictionViewModel
    var confirm: ([CityCompleterDataset]) -> Void
    
    init(confirm: @escaping ([CityCompleterDataset]) -> Void) {
        self.confirm = confirm
    }
    
    var body: some View {
        Button (action: {
            withAnimation(.snappy(duration: 4)) {
                viewModel.getRecommendation()
                
                confirm(viewModel.predictedCity)
            }
        }){
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(.gray)
                HStack{
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
            }
            .fixedSize()
        }
        .padding()
    }
}
