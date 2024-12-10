import SwiftUI
import SwiftData
import MapKit

struct TravelSearchView: View {
    @Environment(\.modelContext) private var modelContext: ModelContext
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @EnvironmentObject var viewModel: TravelSearchViewModel
    @State private var departureTapped: Bool = false
    @State private var destinationTapped: Bool = false
    @State private var dateTapped: Bool = false
    @State private var dateReturnTapped: Bool = false
    @State private var triggerAI: Bool = false
    
    @Binding var navigationPath: NavigationPath
    
    @Query var users: [User]
    
    var body: some View {
        if users.first != nil {
            ZStack {
                VStack {
                    HStack {
                        Text("Next journey")
                            .font(.title)
                            .padding()
                        
                        Spacer()
                        
                        NavigationLink(destination: UserPreferencesView(navigationPath: $navigationPath)) {
                            Image(systemName: "person")
                                .font(.title)
                        }
                    }
                    .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                    
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
                                        Text(viewModel.departure.cityName == "" ? "Insert departure" : viewModel.departure.cityName)
                                            .foregroundColor(viewModel.departure.cityName == "" ? .secondary : .blue)
                                            .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 0))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .font(.title2)
                                            .fontWeight(viewModel.departure.cityName == "" ? .light : .semibold)
                                    }
                                }
                                .background(colorScheme == .dark ? Color(red: 48/255, green: 48/255, blue: 48/255) : Color.white)
                                .cornerRadius(10)
                                .shadow(radius: 5)
                                .padding(EdgeInsets(top: 0, leading: 50, bottom: 20, trailing: 50))
                                
                                
                            }
                            .fullScreenCover(isPresented: $departureTapped ) {
                                CompleterView(searchText: viewModel.departure.cityName,
                                onBack: {
                                    departureTapped = false
                                },
                                onClick: { city in
                                    departureTapped = false
                                    viewModel.departure = city
                                })
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
                                        Text(viewModel.arrival.cityName == "" ? "Insert destination" : viewModel.arrival.cityName)
                                            .foregroundColor (getColorDest())
                                            .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 0))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .font(.title2)
                                            .fontWeight(viewModel.arrival.cityName == "" ? .light : .semibold)
                                    }
                                }
                                .background(triggerAI ? LinearGradient(gradient: Gradient(colors: [.green, .cyan, .blue, .cyan, .green]), startPoint: .bottomLeading, endPoint: .topTrailing) : LinearGradient(gradient: Gradient(colors: [colorScheme == .dark ? Color(red: 48/255, green: 48/255, blue: 48/255) : Color.white]), startPoint: .bottomLeading, endPoint: .topTrailing))
                                .cornerRadius(10)
                                .shadow(radius: 5)
                                .padding(EdgeInsets(top: 0, leading: 50, bottom: 20, trailing: 50))
                            }
                            .fullScreenCover(isPresented: $destinationTapped ) {
                                CompleterView(searchText: viewModel.arrival.cityName,
                                              onBack: {
                                    destinationTapped = false
                                              },
                                              onClick: { city in
                                    destinationTapped = false
                                    //TODO
                                    viewModel.arrival = city
                                }
                                )
                            }
                        }
                    }
                    .padding()
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
                        viewModel.computeRoutes()
                        navigationPath.append(NavigationDestination.OutwardOptionsView)
                        triggerAI = false
                        }) {
                        Text("Search")
                            .font(.title3)
                            .foregroundStyle(.white)
                    }
                    .buttonStyle(.borderedProminent)
                    
                    
                    Spacer()
                    
                    DestinationPredictionView(
                        modelContext: modelContext,
                        confirm: { predictedCity in
                            viewModel.arrival = predictedCity
                            self.triggerAI = true
                        })
                    
                }
                .blur(radius: (dateTapped || dateReturnTapped) ? 2 : 0) // Sfoca tutto il contenuto sottostante
                .allowsHitTesting(!(dateTapped || dateReturnTapped))
                
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
            //.animation(.default, value: dateTapped || dateReturnTapped) // TODO 
            .onAppear() {
                print("TravelSearchView onAppear")
            }
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
