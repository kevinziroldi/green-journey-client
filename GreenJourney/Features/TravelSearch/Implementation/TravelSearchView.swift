import SwiftUI
import SwiftData

struct TravelSearchView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @Environment(\.modelContext) private var modelContext: ModelContext
    private var serverService: ServerServiceProtocol
    private var firebaseAuthService: FirebaseAuthServiceProtocol
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @StateObject private var viewModel: TravelSearchViewModel
    @State private var departureTapped: Bool = false
    @State private var destinationTapped: Bool = false
    @State private var dateTapped: Bool = false
    @State private var dateReturnTapped: Bool = false
    @State private var triggerAI: Bool = false
    @State private var showAlertPrediction: Bool = false
    
    @State var isPresenting: Bool = false
    @Binding var navigationPath: NavigationPath
    @Binding var navigationSplitViewVisibility: NavigationSplitViewVisibility
    
    @Query var users: [User]
    
    init(modelContext: ModelContext, navigationPath: Binding<NavigationPath>, serverService: ServerServiceProtocol, firebaseAuthService: FirebaseAuthServiceProtocol, navigationSplitViewVisibility: Binding<NavigationSplitViewVisibility>) {
        _viewModel = StateObject(wrappedValue: TravelSearchViewModel(modelContext: modelContext, serverService: serverService))
        _navigationPath = navigationPath
        self.serverService = serverService
        self.firebaseAuthService = firebaseAuthService
        _navigationSplitViewVisibility = navigationSplitViewVisibility
    }
    
    var body: some View {
        if users.first != nil {
            ZStack {
                GeometryReader { proxy in
                    ZStack {
                        if triggerAI {
                            // animated gradient
                            MeshGradientView()
                                .scaleEffect(1.3) // avoids clipping
                                .ignoresSafeArea()
                        }
                        
                        Rectangle()
                            .fill(colorScheme == .dark ? AppColors.backColorDark : AppColors.backColorLight)
                            .ignoresSafeArea()
                            .mask {
                                AnimatedRectangle(size: proxy.size, cornerRadius: 48, t: CGFloat(0.0))
                                    .scaleEffect(triggerAI ? 1 : 1.2)
                                    .blur(radius: triggerAI ? 28 : 8)
                            }
                    }
                    .frame(width: proxy.size.width, height: proxy.size.height)
                }
                .ignoresSafeArea()
                ScrollView {
                    VStack {
                        ZStack {
                            // dismiss AI button
                            if triggerAI {
                                Button(action: {
                                    viewModel.arrival = CityCompleterDataset()
                                    withAnimation(.bouncy(duration: 0.5)) {
                                        triggerAI = false
                                    }
                                }) {
                                    HStack {
                                        Spacer()
                                        
                                        Image(systemName: "xmark")
                                            .resizable()
                                            .foregroundStyle(.red)
                                            .frame(width: 25, height: 25)
                                    }
                                    .padding(.horizontal, 30)
                                    .accessibilityIdentifier("dismissAIButton")
                                }
                            }
                            
                            // header
                            TravelSearchHeaderView(triggerAI: $triggerAI, serverService: serverService, firebaseAuthService: firebaseAuthService, navigationPath: $navigationPath, isPresenting: $isPresenting)
                        }
                        .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                        
                        TravelChoiceView(viewModel: viewModel, departureTapped: $departureTapped, destinationTapped: $destinationTapped, dateTapped: $dateTapped, dateReturnTapped: $dateReturnTapped, triggerAI: $triggerAI, isPresenting: $isPresenting)
                        
                        Spacer()
                        
                        Button(action: {
                            Task {
                                await viewModel.computeRoutes()
                            }
                            navigationPath.append(NavigationDestination.OutwardOptionsView(viewModel.departure.cityName, viewModel.arrival.cityName ,viewModel))
                            triggerAI = false
                            
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(AppColors.mainColor)
                                
                                HStack (spacing: 3) {
                                    Spacer()
                                    Text("Search")
                                        .foregroundStyle(.white)
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                    Spacer()
                                }
                                .padding(10)
                            }
                            .padding(.horizontal, 45)
                            .fixedSize(horizontal: false, vertical: true)
                        }
                        .disabled(viewModel.departure.iata == "" || viewModel.arrival.iata == "")
                        .frame(maxWidth: 800)
                        .padding(.top, 20)
                        .accessibilityIdentifier("searchButton")
                        
                        AIPredictionView(viewModel: viewModel, triggerAI: $triggerAI, showAlertPrediction: $showAlertPrediction, navigationSplitViewVisibility: $navigationSplitViewVisibility)
                    }
                }
                .scrollClipDisabled(true)
                .clipShape(Rectangle())
            }
            .background(colorScheme == .dark ? AppColors.backColorDark : AppColors.backColorLight)
            .sheet(isPresented: $dateTapped, onDismiss: {isPresenting = false}) {
                DatePickerView(dateTapped: $dateTapped, title: "Select Outward Date", date: $viewModel.datePicked, limitDate: Date(), isPresenting: $isPresenting)
                    .presentationDetents([.height(530)])
                    .presentationCornerRadius(15)
            }
            .sheet(isPresented: $dateReturnTapped, onDismiss: {isPresenting = false}) {
                DatePickerView(dateTapped: $dateReturnTapped, title: "Select Return Date", date: $viewModel.dateReturnPicked, limitDate: viewModel.datePicked, isPresenting: $isPresenting)
                    .presentationDetents([.height(530)])
                    .presentationCornerRadius(15)
            }
            .toolbar((triggerAI) ? .hidden : .automatic, for: .tabBar)
            .navigationBarBackButtonHidden(triggerAI)
            .onAppear() {
                viewModel.resetParameters()
                isPresenting = false
            }
            .onChange(of: viewModel.datePicked) {
                if viewModel.datePicked > viewModel.dateReturnPicked {
                    viewModel.dateReturnPicked = viewModel.datePicked.addingTimeInterval(7 * 24 * 60 * 60)
                }
            }
            .onChange(of: navigationSplitViewVisibility) {
                // disable AI if the user opens the navigation split view
                if triggerAI && navigationSplitViewVisibility != .detailOnly {
                    triggerAI = false
                }
            }
        }
    }
}

