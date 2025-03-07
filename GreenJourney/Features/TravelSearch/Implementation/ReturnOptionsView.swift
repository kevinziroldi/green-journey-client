import SwiftUI

struct ReturnOptionsView: View {
    @ObservedObject var viewModel: TravelSearchViewModel
    @Binding var navigationPath: NavigationPath
    var body: some View {
        HeaderView(from: viewModel.arrival.cityName, to: viewModel.departure.cityName, date: viewModel.dateReturnPicked)
            .overlay(Color.clear.accessibilityIdentifier("headerView"))

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
                        NavigationLink (destination: OptionDetailsView(option: viewModel.returnOptions[option], viewModel: viewModel, navigationPath: $navigationPath)){
                            OptionCardView(option: viewModel.returnOptions[option], viewModel: viewModel)
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
