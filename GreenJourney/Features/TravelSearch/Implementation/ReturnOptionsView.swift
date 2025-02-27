import SwiftUI

struct ReturnOptionsView: View {
    @ObservedObject var viewModel: TravelSearchViewModel
    @Binding var navigationPath: NavigationPath
    var body: some View {
        VStack (spacing: 0){
            HStack {
                Text(viewModel.arrival.cityName)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding()
                    .accessibilityIdentifier("arrivalLabel")
                
                GeometryReader { geometry in
                    ZStack {
                        Path { path in
                            path.move(to: CGPoint(x: 0, y: geometry.size.height/2))
                            
                            path.addQuadCurve(
                                to: CGPoint(x: geometry.size.width, y: geometry.size.height/2),
                                control: CGPoint(x: geometry.size.width/2, y: 0)
                            )
                        }
                        .stroke(style: StrokeStyle(lineWidth: 4, dash: [15, 8]))
                        .foregroundColor(.primary)
                        
                        Circle()
                            .stroke(Color.black, lineWidth: 5)
                            .fill(Color.white)
                            .frame(width: 10, height: 10)
                            .position(x: geometry.size.width, y: geometry.size.height/2)
                        
                        Circle()
                            .stroke(Color.black, lineWidth: 5)
                            .fill(Color.white)
                            .frame(width: 10, height: 10)
                            .position(x: 0, y: geometry.size.height/2)
                    }
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                }
                .frame(width: 180, height: 75, alignment: .top)
                .accessibilityIdentifier("fromToLine")
                
                Text(viewModel.departure.cityName)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding()
                    .accessibilityIdentifier("departureLabel")
            }
            
            Text(viewModel.dateReturnPicked.formatted(date: .numeric, time: .shortened))
                .accessibilityIdentifier("datePicked")
        }
        Rectangle()
            .frame(height: 1)
            .foregroundColor(.gray)
        
        if (viewModel.returnOptions.isEmpty){
            Spacer()
            CircularProgressView()
            Spacer()
            Spacer()
            Spacer()
            Spacer()
        }
        else{
            ScrollView {
                VStack {
                    ForEach (viewModel.returnOptions.indices, id: \.self) { option in
                        NavigationLink (destination: OptionDetailsView(segments: viewModel.returnOptions[option], viewModel: viewModel, navigationPath: $navigationPath)){
                            OptionCard(option: viewModel.returnOptions[option], viewModel: viewModel)
                                .padding(.horizontal, 10)
                        }
                        .accessibilityIdentifier("returnOption_\(option)")
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
