import Combine
import SwiftData
import SwiftUI
import FirebaseAuth
class MainViewModel: ObservableObject {
    var modelContext: ModelContext
    private var cancellables = Set<AnyCancellable>()
    var users: [User] = []
    var travels: [Travel] = []
    var segments: [Segment] = []
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        do {
            users = try modelContext.fetch(FetchDescriptor<User>())
        }catch {}
    }
    
    func fetchTravels() {
        guard let firebaseUser = Auth.auth().currentUser else {
            print("error retrieving firebase user")
            return
        }
        firebaseUser.getIDToken { token, error in
            if let error = error {
                print("Failed to fetch token: \(error.localizedDescription)")
                return
            } else if let token = token {
                let firebaseToken = token
                
                let baseURL = NetworkManager.shared.getBaseURL()
                guard let url = URL(string:"\(baseURL)/travels/user") else {
                    print("Invalid URL used to retrieve travels from DB")
                    return
                }
                
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                request.setValue("Bearer \(firebaseToken)", forHTTPHeaderField: "Authorization")
                
                URLSession.shared.dataTaskPublisher(for: request)
                    .retry(2)
                    .tryMap {
                        result -> Data in
                        guard let httpResponse = result.response as? HTTPURLResponse,
                              (200...299).contains(httpResponse.statusCode) else {
                            throw URLError(.badServerResponse)
                        }
                        return result.data
                    }
                    .decode(type: [TravelDetails].self, decoder: decoder)
                    .receive(on: DispatchQueue.main)
                    .sink(receiveCompletion: {
                        completion in
                        switch completion {
                        case .finished:
                            break
                        case .failure(let error):
                            print("Error fetching travels: \(error.localizedDescription)")
                        }
                    }, receiveValue: { [weak self] travelDetailsList in
                        self?.removeExistingTravels()
                        self?.addNewTravels(travelDetailsList)
                    })
                    .store(in: &self.cancellables)
            }
            else {
                print("error retrieving user token")
                return
            }
        }
    }
    
    private func removeExistingTravels() {
        do {
            self.travels = try modelContext.fetch(FetchDescriptor<Travel>())
            self.segments = try modelContext.fetch(FetchDescriptor<Segment>())
            
            do {
                for travel in travels {
                    modelContext.delete(travel)
                }
                for segment in segments {
                    modelContext.delete(segment)
                }
                try modelContext.save()
            } catch {
                
                
                // TODO gestione
             
                
                print("Error deleting travel data from SwiftData")
            }
        }catch {
            
            print("Error getting travel data from SwiftData")
        
            
            // TODO gestire
            
            
        }
    }
    
    private func addNewTravels(_ travelDetailsList: [TravelDetails]) {
        for travelDetails in travelDetailsList {
            modelContext.insert(travelDetails.travel)
            for segment in travelDetails.segments {
                modelContext.insert(segment)
            }
        }
        do {
            try modelContext.save()
        } catch {
            
            
            // TODO gestione
            
            
            print("Error saving new travels: \(error.localizedDescription)")
        }
    }
    
    func checkUserLogged() -> Bool {
        if users.first != nil {
            return true
        }else {
            return false
        }
    }
    
    func loadCityMLDataset() {
        do {
            var fetchRequest = FetchDescriptor<CityFeatures>()
            fetchRequest.fetchLimit = 20

            // check if there are no entries in SwiftData
            let citiesDataset = try modelContext.fetch(fetchRequest)
            if !citiesDataset.isEmpty {
                // cities already loaded
                print("Cities are already loaded in SwiftData")
                return
            }
            
            // else, load them
            print("Loading cities")
        
            if let filePath = Bundle.main.path(forResource: "ds_ml_v3", ofType: "csv") {
                do {
                    let fileContents = try String(contentsOfFile: filePath, encoding: .utf8)
                    let rows = fileContents.components(separatedBy: "\n")
                    
                    var citiesDataset: [CityFeatures] = []
                    
                    // first row contains column names
                    for (index, row) in rows.enumerated() where index > 0 && !row.isEmpty {
                        let rowValues = row.components(separatedBy: ",")
                        
                        // extracr row values
                        guard rowValues.count == 17,
                            let id = Int64(rowValues[0]),
                            let population = Double(rowValues[5]),
                            let averageTemperature = Double(rowValues[7]),
                            let livingCost = Double(rowValues[9]),
                            let travelConnectivity = Double(rowValues[10]),
                            let safety = Double(rowValues[11]),
                            let healthcare = Double(rowValues[12]),
                            let education = Double(rowValues[13]),
                            let economy = Double(rowValues[14]),
                            let internetAccess = Double(rowValues[15]),
                            let outdoors = Double(rowValues[16])
                             else {
                            print("Error parsing row \(rowValues[0])")
                            continue
                        }
                        
                        let iata = rowValues[1]
                        let countryCode = rowValues[2]
                        let cityName = rowValues[3]
                        let countryName = rowValues[4]
                        let capital = Bool(Int(rowValues[6]) ?? 0)
                        let continent = rowValues[8]
                        

                        // create cityDataset object
                        let cityFeatures = CityFeatures(
                            id: id,
                            iata: iata,
                            countryCode: countryCode,
                            cityName: cityName,
                            countryName: countryName,
                            population: population,
                            capital: capital,
                            averageTemperature: averageTemperature,
                            continent: continent,
                            livingCost: livingCost,
                            travelConnectivity: travelConnectivity,
                            safety: safety,
                            healthcare: healthcare,
                            education: education,
                            economy: economy,
                            internetAccess: internetAccess,
                            outdoors: outdoors
                        )

                        citiesDataset.append(cityFeatures)
                    }
                    
                    for cityDataset in citiesDataset {
                        modelContext.insert(cityDataset)
                        print(cityDataset.cityName)
                    }
                    do {
                        try modelContext.save()
                        print("Cities loaded correctly to SwiftData")
                    } catch {
                        
                        // TODO 
                        
                        print ("Error saving cities to dataset")
                    }
                    
                } catch {
                    print("Errore while reading CSV file: \(error)")
                }
            } else {
                
                print("CSV file not found")
                
            }
            
        }catch {
            
            print("Error interacting with SwiftData")
            
            // TODO gestire
            
        }
    }
    
    func loadCityCompleterDataset() {
        do {
            // check if there are no entries in SwiftData
            var fetchRequest = FetchDescriptor<CityCompleterDataset>()
            fetchRequest.fetchLimit = 20
            let citiesCompleterDataset = try modelContext.fetch(fetchRequest)

            if !citiesCompleterDataset.isEmpty {
                // cities already loaded
                print("Cities for completer are already loaded in SwiftData")
                return
            }
            
            // else, load them
            print("Loading cities")
            
            if let filePath = Bundle.main.path(forResource: "ds_iata_v5", ofType: "csv") {
                do {
                    let fileContents = try String(contentsOfFile: filePath, encoding: .utf8)
                    let rows = fileContents.components(separatedBy: "\n")
                    
                    var citiesCompleterDataset: [CityCompleterDataset] = []
                    
                    // first row contains column names
                    for (index, row) in rows.enumerated() where index > 0 && !row.isEmpty {
                        let rowValues = row.components(separatedBy: ",")
                        
                        let locode = rowValues[0]
                        let city = rowValues[1]
                        let continent = rowValues[4]
                        let countryCode = rowValues[3]
                        let countryName = rowValues[2]

                        // create cityCompleterDataset object
                        let cityCompleterDataset = CityCompleterDataset(city: city, countryName: countryName,continent: continent, locode: locode, countryCode: countryCode)

                        citiesCompleterDataset.append(cityCompleterDataset)
                    }
                    var counter = 0
                    for cityCompleterDataset in citiesCompleterDataset {
                        modelContext.insert(cityCompleterDataset)
                        counter += 1
                        if counter.isMultiple(of: 20000) {
                            do {
                                try modelContext.save()
                            } catch {
                                print ("Error saving cities to dataset, counter: \(counter)")
                            }
                        }
                    }
                    do {
                        try modelContext.save()
                        print("Cities for completer loaded correctly to SwiftData")
                    } catch {
                        
                        // TODO
                        
                        print ("Error saving cities to dataset")
                    }
                    
                } catch {
                    print("Errore while reading CSV file: \(error)")
                }
            } else {
                
                print("CSV file not found")
                
            }
            
        }catch {
            
            print("Error interacting with SwiftData")
            
            // TODO gestire
            
        }
    }
}

extension Bool {
    init(_ int: Int) {
        if int == 1{
            self = true
        }
        self = false
    }
}
