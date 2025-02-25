import SwiftUI
import SwiftData

@MainActor
class PersistenceHandler {
    static let shared = PersistenceHandler()
    let container: ModelContainer

    init() {
        switch ConfigReader.serverServicesType {
        case .real:
            if let dbInstance = ConfigReader.dbInstance {
                do {
                    let fileManager = FileManager.default
                    let appSupportURL = try fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                    let databaseURL = appSupportURL.appendingPathComponent(dbInstance + ".sqlite")
                    
                    if !fileManager.fileExists(atPath: databaseURL.path) {
                        if let bundleURL = Bundle.main.url(forResource: dbInstance, withExtension: "sqlite") {
                            try fileManager.copyItem(at: bundleURL, to: databaseURL)
                            print("Database successfully copied in the app directory")
                        } else {
                            fatalError("Missing database file in the bundle")
                        }
                    } else {
                        print("Database already existing in the app directory")
                    }
                    
                    // configure model container
                    let configuration = ModelConfiguration(url: databaseURL)
                    self.container = try ModelContainer(for: User.self, Travel.self, Segment.self, CityFeatures.self, CityCompleterDataset.self, configurations: configuration)
                    
                    print("ModelContainer successfully initialized")
                } catch {
                    fatalError("Error initializing ModelContainer: \(error)")
                }
            } else {
                fatalError("Database instance name not found")
            }
        case .mock:
            let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
            self.container = try! ModelContainer(for: User.self, Travel.self, Segment.self, CityFeatures.self, CityCompleterDataset.self, configurations: configuration)
            
            try! addCitiesCompleterDatasetToSwiftData()
            try! addCitiesFeaturesToSwiftData()
            
            // user inserted with login
            // travels retrieved from the mock server 
        }
    }
    
    private func addCitiesCompleterDatasetToSwiftData() throws {
        let cityMilan = CityCompleterDataset(
            cityName: "Milano",
            countryName: "Italy",
            iata: "MIL",
            countryCode: "IT",
            continent: "Europe"
        )
        let cityParis = CityCompleterDataset(
            cityName: "Paris",
            countryName: "France",
            iata: "PAR",
            countryCode: "FR",
            continent: "Europe"
        )
        let cityBerlin = CityCompleterDataset(
            cityName: "Berlin",
            countryName: "Germany",
            iata: "BER",
            countryCode: "DE",
            continent: "Europe"
        )
        let cityRome = CityCompleterDataset(
            cityName: "Roma",
            countryName: "Italy",
            iata: "ROM",
            countryCode: "IT",
            continent: "Europe"
        )
        let cityLondon = CityCompleterDataset(
            cityName: "London",
            countryName: "United Kingdom",
            iata: "LON",
            countryCode: "GB",
            continent: "Europe"
        )
        let cityFirenze = CityCompleterDataset(
            cityName: "Firenze",
            countryName: "Italy",
            iata: "FLR",
            countryCode: "IT",
            continent: "Europe"
        )
        
        self.container.mainContext.insert(cityMilan)
        self.container.mainContext.insert(cityBerlin)
        self.container.mainContext.insert(cityParis)
        self.container.mainContext.insert(cityRome)
        self.container.mainContext.insert(cityLondon)
        self.container.mainContext.insert(cityFirenze)
        try self.container.mainContext.save()
    }
    
    private func addCitiesFeaturesToSwiftData() throws {
        let cityFeatureParis = CityFeatures(
            id: 55,
            iata: "PAR",
            countryCode: "FR",
            cityName: "Paris",
            countryName: "France",
            population: 11060000.0,
            capital: true,
            averageTemperature: 22.0219696969697,
            continent: "Europe",
            livingCost: 3.664,
            travelConnectivity: 10.0,
            safety: 6.2465,
            healthcare: 8.207666666666666,
            education: 7.085,
            economy: 4.2045,
            internetAccess: 9.716,
            outdoors: 4.433
        )
        let cityFeatureRome = CityFeatures(
            id: 69,
            iata: "ROM",
            countryCode: "IT",
            cityName: "Rome",
            countryName: "Italy",
            population: 2748109.0,
            capital: true,
            averageTemperature: 30.3587786259542,
            continent: "Europe",
            livingCost: 5.323,
            travelConnectivity: 6.4335,
            safety: 6.604500000000001,
            healthcare: 7.863666666666665,
            education: 4.157000000000001,
            economy: 3.3625,
            internetAccess: 4.491,
            outdoors: 6.396000000000001
        )
        let cityFeatureVienna = CityFeatures(
            id: 71,
            iata: "VIE",
            countryCode: "AT",
            cityName: "Vienna",
            countryName: "Austria",
            population: 2223236.0,
            capital: true,
            averageTemperature: 25.450381679389317,
            continent: "Europe",
            livingCost: 5.111,
            travelConnectivity: 8.0315,
            safety: 8.5965,
            healthcare: 8.198,
            education: 4.854500000000001,
            economy: 4.663,
            internetAccess: 6.173,
            outdoors: 5.294499999999999
        )
        let cityFeatureLondon = CityFeatures(
            id: 51,
            iata: "LON",
            countryCode: "GB",
            cityName: "London",
            countryName: "United Kingdom",
            population: 11262000.0,
            capital: true,
            averageTemperature: 19.955384615384613,
            continent: "Europe",
            livingCost: 3.94,
            travelConnectivity: 9.4025,
            safety: 7.243500000000001,
            healthcare: 8.017999999999999,
            education: 9.027,
            economy: 5.438,
            internetAccess: 5.8455,
            outdoors: 5.374499999999999
        )
        
        self.container.mainContext.insert(cityFeatureParis)
        self.container.mainContext.insert(cityFeatureRome)
        self.container.mainContext.insert(cityFeatureVienna)
        self.container.mainContext.insert(cityFeatureLondon)
        try self.container.mainContext.save()
    }
}
