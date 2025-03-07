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
                        HStack {
                            NavigationLink (destination: OptionDetailsView(option: viewModel.returnOptions[option], viewModel: viewModel, navigationPath: $navigationPath)){
                                OptionCardView(option: viewModel.returnOptions[option], viewModel: viewModel)
                                    .contentShape(Rectangle())
                            }
                            .accessibilityIdentifier("returnOption_\(option)")
                        }
                        .padding(.horizontal, 10)
                        .frame(maxWidth: 800)
                        .buttonStyle(.plain)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}
