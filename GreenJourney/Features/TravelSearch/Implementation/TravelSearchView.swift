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
                        .accessibilityIdentifier("meshGradientView")
                    
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
                            HStack {
                                Text("Next journey")
                                    .font(.title)
                                    .padding()
                                    .accessibilityIdentifier("travelSearchViewTitle")
                                
                                Spacer()
                                
                                NavigationLink(destination: UserPreferencesView(modelContext: modelContext, navigationPath: $navigationPath, serverService: serverService, firebaseAuthService: firebaseAuthService)) {
                                    Image(systemName: "person")
                                        .font(.title)
                                        .accessibilityIdentifier("userPreferencesLink")
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
                                        // Punto iniziale in alto a sinistra
                                        path.move(to: CGPoint(x: geometry.size.width/2 - 10, y: 0))
                                        
                                        // Prima curva della "S" verso destra e in basso
                                        path.addQuadCurve(
                                            to: CGPoint(x: geometry.size.width/2, y: geometry.size.height/2),
                                            control: CGPoint(x: 0, y: geometry.size.height/4)
                                        )
                                        path.addQuadCurve(
                                            to: CGPoint(x: geometry.size.width/2 + 25, y: geometry.size.height),
                                            control: CGPoint(x: geometry.size.width, y: geometry.size.height * 3/4)
                                        )
                                    }
                                    .stroke(style: StrokeStyle(lineWidth: 5, dash: [11, 6])) // Stile tratteggiato
                                    .foregroundColor(.primary) // Colore della linea
                                }
                                .frame(width: 100, height: 110)
                                .padding(EdgeInsets(top: 0, leading: 0, bottom: 80, trailing: 320))
                                
                                VStack {
                                    VStack {
                                        Text("From")
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(EdgeInsets(top: 10, leading: 50, bottom: 0, trailing: 50))
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
                                                    .foregroundColor(viewModel.departure.cityName == "" ? .secondary : .blue)
                                                    .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 0))
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .font(.title2)
                                                    .fontWeight(viewModel.departure.cityName == "" ? .light : .semibold)
                                            }
                                            .accessibilityIdentifier("departureButton")
                                        }
                                        .background(colorScheme == .dark ? Color(red: 48/255, green: 48/255, blue: 48/255) : Color.white)
                                        .cornerRadius(10)
                                        .shadow(radius: 5)
                                        .padding(EdgeInsets(top: 0, leading: 50, bottom: 20, trailing: 50))
                                        
                                        
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
                                            .padding(EdgeInsets(top: 10, leading: 50, bottom: 0, trailing: 50))
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
                                                    .foregroundColor (getColorDest())
                                                    .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 0))
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .font(.title2)
                                                    .fontWeight(viewModel.arrival.cityName == "" ? .light : .semibold)
                                            }
                                            .accessibilityIdentifier("destinationButton")
                                        }
                                        .background(triggerAI ? LinearGradient(gradient: Gradient(colors: [.green, .cyan, .blue, .cyan, .green]), startPoint: .bottomLeading, endPoint: .topTrailing) : LinearGradient(gradient: Gradient(colors: [colorScheme == .dark ? Color(red: 48/255, green: 48/255, blue: 48/255) : Color.white]), startPoint: .bottomLeading, endPoint: .topTrailing))
                                        .cornerRadius(10)
                                        .shadow(radius: 5)
                                        .padding(EdgeInsets(top: 0, leading: 50, bottom: 20, trailing: 50))
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
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke()
                                HStack (spacing: 0) {
                                    Button(action: {
                                        dateTapped = true
                                    }) {
                                        VStack{
                                            Text("Outward date")
                                                .font(.headline)
                                            Text(viewModel.datePicked.formatted(date: .numeric, time: .shortened))
                                                .font(.subheadline)
                                                .padding(.top, 5)
                                            
                                        }
                                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                                        
                                    }
                                    .padding(EdgeInsets(top: 10, leading: 25, bottom: 10, trailing: 25))
                                    .accessibilityIdentifier("outwardDateButton")
                                    Rectangle()
                                        .frame(width: 2)
                                        .foregroundStyle(.gray)
                                    
                                    Button(action:  {
                                        dateReturnTapped = true
                                        
                                    }) {
                                        VStack {
                                            Text("Return date")
                                                .font(.headline)
                                            Text(viewModel.dateReturnPicked.formatted(date: .numeric, time: .shortened))
                                                .opacity(viewModel.oneWay ? 0 : 1)
                                                .font(.subheadline)
                                                .padding(.top, 5)
                                        }
                                        .foregroundStyle(viewModel.oneWay ? Color.secondary : colorScheme == .dark ? Color.white : Color.black)
                                    }
                                    .padding(EdgeInsets(top: 10, leading: 25, bottom: 10, trailing: 25))
                                    .disabled(viewModel.oneWay)
                                    .accessibilityIdentifier("returnDateButton")
                                }
                            }
                            .fixedSize()
                            
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
                                        .fill((viewModel.departure.iata == "" || viewModel.arrival.iata == "") ? .black.opacity(0.3): .blue)
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
                            
                            Spacer()
                            
                            HStack {
                                if !triggerAI {
                                    DestinationPredictionView(
                                        modelContext: modelContext,
                                        confirm: { predictedCities in
                                            if let firstCity = predictedCities.first {
                                                viewModel.predictionShown = 0
                                                viewModel.arrival = firstCity
                                                viewModel.predictedCities = predictedCities
                                                withAnimation(.bouncy(duration: 1)) {
                                                    self.triggerAI = true
                                                }
                                            } else {
                                                showAlertPrediction = true
                                            }
                                        })
                                    .alert(isPresented: $showAlertPrediction) {
                                        Alert(
                                            title: Text("An error occurred while computing the prediction, try again later"),
                                            dismissButton: .default(Text("OK")) {}
                                        )
                                    }
                                }
                                else {
                                    Spacer()
                                    //button for avoid using AI
                                    Button (action: {
                                        viewModel.arrival = CityCompleterDataset()
                                        withAnimation(.bouncy(duration: 1)) {
                                            triggerAI = false
                                        }
                                    }) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(.gray)
                                            HStack {
                                                ZStack{
                                                    Image(systemName: "apple.intelligence")
                                                        .resizable()
                                                        .foregroundStyle(.gray)
                                                        .frame(width: 30, height: 30)
                                                    Image(systemName: "xmark")
                                                        .resizable()
                                                        .foregroundStyle(.red.opacity(0.8))
                                                        .frame(width: 30, height: 30)
                                                }
                                                .frame(height: 50)
                                                Text("Do not use AI")
                                                    .foregroundStyle(.gray)
                                            }
                                            .padding(5)
                                            .padding(.horizontal, 5)
                                        }
                                        .frame(width: geometry.size.width/2 - 20, height: 60)
                                    }
                                    Spacer()
                                    //button for see another prediction
                                    Button (action: {
                                        if viewModel.predictedCities.count == viewModel.predictionShown + 1 {
                                            viewModel.predictionShown = 0
                                        }
                                        else {
                                            viewModel.predictionShown += 1
                                        }
                                        withAnimation(.bouncy(duration: 1)) {
                                            viewModel.arrival = viewModel.predictedCities[viewModel.predictionShown]
                                        }
                                    }) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(.gray)
                                            HStack {
                                                ZStack{
                                                    Image(systemName: "apple.intelligence")
                                                        .resizable()
                                                        .foregroundStyle(.linearGradient(Gradient(colors: [.blue, .green]), startPoint: .bottomLeading, endPoint: .topTrailing))
                                                        .frame(width: 25, height: 25)
                                                    Image(systemName: "arrow.trianglehead.2.clockwise")
                                                        .resizable()
                                                        .foregroundStyle(.gray.opacity(0.7))
                                                        .frame(width: 40, height: 40)
                                                }
                                                .frame(height: 50)
                                                Text("New generation")
                                                    .foregroundStyle(.gray)
                                            }
                                            .padding(5)
                                            .padding(.horizontal, 5)
                                        }
                                        .frame(width: geometry.size.width/2 - 20, height: 60)
                                        
                                    }
                                    
                                    Spacer()
                                }
                            }
                            .position(x: geometry.size.width/2, y: 100)
                            
                            Spacer()
                            
                        }
                    }
                    .allowsHitTesting(!(dateTapped || dateReturnTapped))
                    .mask {
                        AnimatedRectangle(size: geometry.size, cornerRadius: 48, t: CGFloat(0.0))
                            .scaleEffect(triggerAI ? 1 : 1.2)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .blur(radius: triggerAI ? 28 : 8)
                    }
                    
                    // Modale per il DatePicker "Outward date"
                    if dateTapped {
                        DatePickerView(dateTapped: $dateTapped, title: "Select Outward Date", date: $viewModel.datePicked)
                            .transition(.move(edge: .bottom))
                    }
                    
                    // Modale per il DatePicker "Return date"
                    if dateReturnTapped && !viewModel.oneWay {
                        DatePickerView(dateTapped: $dateReturnTapped, title: "Select Return Date", date: $viewModel.dateReturnPicked)
                            .transition(.move(edge: .bottom))
                    }
                }
            }
            .toolbar((triggerAI || dateTapped || dateReturnTapped) ? .hidden : .automatic, for: .tabBar)
            .navigationBarBackButtonHidden(triggerAI || dateTapped || dateReturnTapped)
        }
        
    }
    
    private func getColorDest () -> Color {
        if viewModel.arrival.cityName == "" {
            return .secondary
        }
        else if triggerAI {
            return .white
        }
        else {
            return .blue
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
        ZStack {
            // background opacity
            if dateTapped {
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation(.easeInOut) {
                            dateTapped = false
                        }
                    }
            }
            
            // pop-up view
            VStack {
                Spacer()
                
                VStack {
                    Capsule()
                        .frame(width: 40, height: 5)
                        .foregroundColor(.gray)
                        .padding(.top, 8)
                    ZStack {
                        Text(title)
                            .font(.headline)
                            .padding(.top, 10)
                        
                        Button("Done") {
                            dateTapped = false
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.trailing, 10)
                        
                    }
                    
                    DatePicker("", selection: $date, in: Date()...Date.distantFuture)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                    Spacer()
                    Button("Back") {
                        withAnimation(.easeInOut) {
                            date = Date()
                            dateTapped = false
                        }
                    }
                    .padding(.bottom, 20)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 350)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(radius: 10)
                .offset(y: offsetY)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            if gesture.translation.height > 0 {
                                offsetY = gesture.translation.height
                            }
                        }
                        .onEnded { gesture in
                            if gesture.translation.height > 150 {
                                withAnimation(.spring()) {
                                    dateTapped = false
                                    offsetY = 0
                                }
                            } else {
                                withAnimation(.spring()) {
                                    offsetY = 0
                                }
                            }
                        }
                )
                .transition(.move(edge: .bottom))
            }
            .animation(.easeInOut, value: dateTapped)
        }
        .ignoresSafeArea()
        
    }
}

