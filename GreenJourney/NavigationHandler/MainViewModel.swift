import Combine
import SwiftData
import SwiftUI

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
        var userID = -1
        if checkUserLogged() {
            userID = users.first?.userID ?? -1
        }
        
        let baseURL = NetworkManager.shared.getBaseURL()
        guard let url = URL(string:"\(baseURL)/travels/user?id=\(userID)") else {
            print("Invalid URL used to retrieve travels from DB")
            return
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        URLSession.shared.dataTaskPublisher(for: url)
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
            .store(in: &cancellables)
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
            
            if let filePath = Bundle.main.path(forResource: "city_ds", ofType: "csv") {
                do {
                    let fileContents = try String(contentsOfFile: filePath, encoding: .utf8)
                    let rows = fileContents.components(separatedBy: "\n")
                    
                    var citiesDataset: [CityFeatures] = []
                    
                    // first row contains column names
                    for (index, row) in rows.enumerated() where index > 0 && !row.isEmpty {
                        let rowValues = row.components(separatedBy: ",")
                        
                        // extracr row values
                        guard rowValues.count == 15,
                            let population = Double(rowValues[2]),
                            let averageTemperature = Double(rowValues[4]),
                            let livingCost = Double(rowValues[6]),
                            let travelConnectivity = Double(rowValues[7]),
                            let safety = Double(rowValues[8]),
                            let healthcare = Double(rowValues[9]),
                            let education = Double(rowValues[10]),
                            let economy = Double(rowValues[11]),
                            let internetAccess = Double(rowValues[12]),
                            let outdoors = Double(rowValues[13]),
                            let id = Int64(rowValues[14]) else {
                            print("Error parsing row \(rowValues[0])")
                            continue
                        }
                        let city = rowValues[0]
                        let country = rowValues[1]
                        let capital = Bool(Int(rowValues[3]) ?? 0)
                        let continent = rowValues[5]

                        // create cityDataset object
                        let cityDataset = CityFeatures(
                            id: id,
                            city: city,
                            country: country,
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

                        citiesDataset.append(cityDataset)
                    }
                    
                    for cityDataset in citiesDataset {
                        modelContext.insert(cityDataset)
                        print(cityDataset.city)
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
            
            if let filePath = Bundle.main.path(forResource: "ds_locode_reduced", ofType: "csv") {
                do {
                    let fileContents = try String(contentsOfFile: filePath, encoding: .utf8)
                    let rows = fileContents.components(separatedBy: "\n")
                    
                    var citiesCompleterDataset: [CityCompleterDataset] = []
                    
                    // first row contains column names
                    for (index, row) in rows.enumerated() where index > 0 && !row.isEmpty {
                        let rowValues = row.components(separatedBy: ",")
                        
                        let locode = rowValues[0]
                        let city = rowValues[1]
                        let continent = rowValues[6]
                        let countryCode = rowValues[3]
                        let countryName = rowValues[2]

                        // create cityCompleterDataset object
                        let cityCompleterDataset = CityCompleterDataset(city: city, countryName: countryName,continent: continent, locode: locode, countryCode: countryCode)

                        citiesCompleterDataset.append(cityCompleterDataset)
                    }
                    
                    for cityCompleterDataset in citiesCompleterDataset {
                        modelContext.insert(cityCompleterDataset)
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