private struct TravelSearchHeaderView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @Environment(\.modelContext) var modelContext: ModelContext
    @Binding var triggerAI: Bool
    var serverService: ServerServiceProtocol
    var firebaseAuthService: FirebaseAuthServiceProtocol
    @Binding var navigationPath: NavigationPath
    @Binding var isPresenting: Bool
    
    var body: some View {
        HStack {
            Text("Search Travel")
                .font(.system(size: 32).bold())
                .padding()
                .fontWeight(.semibold)
                .accessibilityIdentifier("travelSearchViewTitle")
            
            Spacer()
            
            if horizontalSizeClass == .compact {
                // iOS
                UserPreferencesButtonView(navigationPath: $navigationPath, isPresenting: $isPresenting)
                    .disabled(triggerAI)
                    .opacity(triggerAI ? 0 : 1)
            }
        }
    }
}

private struct TravelChoiceView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    @ObservedObject var viewModel: TravelSearchViewModel
    
    @Binding var departureTapped: Bool
    @Binding var destinationTapped: Bool
    @Binding var dateTapped: Bool
    @Binding var dateReturnTapped: Bool
    @Binding var triggerAI: Bool
    @Binding var isPresenting: Bool
    
    var body: some View {
        if horizontalSizeClass == .compact {
            // iOS
            
            ZStack {
                // path drawing
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
                    // departure
                    DepartureTitleView()
                    DepartureCompleterView(viewModel: viewModel, departureTapped: $departureTapped, triggerAI: $triggerAI, isPresenting: $isPresenting)
                        .padding(EdgeInsets(top: 0, leading: 40, bottom: 20, trailing: 40))
                    
                    
                    // destination
                    DestinationTitleView()
                    DestinationCompleterView(viewModel: viewModel, destinationTapped: $destinationTapped, triggerAI: $triggerAI, isPresenting: $isPresenting)
                        .padding(EdgeInsets(top: 0, leading: 40, bottom: 20, trailing: 40))
                    
                }
            }
            
            Spacer()
            
            VStack {
                HStack {
                    Toggle("Round trip", isOn: Binding(
                        get: { !viewModel.oneWay },
                        set: { viewModel.oneWay = !$0 }))
                    .frame(width: 150)
                    .fontWeight(.semibold)
                    .toggleStyle(SwitchToggleStyle(tint: AppColors.mainColor))
                    .accessibilityIdentifier("tripTypePicker")
                    
                    Spacer()
                }
                // date pickers
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(uiColor: .systemBackground))
                        .shadow(radius: 2, x: 0, y: 2)
                    VStack (spacing: 0){
                        OutwardDatePickerView(dateTapped: $dateTapped, viewModel: viewModel, isPresenting: $isPresenting)
                        
                        Divider()
                        
                        ReturnDatePickerView(dateReturnTapped: $dateReturnTapped, viewModel: viewModel, isPresenting: $isPresenting)
                    }
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 45)
        } else {
            // iPadOS
            
            ZStack {
                // path drawing
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
                    // departure
                    VStack {
                        // tile
                        DepartureTitleView()
                        DepartureCompleterView(viewModel: viewModel, departureTapped: $departureTapped, triggerAI: $triggerAI, isPresenting: $isPresenting)
                            .padding(EdgeInsets(top: 0, leading: 40, bottom: 20, trailing: 40))
                    }
                    VStack {
                        // title
                        DestinationTitleView()
                        DestinationCompleterView(viewModel: viewModel, destinationTapped: $destinationTapped, triggerAI: $triggerAI, isPresenting: $isPresenting)
                            .padding(EdgeInsets(top: 0, leading: 40, bottom: 20, trailing: 40))
                    }
                    
                    VStack {
                        HStack {
                            Toggle("Round trip", isOn: Binding(
                                get: { !viewModel.oneWay },
                                set: { viewModel.oneWay = !$0 }))
                            .frame(width: 150)
                            .fontWeight(.semibold)
                            .toggleStyle(SwitchToggleStyle(tint: AppColors.mainColor))
                            Spacer()
                        }
                        // date pickers
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(uiColor: .systemBackground))
                                .shadow(radius: 2, x: 0, y: 2)
                            HStack {
                                OutwardDatePickerView(dateTapped: $dateTapped, viewModel: viewModel, isPresenting: $isPresenting)
                                
                                Divider()
                                
                                ReturnDatePickerView(dateReturnTapped: $dateReturnTapped, viewModel: viewModel, isPresenting: $isPresenting)
                            }
                        }
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 45)
                }
            }
            .frame(maxWidth: 800)
        }
    }
}

