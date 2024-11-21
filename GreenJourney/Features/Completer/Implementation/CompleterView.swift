import SwiftUI
import SwiftData

struct CompleterView: View {
    @StateObject private var viewModel: CompleterViewModel
    var onBack: () -> Void
    init(modelContext: ModelContext, searchText: String, onBack: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: CompleterViewModel(modelContext: modelContext, searchText: searchText))
        self.onBack = onBack
    }
    
    var body: some View {
        VStack {
            TextField("Search City", text: $viewModel.searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            List(viewModel.suggestions, id: \.id) { city in
                VStack(alignment: .leading) {
                    Text(city.city).font(.headline)
                    Text("\(city.countryName) (\(city.countryCode))")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            Button("Back") { onBack() }
        }
    }
}
