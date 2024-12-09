/*
import SwiftUI
import SwiftData

class PersistenceHandler {
    static let shared = PersistenceHandler()
    let container: ModelContainer

    init() {
        // specify the model types you want to persist
        container = try! ModelContainer(for: User.self, Travel.self, Segment.self, CityFeatures.self, CityCompleterDataset.self)
        
        print(container.configurations.first?.url)
    }
}
*/


import SwiftUI
import SwiftData

class PersistenceHandler {
    static let shared = PersistenceHandler()
    let container: ModelContainer

    init() {
        do {
            let fileManager = FileManager.default
            let appSupportURL = try fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let databaseURL = appSupportURL.appendingPathComponent("db_copy.sqlite")
            
            if !fileManager.fileExists(atPath: databaseURL.path) {
                if let bundleURL = Bundle.main.url(forResource: "db_copy", withExtension: "sqlite") {
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
            container = try ModelContainer(for: User.self, Travel.self, Segment.self, CityFeatures.self, CityCompleterDataset.self, configurations: configuration)

            print("ModelContainer successfully initialized")
        } catch {
            fatalError("Error initializing ModelContainer: \(error)")
        }
    }
}