private struct DepartureTitleView: View {
    var body: some View {
        Text("From")
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(EdgeInsets(top: 10, leading: 40, bottom: 0, trailing: 40))
            .font(.title)
            .fontWeight(.bold)
            .accessibilityIdentifier("departureLabel")
    }
}

private struct DepartureCompleterView: View {
    @Environment(\.modelContext) private var modelContext: ModelContext
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    @ObservedObject var viewModel: TravelSearchViewModel
    @Binding var departureTapped: Bool
    @Binding var triggerAI: Bool
    @Binding var isPresenting: Bool
    
    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(AppColors.mainColor, lineWidth: 6)
                    .frame(height: 50)
                
                Button(action: {
                    if !isPresenting {
                        isPresenting = true
                        departureTapped = true
                    }
                }) {
                    Text(viewModel.departure.cityName == "" ? "Insert departure" : viewModel.departure.cityName)
                        .foregroundColor(viewModel.departure.cityName == "" ? .secondary : AppColors.mainColor)
                        .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 0))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.title2)
                        .fontWeight(viewModel.departure.cityName == "" ? .light : .semibold)
                }
                .accessibilityIdentifier("departureButton")
            }
            .background(colorScheme == .dark ? Color(red: 48/255, green: 48/255, blue: 48/255) : Color.white)
            .cornerRadius(10)
        }
        .fullScreenCover(isPresented: $departureTapped ) {
            CompleterView(modelContext: modelContext, searchText: viewModel.departure.cityName,
                          onBack: {
                departureTapped = false
                isPresenting = false
            },
                          onClick: { city in
                departureTapped = false
                isPresenting = false
                viewModel.departure = city
            },
                          departure: true)
        }
    }
}

