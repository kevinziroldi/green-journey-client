import SwiftUI
import SwiftData
import MapKit

struct FromToView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var viewModel: FromToViewModel
    @State private var departureTapped: Bool = false
    @State private var destinationTapped: Bool = false
    @State private var dateTapped = false
    @State private var dateReturnTapped = false
    @State private var triggerAI: Bool = false
    
    @Binding var navigationPath: NavigationPath
    
    @Query var users: [User]
    
    /*init(modelContext: ModelContext, navigationPath: Binding<NavigationPath>) {
        _viewModel = StateObject(wrappedValue: FromToViewModel(modelContext: modelContext))
        _navigationPath = navigationPath
    }*/
    
    var body: some View {
        if users.first != nil {
            //NavigationStack {
                ZStack {
                    VStack {
                        HStack {
                            Text("Next journey")
                                .font(.title)
                                .padding()
                            
                            Spacer()
                            
                            Button(action: {
                                navigationPath.append(NavigationDestination.UserPreferencesView)
                                print(navigationPath)
                            }) {
                                Image(systemName: "person")
                                    .font(.title)
                            }
                        }
                        
                        Picker("", selection: $viewModel.oneWay) {
                            Text("One way").tag(true)
                            Text("Round trip").tag(false)
                        }
                        .pickerStyle(.segmented)
                        .padding()
                        .frame(maxWidth: 190) // Set a max width to control the size
                        
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
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 80, trailing: 300))
                            VStack {
                                VStack {
                                    Text("From")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(EdgeInsets(top: 10, leading: 50, bottom: 0, trailing: 50))
                                        .frame(alignment: .top)
                                        .font(.title)
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(colorScheme == .dark ? Color.white.opacity(0.6) : Color.black.opacity(0.6), lineWidth: 3)
                                            .frame(height: 50)
                                        
                                        Button(action: {
                                            departureTapped = true
                                        }) {
                                            Text(viewModel.departure == "" ? "Insert departure" : viewModel.departure)
                                                .foregroundColor(viewModel.departure == "" ? .secondary : .blue)
                                                .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 0))
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .font(.title2)
                                                .fontWeight(viewModel.departure == "" ? .light : .semibold)
                                        }
                                    }
                                    .background(colorScheme == .dark ? Color(red: 48/255, green: 48/255, blue: 48/255) : Color.white)
                                    .cornerRadius(10)
                                    .shadow(radius: 5)
                                    .padding(EdgeInsets(top: 0, leading: 50, bottom: 20, trailing: 50))
                                    
                                    
                                }
                                .fullScreenCover(isPresented: $departureTapped ) {
                                    TextFieldSearchModalView(
                                        testo: $viewModel.departure,
                                        viewModel: viewModel,
                                        onBack: {
                                            departureTapped = false
                                        }) { selected in
                                            viewModel.departure = selected
                                            departureTapped = false
                                        }
                                }
                                
                                VStack{
                                    Text("To")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(EdgeInsets(top: 10, leading: 50, bottom: 0, trailing: 50))
                                        .frame(alignment: .top)
                                        .font(.title)
                                    ZStack{
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(colorScheme == .dark ? Color.white.opacity(0.6) : Color.black.opacity(0.6), lineWidth: 3)
                                            .frame(height: 50)
                                        
                                        Button(action: {
                                            destinationTapped = true
                                        }) {
                                            Text(viewModel.destination == "" ? "Insert destination" : viewModel.destination)
                                                .foregroundColor (getColorDest())
                                                .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 0))
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .font(.title2)
                                                .fontWeight(viewModel.destination == "" ? .light : .semibold)
                                        }
                                    }
                                    .background(triggerAI ? LinearGradient(gradient: Gradient(colors: [.green, .cyan, .blue, .cyan, .green]), startPoint: .bottomLeading, endPoint: .topTrailing) : LinearGradient(gradient: Gradient(colors: [colorScheme == .dark ? Color(red: 48/255, green: 48/255, blue: 48/255) : Color.white]), startPoint: .bottomLeading, endPoint: .topTrailing))
                                    .cornerRadius(10)
                                    .shadow(radius: 5)
                                    .padding(EdgeInsets(top: 0, leading: 50, bottom: 20, trailing: 50))
                                }
                                .fullScreenCover(isPresented: $destinationTapped ) {
                                    TextFieldSearchModalView(
                                        testo: $viewModel.destination,
                                        viewModel: viewModel,
                                        onBack: {
                                            destinationTapped = false
                                        }
                                    ) { selected in
                                        viewModel.destination = selected
                                        destinationTapped = false
                                        triggerAI = false
                                    }
                                }
                            }
                        }
                        
                        HStack {
                            Spacer()
                            VStack {
                                Button("Outward date") {
                                    dateTapped = true
                                    
                                }
                                .buttonStyle(.bordered)
                                Text(viewModel.datePicked.formatted(date: .numeric, time: .shortened))
                                    .font(.subheadline)
                                
                            }
                            Spacer()
                            VStack {
                                Button("Return date") {
                                    dateReturnTapped = true
                                }
                                .buttonStyle(.bordered)
                                
                                Text(!viewModel.oneWay ? viewModel.dateReturnPicked.formatted(date: .numeric, time: .shortened) : " ")
                                    .font(.subheadline)
                            }
                            .disabled(viewModel.oneWay)
                            Spacer()
                        }
                        .padding()
                        
                        Spacer()
                        Button(action: {
                            viewModel.insertCoordinates()   // compute coordinates for departure and destination
                            viewModel.computeRoutes()
                            
                            // Naviga manualmente alla destinazione
                            navigationPath.append(NavigationDestination.TravelOptionsView)
                        }) {
                            Text("Search")
                                .font(.title3)
                                .foregroundStyle(.white)
                        }
                        .buttonStyle(.borderedProminent)
                        
                        
                        Spacer()
                        
                        Button (action: {
                            viewModel.destination = " "
                            withAnimation(.snappy(duration: 4)) {
                                //TODO change
                                //viewModel.destination = "Milan"
                                viewModel.getRecommendation()
                                triggerAI = true
                            }
                        }){
                            Text("Don't know where to go? Ask AI.")
                                .foregroundColor(.gray)
                                .padding()
                            Spacer()
                            Image(systemName: "apple.intelligence")
                                .font(.title)
                                .frame(width: 50, height: 50)
                            //.background(.white)
                                .clipShape(Circle())
                                .padding(EdgeInsets(top: 0, leading: 5, bottom: 5, trailing: 5))
                                .foregroundStyle(.linearGradient(Gradient(colors: [.blue, .pink]), startPoint: .bottomLeading, endPoint: .topTrailing))
                            
                        }
                        .cornerRadius(10)
                        .border(.gray, width: 1)
                        .padding()
                        
                    }
                    .padding()
                    .blur(radius: (dateTapped || dateReturnTapped) ? 2 : 0) // Sfoca tutto il contenuto sottostante
                    
                    // Modale per il DatePicker "Outward date"
                    if dateTapped {
                        DatePickerModalView(
                            title: "Select Outward Date",
                            date: $viewModel.datePicked,
                            onConfirm: {
                                dateTapped = false
                            },
                            onReset: {
                                viewModel.datePicked = Date() // Imposta la data predefinita
                                dateTapped = false
                            }
                        )
                    }
                    
                    // Modale per il DatePicker "Return date"
                    if dateReturnTapped && !viewModel.oneWay {
                        DatePickerModalView(
                            title: "Select Return Date",
                            date: $viewModel.dateReturnPicked,
                            onConfirm: {
                                dateReturnTapped = false
                            },
                            onReset: {
                                viewModel.dateReturnPicked = Date() // Imposta la data predefinita
                                dateReturnTapped = false
                            }
                        )
                    }
                }
                .animation(.default, value: dateTapped || dateReturnTapped)
            //}
        }
        else {
            LoginView(modelContext: modelContext)
                .transition(.opacity.animation(.easeInOut(duration: 0.2)))
        }
    }
    
    private func getColorDest () -> Color {
        if viewModel.destination == "" {
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

struct DatePickerModalView: View {
    var title: String
    @Binding var date: Date
    @Environment(\.colorScheme) var colorScheme
    var onConfirm: () -> Void
    var onReset: () -> Void
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                        .stroke(colorScheme == .dark ? Color.white.opacity(0.4) : Color.black.opacity(0.4), lineWidth: 2)
            
            VStack(spacing: 20) {
                Text(title)
                    .font(.headline)
                
                DatePicker("", selection: $date, in: Date()...Date.distantFuture)
                    .datePickerStyle(.graphical)
                    .labelsHidden()
                
                HStack {
                    Button("Reset") {
                        onReset()
                    }
                    .buttonStyle(.bordered)
                    
                    Spacer()
                    
                    Button("Confirm") {
                        onConfirm()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.horizontal)
            }
            .padding()
            .cornerRadius(12)
            
        }
        .background(colorScheme == .dark ? Color.black : Color.white)
        .shadow(radius: 10)
        .frame(width: 330, height: 500)
        .cornerRadius(12)
    }
}


struct TextFieldSearchModalView: View {
    @Binding var testo: String
    @ObservedObject var viewModel: FromToViewModel
    @Environment(\.colorScheme) var colorScheme
    @FocusState var textfieldOpen: Bool
    var onBack: () -> Void
    var onClick: (String) -> Void
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(colorScheme == .dark ? Color.white.opacity(0.6) : Color.black.opacity(0.6), lineWidth: 2)
                    .frame(height: 50)
                
                HStack {
                    Button(action: {
                        onBack()
                    }) {
                        Image(systemName: "chevron.backward")
                            .font(.title2)
                            .foregroundStyle(.gray)
                    }
                    TextField("insert", text: $testo)
                        .background(colorScheme == .dark ? Color(red: 48/255, green: 48/255, blue: 48/255) : Color.white)
                        .font(.title2)
                        .focused($textfieldOpen)
                        .onSubmit {
                            onClick(testo)
                        }
                }
                .padding()
            }
            .padding(EdgeInsets(top: 80, leading: 10, bottom: 0, trailing: 10))
            
                
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
                    onClick(suggestion.title)
                }
            }
            .listStyle(PlainListStyle())
            .cornerRadius(10)
            .padding([.leading, .trailing], 16)
            
            HStack {
                Button("Back") {
                    onBack()
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal)
        }
        .ignoresSafeArea()
        .padding()
        .background(colorScheme == .dark ? Color.black : Color.white)
        .cornerRadius(12)
        .shadow(radius: 10)
        .onAppear(){
            textfieldOpen = true
        }
    }
}
