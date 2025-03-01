import SwiftUI
import SwiftData

struct TravelSearchView: View {
    @Environment(\.modelContext) private var modelContext: ModelContext
    private var serverService: ServerServiceProtocol
    private var firebaseAuthService: FirebaseAuthServiceProtocol
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @StateObject var viewModel: TravelSearchViewModel
    @State private var departureTapped: Bool = false
    @State private var destinationTapped: Bool = false
    @State private var dateTapped: Bool = false
    @State private var dateReturnTapped: Bool = false
    @State private var triggerAI: Bool = false
    @State private var showAlertPrediction: Bool = false
    
    @State var counter: Int = 0
    @State var origin: CGPoint = .init(x: 0.5, y: 0.5)
    
    @Binding var navigationPath: NavigationPath
    
    @Query var users: [User]
    
    init(modelContext: ModelContext, navigationPath: Binding<NavigationPath>, serverService: ServerServiceProtocol, firebaseAuthService: FirebaseAuthServiceProtocol) {
        _viewModel = StateObject(wrappedValue: TravelSearchViewModel(modelContext: modelContext, serverService: serverService))
        _navigationPath = navigationPath
        self.serverService = serverService
        self.firebaseAuthService = firebaseAuthService
    }
    
    var body: some View {
        if users.first != nil {
            GeometryReader { geometry in
                ZStack {
                    // Colorful animated gradient
                    MeshGradientView()
                        .scaleEffect(1.3) // avoids clipping
                        .opacity(triggerAI ? 1 : 0)
                        .ignoresSafeArea()
                        .disabled(!triggerAI)
                    
                    // Brightness rim on edges
                    if triggerAI {
                        RoundedRectangle(cornerRadius: 52, style: .continuous)
                            .stroke(Color.white, style: .init(lineWidth: 4))
                            .blur(radius: 4)
                            .ignoresSafeArea()
                    }
                    ZStack {
                        Rectangle()
                            .fill(colorScheme == .dark ? Color.black : Color.white)
                            .ignoresSafeArea()
                        
                        VStack {
                            ZStack {
                                //button for avoid using AI
                                if triggerAI {
                                    Button (action: {
                                        viewModel.arrival = CityCompleterDataset()
                                        withAnimation(.bouncy(duration: 0.5)) {
                                            triggerAI = false
                                        }
                                    }) {
                                        HStack {
                                            Spacer()
                                            Image(systemName: "xmark.circle")
                                                .resizable()
                                                .foregroundStyle(.red.opacity(0.8))
                                                .frame(width: 35, height: 35)
                                        }
                                        .padding(.top, 30)
                                        .padding(.horizontal, 30)
                                        .accessibilityIdentifier("dismissAIButton")
                                    }
                                }
                                HStack {
                                    Text("Next journey")
                                        .font(.system(size: 32).bold())
                                        .padding()
                                        .fontWeight(.semibold)
                                        .opacity(triggerAI ? 0 : 1)
                                        .accessibilityIdentifier("travelSearchViewTitle")
                                    
                                    Spacer()
                                    
                                    NavigationLink(destination: UserPreferencesView(modelContext: modelContext, navigationPath: $navigationPath, serverService: serverService, firebaseAuthService: firebaseAuthService)) {
                                        Image(systemName: "person")
                                            .font(.title)
                                            .foregroundStyle(AppColors.mainGreen)
                                    }
                                    .disabled(triggerAI)
                                    .opacity(triggerAI ? 0 : 1)
                                    .accessibilityIdentifier("userPreferencesButton")
                                }
                            }
                            .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                            
                            Picker("", selection: $viewModel.oneWay) {
                                Text("One way").tag(true)
                                Text("Round trip").tag(false)
                            }
                            .pickerStyle(.segmented)
                            .padding()
                            .frame(maxWidth: 300) // set a max width to control the size
                            .accessibilityIdentifier("tripTypePicker")
                            
                            ZStack {
                                GeometryReader { geometry in
                                    Path { path in
                                        path.move(to: CGPoint(x: geometry.size.width/2 - 10, y: 0))
                                        
                                        // first curve
                                        path.addQuadCurve(
                                            to: CGPoint(x: geometry.size.width/2, y: geometry.size.height/2),
                                            control: CGPoint(x: 0, y: geometry.size.height/4)
                                        )
                                        path.addQuadCurve(
                                            to: CGPoint(x: geometry.size.width/2 + 25, y: geometry.size.height),
                                            control: CGPoint(x: geometry.size.width, y: geometry.size.height * 3/4)
                                        )
                                    }
                                    .stroke(style: StrokeStyle(lineWidth: 5, dash: [11, 6]))
                                    .foregroundColor(.primary)
                                }
                                .frame(width: 90, height: 120)
                                .position(x: 45, y: 100)
                                VStack {
                                    VStack {
                                        Text("From")
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(EdgeInsets(top: 10, leading: 40, bottom: 0, trailing: 40))
                                            .frame(alignment: .top)
                                            .font(.title)
                                            .accessibilityIdentifier("departureLabel")
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(colorScheme == .dark ? Color.white.opacity(0.6) : Color.black.opacity(0.6), lineWidth: 3)
                                                .frame(height: 50)
                                            
                                            Button(action: {
                                                departureTapped = true
                                            }) {
                                                Text(viewModel.departure.cityName == "" ? "Insert departure" : viewModel.departure.cityName)
                                                    .foregroundColor(viewModel.departure.cityName == "" ? .secondary : AppColors.mainGreen)
                                                    .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 0))
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .font(.title2)
                                                    .fontWeight(viewModel.departure.cityName == "" ? .light : .semibold)
                                            }
                                            .accessibilityIdentifier("departureButton")
                                        }
                                        .background(colorScheme == .dark ? Color(red: 48/255, green: 48/255, blue: 48/255) : Color.white)
                                        .cornerRadius(10)
                                        .padding(EdgeInsets(top: 0, leading: 40, bottom: 20, trailing: 40))
                                    }
                                    .fullScreenCover(isPresented: $departureTapped ) {
                                        CompleterView(modelContext: modelContext, searchText: viewModel.departure.cityName,
                                                      onBack: {
                                            departureTapped = false
                                        },
                                                      onClick: { city in
                                            departureTapped = false
                                            viewModel.departure = city
                                        },
                                                      departure: true)
                                    }
                                    
                                    VStack{
                                        Text("To")
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(EdgeInsets(top: 10, leading: 40, bottom: 0, trailing: 40))
                                            .frame(alignment: .top)
                                            .font(.title)
                                            .accessibilityIdentifier("destinationLabel")
                                        ZStack{
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(colorScheme == .dark ? Color.white.opacity(0.6) : Color.black.opacity(0.6), lineWidth: 3)
                                                .frame(height: 50)
                                            
                                            Button(action: {
                                                if !triggerAI {
                                                    destinationTapped = true
                                                }
                                            }) {
                                                Text(viewModel.arrival.cityName == "" ? "Insert destination" : viewModel.arrival.cityName)
                                                    .foregroundColor (viewModel.arrival.cityName == "" ? Color.secondary : triggerAI ? Color.white : AppColors.mainGreen)
                                                    .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 0))
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .font(.title2)
                                                    .fontWeight(viewModel.arrival.cityName == "" ? .light : .semibold)
                                            }
                                            .accessibilityIdentifier("destinationButton")
                                        }
                                        .background(triggerAI ? LinearGradient(gradient: Gradient(colors: [.green, .cyan, .blue, .cyan, .green]), startPoint: .bottomLeading, endPoint: .topTrailing) : LinearGradient(gradient: Gradient(colors: [colorScheme == .dark ? Color(red: 48/255, green: 48/255, blue: 48/255) : Color.white]), startPoint: .bottomLeading, endPoint: .topTrailing))
                                        .cornerRadius(10)
                                        .padding(EdgeInsets(top: 0, leading: 40, bottom: 20, trailing: 40))
                                    }
                                    .fullScreenCover(isPresented: $destinationTapped ) {
                                        CompleterView(modelContext: modelContext, searchText: viewModel.arrival.cityName,
                                                      onBack: {
                                            destinationTapped = false
                                        },
                                                      onClick: { city in
                                            destinationTapped = false
                                            triggerAI = false
                                            viewModel.arrival = city
                                        },
                                                      departure: false
                                        )
                                    }
                                }
                            }
                            Spacer()
                            VStack {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(colorScheme == .dark ? Color.white.opacity(0.6) : Color.black.opacity(0.6), lineWidth: 1.5)
                                        .fill(AppColors.mainGreen.opacity(0.4))
                                    Button(action: {
                                        dateTapped = true
                                    }) {
                                        HStack{
                                            Image(systemName: "calendar")
                                                .font(.title2)
                                                .padding(.leading, 8)
                                            Text("Outward")
                                                .font(.headline)
                                                .frame(width: 100, alignment: .leading)
                                            Text(viewModel.datePicked.formatted(date: .numeric, time: .shortened))

                                            Spacer()
                                            
                                        }
                                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                                    }
                                    .padding(.vertical, 10)
                                    .accessibilityIdentifier("outwardDateButton")
                                }
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(colorScheme == .dark ? Color.white.opacity(0.6) : Color.black.opacity(0.6), lineWidth: 1.5)
                                        .fill(viewModel.oneWay ? Color.gray.opacity(0.5) : AppColors.mainGreen.opacity(0.4))
                                    Button(action:  {
                                        dateReturnTapped = true
                                    }) {
                                        HStack {
                                            Image(systemName: "calendar")
                                                .font(.title2)
                                            .padding(.leading, 8)
                                            Text("Return")
                                                .font(.headline)
                                                .frame(width: 100, alignment: .leading)

                                            Text(viewModel.dateReturnPicked.formatted(date: .numeric, time: .shortened))
                                                .opacity(viewModel.oneWay ? 0 : 1)
                                            Spacer()
                                            
                                        }
                                        .foregroundStyle(viewModel.oneWay ? Color.secondary : colorScheme == .dark ? Color.white : Color.black)
                                    }
                                    .padding(.vertical, 10)
                                    .disabled(viewModel.oneWay)
                                    .accessibilityIdentifier("returnDateButton")
                                }
                            }
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 45)
                            
                            Spacer()
                            
                            Button(action: {
                                Task {
                                    await viewModel.computeRoutes()
                                }
                                navigationPath.append(NavigationDestination.OutwardOptionsView(viewModel))
                                triggerAI = false
                                
                            }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill((viewModel.departure.iata == "" || viewModel.arrival.iata == "") ? .black.opacity(0.3) : AppColors.mainGreen)
                                    HStack{
                                        Text("Search")
                                            .font(.title)
                                            .foregroundStyle(.white)
                                            .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                                    }
                                }
                                .fixedSize()
                            }
                            .disabled(viewModel.departure.iata == "" || viewModel.arrival.iata == "")
                            .padding(.top, 20)
                            .accessibilityIdentifier("searchButton")
                            
                            
                            HStack {
                                if !triggerAI {
                                    DestinationPredictionView(
                                        modelContext: modelContext,
                                        confirm: { predictedCities in
                                            if let firstCity = predictedCities.first {
                                                viewModel.predictionShown = 0
                                                viewModel.arrival = firstCity
                                                viewModel.predictedCities = predictedCities
                                                withAnimation(.bouncy(duration: 0.5)) {
                                                    self.triggerAI = true
                                                }
                                            } else {
                                                showAlertPrediction = true
                                            }
                                        }
                                    )
                                    .alert(isPresented: $showAlertPrediction) {
                                        Alert(
                                            title: Text("An error occurred while computing the prediction, try again later"),
                                            dismissButton: .default(Text("OK")) {}
                                        )
                                    }
                                }
                                else {
                                    Spacer()
                                    
                                    //button for see another prediction
                                    Button (action: {
                                        if viewModel.predictedCities.count == viewModel.predictionShown + 1 {
                                            viewModel.predictionShown = 0
                                        }
                                        else {
                                            viewModel.predictionShown += 1
                                        }
                                        withAnimation(.bouncy(duration: 0.5)) {
                                            viewModel.arrival = viewModel.predictedCities[viewModel.predictionShown]
                                        }
                                    }) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(.linearGradient(Gradient(colors: [.green, .blue]), startPoint: .bottomLeading, endPoint: .topTrailing), lineWidth: 2)
                                            HStack {
                                                Text("Generate a new prediction")
                                                    .foregroundStyle(.gray)
                                                    .padding(.leading, 5)
                                                Spacer()
                                                Image(systemName: "apple.intelligence")
                                                    .font(.title)
                                                    .foregroundStyle(.linearGradient(Gradient(colors: [.blue, .green]), startPoint: .bottomLeading, endPoint: .topTrailing))
                                            }
                                            .padding(5)
                                            .padding(.horizontal, 5)
                                        }
                                        .frame(width: 340, height: 60)
                                    }
                                    .accessibilityIdentifier("newGenerationButton")
                                    
                                    Spacer()
                                }
                            }
                            .position(x: geometry.size.width/2, y: 60)
                            
                            Spacer()
                            
                        }
                    }
                    .mask {
                        AnimatedRectangle(size: geometry.size, cornerRadius: 48, t: CGFloat(0.0))
                            .scaleEffect(triggerAI ? 1 : 1.2)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .blur(radius: triggerAI ? 28 : 8)
                        
                    }
                }
                .sheet(isPresented: $dateTapped) {
                    DatePickerView(dateTapped: $dateTapped, title: "Select Outward Date", date: $viewModel.datePicked)
                        .presentationDetents([.height(530)])
                        .presentationCornerRadius(30)
                        }
                .sheet(isPresented: $dateReturnTapped) {
                    DatePickerView(dateTapped: $dateReturnTapped, title: "Select Return Date", date: $viewModel.dateReturnPicked)
                        .presentationDetents([.height(530)])
                        .presentationCornerRadius(30)
                        }
                
            }
            .toolbar((triggerAI) ? .hidden : .automatic, for: .tabBar)
            .navigationBarBackButtonHidden(triggerAI)
            .onAppear() {
                viewModel.resetParameters()
            }
        }
    }
}


struct DatePickerView: View {
    @Binding var dateTapped: Bool
    @State private var offsetY: CGFloat = 0
    var title: String
    @Binding var date: Date
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack (spacing: 0){
            Capsule()
                .frame(width: 40, height: 5)
                .foregroundColor(.gray)
                .padding(.top, 8)
            ZStack {
                HStack {
                    Spacer()
                    Button("Done") {
                        dateTapped = false
                    }
                    .fontWeight(.bold)
                    .padding(.trailing, 20)
                    .padding(.bottom, 15)
                    .accessibilityIdentifier("datePickerDoneButton")
                }
            
            Text(title)
                .font(.system(size: 22).bold())
                .padding(.top, 30)
                .accessibilityIdentifier("datePickerTitle")
        }
            DatePicker("", selection: $date, in: Date()...Date.distantFuture)
                .datePickerStyle(.graphical)
                .labelsHidden()
                .accessibilityIdentifier("datePickerElement")
                .padding(.top, 20)
            Spacer()
        }
        .ignoresSafeArea()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        
    }
}

