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
        
        print("DELETE TRAVELS")
        
        do {
            self.travels = try modelContext.fetch(FetchDescriptor<Travel>())
            self.segments = try modelContext.fetch(FetchDescriptor<Segment>())
        }catch {}
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
    }
    
    private func addNewTravels(_ travelDetailsList: [TravelDetails]) {
        
        print("ADD TRAVELS")
        
        for travelDetails in travelDetailsList {
            modelContext.insert(travelDetails.travel)
            print(travelDetails.travel.travelID)
            for segment in travelDetails.segments {
                modelContext.insert(segment)
                print(segment.departure + " " + segment.destination)
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
            print("User IS logged")
            return true
        }else {
            print("User IS NOT logged")
            return false
        }
    }
}
