import SwiftUI

struct ReturnOptionsView: View {
    @ObservedObject var viewModel: TravelSearchViewModel
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @Binding var navigationPath: NavigationPath
    var body: some View {
        ScrollView {
            VStack {
                HeaderView(from: viewModel.arrival.cityName, to: viewModel.departure.cityName, date: viewModel.dateReturnPicked)
                    .overlay(Color.clear.accessibilityIdentifier("headerView"))
                
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.gray)
                
                if (viewModel.returnOptions.isEmpty){
                    CircularProgressView()
                        .padding(.top, 50)
                }
                else{
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
        .background(colorScheme == .dark ? AppColors.backColorDark : AppColors.backColorLight)
    }
}
