import Foundation
import SwiftData
import Combine

class RankingViewModel: ObservableObject {
    var modelContext: ModelContext
    private var serverService: ServerServiceProtocol
    
    var users: [User] = []
    
    @Published var shortDistanceRanking: [RankingElement] = []
    @Published var longDistanceRanking: [RankingElement] = []
    @Published var leaderboardSelected: Bool = true
    
    @Published var errorMessage: String? = nil
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        
        
        // TODO mock or not
        self.serverService = ServerService()
    }
    
    func fecthRanking() {
        Task { @MainActor in
            errorMessage = nil
            
            // get user id
            do {
                users = try modelContext.fetch(FetchDescriptor<User>())
            }catch {
                print("Error getting user from SwiftData")
                errorMessage = "An error occurred retrieving rankings from server"
                return
            }
            guard let userID = users.first?.userID else {
                print("No user found")
                errorMessage = "An error occurred retrieving rankings from server"
                return
            }
            
            // get ranking from server
            do {
                let rankingResponse = try await serverService.getRanking(userID: userID)
                self.shortDistanceRanking = rankingResponse.shortDistanceRanking
                self.longDistanceRanking = rankingResponse.longDistanceRanking
            }catch {
                print("Error fetching rankings: \(error.localizedDescription)")
                self.errorMessage = "An error occurred retrieving rankings from server"
            }
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
