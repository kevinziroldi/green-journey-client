import SwiftUI
import SwiftData

struct CompleterView: View {
    @StateObject private var viewModel: CompleterViewModel
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @FocusState var textfieldOpen: Bool
    var onBack: () -> Void
    var onClick: (CityCompleterDataset) -> Void
    var searchText: String
    
    init(modelContext: ModelContext, searchText: String, onBack: @escaping () -> Void, onClick: @escaping (CityCompleterDataset) -> Void, departure: Bool) {
        _viewModel = StateObject(wrappedValue: CompleterViewModel(modelContext: modelContext, departure: departure))
        self.onBack = onBack
        self.onClick = onClick
        self.searchText = searchText
    }
    
    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .stroke(colorScheme == .dark ? Color.white.opacity(0.6) : Color.black.opacity(0.6), lineWidth: 2)
                    .fill(colorScheme == .dark ? Color(red: 48/255, green: 48/255, blue: 48/255) : Color.white)
                    .frame(height: 50)
                
                HStack {
                    Button(action: {
                        onBack()
                    }) {
                        Image(systemName: "chevron.backward")
                            .font(.title2)
                            .foregroundStyle(.gray)
                    }
                    .accessibilityIdentifier("backButtonTop")
                    
                    TextField("Search City", text: $viewModel.searchText)
                        .font(.title2)
                        .textInputAutocapitalization(.words)
                        .focused($textfieldOpen)
                        .padding()
                        .accessibilityIdentifier("searchedCityTextField")
                }
                .padding()
            }
            .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10))
            
            
            List(viewModel.suggestions, id: \.id) { city in
                Button(action: {
                    onClick(city)
                }) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(city.cityName).font(.headline)
                                .foregroundStyle(colorScheme == .dark ? .white: .black)
                            Text("\(city.countryName) (\(city.countryCode))")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .overlay(Color.clear.accessibilityIdentifier("listElement_\(city.iata)_\(city.countryCode)"))
                        
                        Spacer()
                        if viewModel.departure && viewModel.searchText == "" {
                            Image(systemName: "clock.arrow.trianglehead.counterclockwise.rotate.90")
                                .font(.title3)
                                .foregroundStyle(colorScheme == .dark ? .white: .black)
                                .padding(.trailing, 10)
                        }
                        else if !viewModel.departure && viewModel.searchText == "" {
                            Text("🔥")
                                .font(.title3)
                                .padding(.trailing, 10)
                        }
                    }
                }
                .listRowBackground(
                    colorScheme == .dark
                    ? AppColors.blockColorDark
                    : Color(UIColor.systemBackground)
                )
            }
            .scrollContentBackground(.hidden)
            .scrollDismissesKeyboard(.immediately)
        }
        .background(colorScheme == .dark ? AppColors.backColorDark : AppColors.backColorLight)
        .onAppear(){
            viewModel.searchText = self.searchText
            textfieldOpen = true
        }
    }
}
