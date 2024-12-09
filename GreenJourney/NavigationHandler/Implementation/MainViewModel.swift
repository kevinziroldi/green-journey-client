import Combine
import FirebaseAuth
import SwiftData
import SwiftUI

class MainViewModel: ObservableObject {
    var modelContext: ModelContext
    private var cancellables = Set<AnyCancellable>()
    
    private var isDataLoaded: Bool = false
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func loadData() {
        if !isDataLoaded {
            // refresh travels data
            fetchTravels()
            // set data loaded
            isDataLoaded = true
        }
    }
    
    func fetchTravels() {
        guard let firebaseUser = Auth.auth().currentUser else {
            print("error retrieving firebase user")
            return
        }
        firebaseUser.getIDToken { [weak self] token, error in
            guard let strongSelf = self else { return }
            if let error = error {
                print("Failed to fetch token: \(error.localizedDescription)")
                return
            } else if let firebaseToken = token {
                let baseURL = NetworkHandler.shared.getBaseURL()
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
                        guard let strongSelf = self else { return }
                        strongSelf.removeExistingTravels()
                        strongSelf.addNewTravels(travelDetailsList)
                    })
                    .store(in: &strongSelf.cancellables)
            }
            else {
                print("error retrieving user token")
                return
            }
        }
    }
    
    private func removeExistingTravels() {
        do {
            let travels = try modelContext.fetch(FetchDescriptor<Travel>())
            let segments = try modelContext.fetch(FetchDescriptor<Segment>())
            
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
        do {
            let users = try modelContext.fetch(FetchDescriptor<User>())
            if users.first != nil {
                return true
            }
        }catch {
            print("Error interacting with SwiftData")
        }
        
        return false
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
