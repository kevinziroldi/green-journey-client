import Foundation
import SwiftData
import Combine

@MainActor
class RankingViewModel: ObservableObject {
    var modelContext: ModelContext
    private var serverService: ServerServiceProtocol
    
    var users: [User] = []
    
    @Published var shortDistanceRanking: [RankingElement] = []
    @Published var longDistanceRanking: [RankingElement] = []
    @Published var leaderboardSelected: Bool = true
    
    @Published var errorMessage: String? = nil
    
    init(modelContext: ModelContext, serverService: ServerServiceProtocol) {
        self.modelContext = modelContext
        self.serverService = serverService
    }
    
    func fecthRanking() async {
        self.errorMessage = nil
        
        // get user id
        do {
            users = try modelContext.fetch(FetchDescriptor<User>())
        }catch {
            print("Error getting user from SwiftData")
            self.errorMessage = "An error occurred retrieving rankings from server"
            return
        }
        guard let userID = users.first?.userID else {
            print("No user found")
            self.errorMessage = "An error occurred retrieving rankings from server"
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
    
    func computeTotalDuration (duration: Int) -> String {
        return UtilitiesFunctions.convertTotalDurationToString(totalDuration: duration/1000000000)
    }
}