private struct DestinationTitleView: View {
    var body: some View {
        Text("To")
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(EdgeInsets(top: 10, leading: 40, bottom: 0, trailing: 40))
            .font(.title)
            .fontWeight(.bold)
            .accessibilityIdentifier("destinationLabel")
    }
}

private struct DestinationCompleterView: View {
    @Environment(\.modelContext) private var modelContext: ModelContext
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    @ObservedObject var viewModel: TravelSearchViewModel
    @Binding var destinationTapped: Bool
    @Binding var triggerAI: Bool
    @Binding var isPresenting: Bool
    
    var body: some View {
        VStack{
            ZStack{
                RoundedRectangle(cornerRadius: 10)
                    .stroke(triggerAI ? .clear : AppColors.mainColor, lineWidth: 6)
                    .frame(height: 50)
                
                Button(action: {
                    if !triggerAI {
                        if !isPresenting {
                            isPresenting = true
                            destinationTapped = true
                        }
                    }
                }) {
                    Text(viewModel.arrival.cityName == "" ? "Insert destination" : viewModel.arrival.cityName)
                        .foregroundColor (viewModel.arrival.cityName == "" ? Color.secondary : triggerAI ? Color.white : AppColors.mainColor)
                        .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 0))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.title2)
                        .fontWeight(viewModel.arrival.cityName == "" ? .light : .semibold)
                }
                .accessibilityIdentifier("destinationButton")
            }
            .background(triggerAI ? LinearGradient(gradient: Gradient(colors: [.green, .mint, .blue]), startPoint: .bottomLeading, endPoint: .topTrailing) : LinearGradient(gradient: Gradient(colors: [colorScheme == .dark ? Color(red: 48/255, green: 48/255, blue: 48/255) : Color.white]), startPoint: .bottomLeading, endPoint: .topTrailing))
            .cornerRadius(10)
        }
        .fullScreenCover(isPresented: $destinationTapped ) {
            CompleterView(modelContext: modelContext, searchText: viewModel.arrival.cityName,
                          onBack: {
                destinationTapped = false
                isPresenting = false
            },
                          onClick: { city in
                destinationTapped = false
                isPresenting = false
                triggerAI = false
                viewModel.arrival = city
            },
                          departure: false
            )
        }
    }
}

private struct OutwardDatePickerView: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    @Binding var dateTapped: Bool
    
    @ObservedObject var viewModel: TravelSearchViewModel
    @Binding var isPresenting: Bool
    
    var body: some View {
        Button(action: {
            if !isPresenting {
                isPresenting = true
                dateTapped = true
            }
        }) {
            HStack{
                Image(systemName: "calendar")
                    .font(.title2)
                Text("Outward")
                    .font(.headline)
                    .frame(width: 80, alignment: .leading)
                Text(viewModel.datePicked.formatted(date: .numeric, time: .shortened))
                Spacer()
            }
            .padding(.horizontal, 5)
            .scaledToFit()
            .minimumScaleFactor(0.6)
            .lineLimit(1)
            .foregroundStyle(colorScheme == .dark ? .white : .black)
        }
        .padding(.vertical, 10)
        .accessibilityIdentifier("outwardDateButton")
        
        .frame(maxWidth: 310)
    }
}

