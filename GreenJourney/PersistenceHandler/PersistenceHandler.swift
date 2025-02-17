import SwiftUI
import SwiftData

@MainActor
class PersistenceHandler {
    static let shared = PersistenceHandler()
    let container: ModelContainer

    init() {
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
                container = try ModelContainer(for: User.self, Travel.self, Segment.self, CityFeatures.self, CityCompleterDataset.self, configurations: configuration)
                
                print("ModelContainer successfully initialized")
            } catch {
                fatalError("Error initializing ModelContainer: \(error)")
            }
        } else {
            fatalError("Database instance name not found")
        }
    }
}
