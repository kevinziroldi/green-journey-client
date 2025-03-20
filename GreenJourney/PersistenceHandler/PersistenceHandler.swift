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
                    self.container = try ModelContainer(for: User.self, Travel.self, Segment.self, CityFeatures.self, CityCompleterDataset.self, Review.self, configurations: configuration)
                    
                    print("ModelContainer successfully initialized")
                } catch {
                    fatalError("Error initializing ModelContainer: \(error)")
                }
            } else {
                fatalError("Database instance name not found")
            }
        case .mock:
            let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
            self.container = try! ModelContainer(for: User.self, Travel.self, Segment.self, CityFeatures.self, CityCompleterDataset.self, Review.self, configurations: configuration)
            
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

/*
import SwiftUI
import SwiftData

@MainActor
class PersistenceHandler {
    static let shared = PersistenceHandler()
    let container: ModelContainer
    
    let appSupportURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
    
    let dbURL: URL
    
    init() {
        
        do{
            dbURL = appSupportURL.appendingPathComponent("GreenJourneyDB.sqlite")
            
            print("Percorso del database: \(dbURL.path)")
            
            
            let configuration = ModelConfiguration(url: dbURL)
            
            // configure model container
            self.container = try ModelContainer(for: User.self, Travel.self, Segment.self, CityFeatures.self, CityCompleterDataset.self, Review.self, configurations: configuration)
            
            cleanDB(modelContext: container.mainContext)
            
            importCitiesCompleter(modelContext: container.mainContext)
            importCitiesFeatures(modelContext: container.mainContext)
            
            if let appSupportURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
                print("Application Support Directory: \(appSupportURL.path)")
            }
        }catch {
            fatalError()
        }
    }
    
    func cleanDB(modelContext: ModelContext) {
        let cityCompleter = try! modelContext.fetch(FetchDescriptor<CityCompleterDataset>())
        for city in cityCompleter {
            modelContext.delete(city)
        }
        
        let cityFeatures = try! modelContext.fetch(FetchDescriptor<CityFeatures>())
        for city in cityFeatures {
            modelContext.delete(city)
        }
        
        try! modelContext.save()
    }
    
    func importCitiesCompleter(modelContext: ModelContext) {
        guard let fileURL = Bundle.main.url(forResource: "ds_iata_v5", withExtension: "csv") else {
            print("CSV file non trovato nel bundle")
            return
        }
        
        do {
            let csvContent = try String(contentsOf: fileURL, encoding: .utf8)
            let lines = csvContent.components(separatedBy: "\n")
            let dataLines = lines.dropFirst()
            
            for line in dataLines {
                if line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { continue }
                let columns = line.components(separatedBy: ",")
                
                if columns.count >= 5 {
                    let iata = columns[0].trimmingCharacters(in: .whitespacesAndNewlines)
                    let cityName = columns[1].trimmingCharacters(in: .whitespacesAndNewlines)
                    let countryName = columns[2].trimmingCharacters(in: .whitespacesAndNewlines)
                    let countryCode = columns[3].trimmingCharacters(in: .whitespacesAndNewlines)
                    let continent = columns[4].trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    let datasetEntry = CityCompleterDataset(cityName: cityName, countryName: countryName, iata: iata, countryCode: countryCode, continent: continent)
                    
                    modelContext.insert(datasetEntry)
                } else {
                    print("Riga non valida: \(line)")
                }
            }
            
            try modelContext.save()
            print("Importazione CSV completata con successo.")
            
        } catch {
            print("Errore durante l'importazione del CSV: \(error)")
        }
    }
    
    func importCitiesFeatures(modelContext: ModelContext) {
        // Ottieni l'URL del file CSV dal bundle
        guard let fileURL = Bundle.main.url(forResource: "ds_ml_v3", withExtension: "csv") else {
            print("CSV file non trovato nel bundle")
            return
        }
        
        do {
            // Leggi il contenuto del file come stringa
            let csvContent = try String(contentsOf: fileURL, encoding: .utf8)
            // Suddividi il contenuto in righe
            let lines = csvContent.components(separatedBy: "\n")
            
            // Se il file contiene l'header, salta la prima riga
            let dataLines = lines.dropFirst()
            
            for line in dataLines {
                // Salta le righe vuote
                if line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { continue }
                
                // Suddividi la riga in componenti, assumendo che il separatore sia la virgola
                let columns = line.components(separatedBy: ",")
                // Verifica che ci siano almeno 17 colonne
                if columns.count >= 17 {
                    // Parsing e trimming dei valori
                    guard let id = Int64(columns[0].trimmingCharacters(in: .whitespacesAndNewlines)),
                          let population = Double(columns[5].trimmingCharacters(in: .whitespacesAndNewlines)),
                          let avgTemp = Double(columns[7].trimmingCharacters(in: .whitespacesAndNewlines)),
                          let livingCost = Double(columns[9].trimmingCharacters(in: .whitespacesAndNewlines)),
                          let travelConnectivity = Double(columns[10].trimmingCharacters(in: .whitespacesAndNewlines)),
                          let safety = Double(columns[11].trimmingCharacters(in: .whitespacesAndNewlines)),
                          let healthcare = Double(columns[12].trimmingCharacters(in: .whitespacesAndNewlines)),
                          let education = Double(columns[13].trimmingCharacters(in: .whitespacesAndNewlines)),
                          let economy = Double(columns[14].trimmingCharacters(in: .whitespacesAndNewlines)),
                          let internetAccess = Double(columns[15].trimmingCharacters(in: .whitespacesAndNewlines)),
                          let outdoors = Double(columns[16].trimmingCharacters(in: .whitespacesAndNewlines))
                    else {
                        print("Errore nel parsing dei valori numerici per la riga: \(line)")
                        continue
                    }
                    
                    // Converte il campo 'capital': "1" per true, altrimenti false
                    let capitalValue = columns[6].trimmingCharacters(in: .whitespacesAndNewlines)
                    let capital = (capitalValue == "1")
                    
                    // Estrai le stringhe per gli altri campi
                    let iata = columns[1].trimmingCharacters(in: .whitespacesAndNewlines)
                    let countryCode = columns[2].trimmingCharacters(in: .whitespacesAndNewlines)
                    let cityName = columns[3].trimmingCharacters(in: .whitespacesAndNewlines)
                    let countryName = columns[4].trimmingCharacters(in: .whitespacesAndNewlines)
                    let continent = columns[8].trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    // Crea l'oggetto CityFeatures
                    let cityFeature = CityFeatures(
                        id: id,
                        iata: iata,
                        countryCode: countryCode,
                        cityName: cityName,
                        countryName: countryName,
                        population: population,
                        capital: capital,
                        averageTemperature: avgTemp,
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
                    
                    // Inserisci l'oggetto nel ModelContext
                    modelContext.insert(cityFeature)
                } else {
                    print("Riga non valida (numero di colonne insufficiente): \(line)")
                }
            }
            
            // Salva tutte le modifiche nel ModelContext
            try modelContext.save()
            print("Importazione CSV completata con successo.")
            
        } catch {
            print("Errore durante l'importazione del CSV: \(error)")
        }
    }
}
*/