private struct ReturnDatePickerView: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    @Binding var dateReturnTapped: Bool
    @ObservedObject var viewModel: TravelSearchViewModel
    @Binding var isPresenting: Bool
    
    var body: some View {
        
        Button(action:  {
            if !isPresenting {
                isPresenting = true
                dateReturnTapped = true
            }
        }) {
            HStack {
                Image(systemName: "calendar")
                    .font(.title2)
                Text("Return")
                    .font(.headline)
                    .frame(width: 80, alignment: .leading)
                
                Text(viewModel.dateReturnPicked.formatted(date: .numeric, time: .shortened))
                Spacer()
                
            }
            .padding(.horizontal, 5)
            .scaledToFit()
            .minimumScaleFactor(0.6)
            .lineLimit(1)
            .foregroundStyle(viewModel.oneWay ? Color.secondary : colorScheme == .dark ? Color.white : Color.black)
        }
        .padding(.vertical, 10)
        .disabled(viewModel.oneWay)
        .accessibilityIdentifier("returnDateButton")
        
        .frame(maxWidth: 310)
    }
}

private struct DatePickerView: View {
    @Binding var dateTapped: Bool
    var title: String
    @Binding var date: Date
    let limitDate: Date
    @Binding var isPresenting: Bool
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
                        isPresenting = false
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
            DatePicker("", selection: $date, in: limitDate...Date.distantFuture)
                .datePickerStyle(.graphical)
                .labelsHidden()
                .accessibilityIdentifier("datePickerElement")
                .padding(.top, 20)
            Spacer()
        }
        .ignoresSafeArea()
        .frame(maxWidth: .infinity)
    }
}

private struct AIPredictionView: View {
    @Environment(\.modelContext) private var modelContext: ModelContext
    
    @ObservedObject var viewModel: TravelSearchViewModel
    @Binding var triggerAI: Bool
    @Binding var showAlertPrediction: Bool
    
    @Binding var navigationSplitViewVisibility: NavigationSplitViewVisibility
    
    var body: some View {
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
                                self.navigationSplitViewVisibility = .detailOnly
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
                
                //button for see another prediction
                Button(action: {
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
                            .stroke(.linearGradient(Gradient(colors: [.green, .blue]), startPoint: .bottomLeading, endPoint: .topTrailing), lineWidth: 3)
                            .fill(.linearGradient(Gradient(colors: [.green.opacity(0.2), .mint.opacity(0.2)]), startPoint: .bottomLeading, endPoint: .topTrailing))
                        HStack {
                            Text("Generate a new prediction")
                                .foregroundStyle(.gray)
                            Spacer()
                            ZStack {
                                Image(systemName: "arrow.trianglehead.2.clockwise")
                                    .font(.largeTitle)
                                    .fontWeight(.light)
                                    .scaleEffect(1.3)
                                    .foregroundStyle(.linearGradient(Gradient(colors: [.blue, .green]), startPoint: .bottomLeading, endPoint: .topTrailing))
                                Image(systemName: "apple.intelligence")
                                    .font(.title)
                                    .foregroundStyle(.linearGradient(Gradient(colors: [.blue, .green]), startPoint: .bottomLeading, endPoint: .topTrailing))
                            }
                        }
                        .padding(5)
                        .padding(.horizontal, 5)
                    }
                    .frame(height: 60)
                }
                .accessibilityIdentifier("newGenerationButton")
                
            }
        }
        .padding(.horizontal, 45)
        .frame(maxWidth: 800)
        .padding(.top, 20)
        .padding(.bottom, 10)
    }
}
