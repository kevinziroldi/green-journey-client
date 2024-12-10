import SwiftUI
import SwiftData

struct CompleterView: View {
    @EnvironmentObject private var viewModel: CompleterViewModel
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @FocusState var textfieldOpen: Bool
    var onBack: () -> Void
    var onClick: (CityCompleterDataset) -> Void
    var searchText: String
    
    init(searchText: String, onBack: @escaping () -> Void, onClick: @escaping (CityCompleterDataset) -> Void) {
        self.onBack = onBack
        self.onClick = onClick
        self.searchText = searchText
    }
    
    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
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
                    TextField("Search City", text: $viewModel.searchText)
                        .font(.title2)
                        .textInputAutocapitalization(.words)
                        .focused($textfieldOpen)
                        .padding()
                }
                .padding()
            }
            .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10))
            
            
            List(viewModel.suggestions, id: \.id) { city in
                VStack(alignment: .leading) {
                    Text(city.cityName).font(.headline)
                    Text("\(city.countryName) (\(city.countryCode))")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .onTapGesture {
                    onClick(city)
                }
            }
            .scrollDismissesKeyboard(.interactively)
            HStack {
                Button("Back") {
                    onBack()
                }
                .buttonStyle(.bordered)
            }
            .padding()
        }
        .onAppear(){
            viewModel.searchText = self.searchText
            textfieldOpen = true
        }
    }
}
