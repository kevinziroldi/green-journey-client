import Foundation
import SwiftData
import Combine

class RankingViewModel: ObservableObject {
    var modelContext: ModelContext
    private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
    var users: [User] = []


    @Published var shortDistanceRanking: [RankingElement] = []
    @Published var longDistanceRanking: [RankingElement] = []
    var leaderboardSelected: Bool = true
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func fecthRanking() {
        do {
            users = try modelContext.fetch(FetchDescriptor<User>())
            
            guard let userID = users.first?.userID else { return }
            
            let baseURL = NetworkHandler.shared.getBaseURL()
            guard let url = URL(string:"\(baseURL)/ranking?id=\(userID)") else { print("ERROR"); return }
            let decoder = JSONDecoder()
            
            URLSession.shared.dataTaskPublisher(for: url)
                .tryMap {
                    result -> Data in
                    guard let httpResponse = result.response as? HTTPURLResponse,
                          (200...299).contains(httpResponse.statusCode) else {
                        throw URLError(.badServerResponse)
                    }
                    //print(String(data: result.data, encoding: .utf8) ?? "No data")
                    return result.data
                }
                .decode(type: RankingResponse.self, decoder: decoder)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: {
                    completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        print("Error fetching rankings: \(error.localizedDescription)")
                    }
                }, receiveValue: { [weak self] response in
                    guard let strongSelf = self else { return }
                    strongSelf.shortDistanceRanking = response.shortDistanceRanking
                    strongSelf.longDistanceRanking = response.longDistanceRanking
                })
                .store(in: &cancellables)
            
        }catch {
            print("Error retrieving user from SwiftData")
        }
    }
    
    func computeTotalDuration (duration: Int) -> String {
        var hours: Int = 0
        var minutes: Int = 0
        var days: Int = 0
        var months: Int = 0
        var years: Int = 0
        
        hours = duration / (3600 * 1000000000)       // 1 hour = 3600 secsecondsondi
        let remainingSeconds = (duration / 1000000000) % (3600)
        minutes = remainingSeconds / 60
        while (minutes >= 60) {
            hours += 1
            minutes -= 60
        }
        while (hours >= 24) {
            days += 1
            hours -= 24
        }
        while (days >= 30) {
            months += 1
            days -= 30
        }
        while (months >= 12) {
            years += 1
            months -= 12
        }
        if years > 0 {
            return "\(years) y, \(months) m, \(days) d, \(hours) h, \(minutes) min"
        }
        if years == 0 && months > 0 {
            return "\(months) m, \(days) d, \(hours) h, \(minutes) min"
        }
        if months == 0 && days > 0 {
            return "\(days) d, \(hours) h, \(minutes) min"
        }
        return "\(hours) h, \(minutes) min"
        
    }
}

struct RankingElement: Decodable {
    var userID: Int
    var firstName: String
    var lastName: String
    var totalDistance: Float64
    var score: Float64
    var totalDuration: Int
    var totalCo2Emitted: Float64
    var totalCo2Compensated: Float64
    var badges: [Badge]
    
    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case firstName = "first_name"
        case lastName = "last_name"
        case totalDistance = "total_distance"
        case score = "score"
        case totalDuration = "total_duration"
        case totalCo2Emitted = "total_co_2_emitted"
        case totalCo2Compensated = "total_co_2_compensated"
        case badges = "badges"
    }
}


struct RankingResponse: Decodable {
    var shortDistanceRanking: [RankingElement]
    var longDistanceRanking: [RankingElement]
    
    enum CodingKeys: String, CodingKey {
        case shortDistanceRanking = "short_distance_ranking"
        case longDistanceRanking = "long_distance_ranking"
    }
}
