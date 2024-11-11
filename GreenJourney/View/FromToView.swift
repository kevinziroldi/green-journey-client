import SwiftUI
import SwiftData
import MapKit

struct FromToView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: FromToViewModel
    @FocusState private var isDepartureFocused: Bool
    @FocusState private var isDestinationFocused: Bool
    @State private var isNavigationActive: Bool = false
    
    init(modelContext: ModelContext) {
        _viewModel = StateObject(wrappedValue: FromToViewModel(modelContext: modelContext))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack{
                    VStack{
                        HStack {
                            Text("Next journey")
                                .font(.title)
                                .padding()
                            
                            Spacer()
                            
                            NavigationLink(destination: UserPreferencesView(modelContext: modelContext)) {
                                Image(systemName: "person")
                                    .font(.title)
                            }
                            .padding()
                        }
                        
                        TextField("insert a departure", text: $viewModel.departure)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .focused($isDepartureFocused)
                            .padding(15)
                            .onTapGesture {
                                isDepartureFocused = true
                            }
                            .scrollDismissesKeyboard(.interactively)
                        if isDepartureFocused && !viewModel.suggestions.isEmpty {
                            List(viewModel.suggestions, id: \.self) { suggestion in
                                VStack(alignment: .leading) {
                                    Text(suggestion.title)
                                        .font(.headline)
                                    Text(suggestion.subtitle)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                .padding(.vertical, 4)
                                .onTapGesture {
                                    viewModel.departure = suggestion.title
                                    isDepartureFocused = false
                                }
                            }
                            .listStyle(PlainListStyle())
                            .frame(maxHeight: 250)
                            .cornerRadius(10)
                            .padding([.leading, .trailing], 16)
                        }
                    }
                    Spacer()
                    
                    VStack{
                        
                        TextField("insert a destination", text: $viewModel.destination)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .focused($isDestinationFocused)
                            .padding(15)
                            .onTapGesture {
                                isDestinationFocused = true
                            }
                            .scrollDismissesKeyboard(.interactively)
                        if isDestinationFocused && !viewModel.suggestions.isEmpty {
                            List(viewModel.suggestions, id: \.self) { suggestion in
                                VStack(alignment: .leading) {
                                    Text(suggestion.title)
                                        .font(.headline)
                                    Text(suggestion.subtitle)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                .padding(.vertical, 4)
                                .onTapGesture {
                                    viewModel.destination = suggestion.title
                                    isDestinationFocused = false
                                }
                            }
                            .listStyle(PlainListStyle())
                            .frame(maxHeight: 250)
                            .cornerRadius(10)
                            .padding([.leading, .trailing], 16)
                        }
                    }
                    Spacer()
                    HStack {
                        Button ("one way") {
                            if (!viewModel.oneWay) {
                                viewModel.oneWay = true
                            }
                        }
                        .foregroundColor(viewModel.oneWay ? Color.red : Color.secondary)
                        
                        Button ("return") {
                            if (viewModel.oneWay) {
                                viewModel.oneWay = false
                            }
                        }
                        .foregroundColor(viewModel.oneWay ? Color.secondary : Color.red)
                    }
                    DatePicker("outward",selection: $viewModel.datePicked)
                        .padding(15)
                    if (!viewModel.oneWay) {
                        DatePicker("return",selection: $viewModel.dateReturnPicked)
                            .padding(15)
                    }
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Button ("compute"){
                        viewModel.insertCoordinates()   //compute coordinates for departure and destination
                        viewModel.computeRoutes(from: viewModel.departure, to: viewModel.destination, on: viewModel.datePicked, return: viewModel.dateReturnPicked, oneWay: viewModel.oneWay)
                        isNavigationActive = true
                    }
                    .navigationDestination(isPresented: $isNavigationActive) {
                        TravelOptionsView(viewModel: viewModel)
                    }
                    Spacer()
                    Spacer()
                }
            }
        }
    }
}
