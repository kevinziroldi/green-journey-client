import Foundation
import SwiftData
import Combine

@MainActor
class RankingViewModel: ObservableObject {
    private let uuid: UUID = UUID()
    private var modelContext: ModelContext
    private var serverService: ServerServiceProtocol
    
    var users: [User] = []
    @Published var badges: [Badge] = []
    @Published var shortDistanceScore: Float64 = 0.0
    @Published var longDistanceScore: Float64 = 0.0
    @Published var shortDistanceRanking: [RankingElement] = []
    @Published var longDistanceRanking: [RankingElement] = []
    @Published var leaderboardSelected: Bool = true
    
    @Published var errorMessage: String? = nil
    @Published var resetRanking: Bool = false
    
    init(modelContext: ModelContext, serverService: ServerServiceProtocol) {
        self.modelContext = modelContext
        self.serverService = serverService
    }
    
    func getUserFromServer() async {
        do {
            let user = try await serverService.getUser()
            badges = user.badges
            shortDistanceScore = user.scoreShortDistance
            longDistanceScore = user.scoreLongDistance
            saveUserToSwiftData(serverUser: user)
        }
        catch {
            print("Error retrieving user from server")
        }
    }
    
    private func saveUserToSwiftData(serverUser: User?) {
        if let user = serverUser {
            // check no user logged
            do {
                let users = try modelContext.fetch(FetchDescriptor<User>())
                if users.count > 0 {
                    for user in users {
                        modelContext.delete(user)
                    }
                    try modelContext.save()
                }
                
                // add user to context
                modelContext.insert(user)
                
                // save user in SwiftData
                try modelContext.save()
            } catch {
                print("Error while interacting with SwiftData")
                return
            }
        }
    }
    
    func fecthRanking() async {
        self.errorMessage = nil
        self.resetRanking = true
        // get user id
        do {
            users = try modelContext.fetch(FetchDescriptor<User>())
        }catch {
            print("Error getting user from SwiftData")
            self.errorMessage = "An error occurred retrieving rankings from server, please try again later."
            return
        }
        guard let userID = users.first?.userID else {
            print("No user found")
            self.errorMessage = "An error occurred retrieving rankings from server, please try again later."
            return
        }
        
        // get ranking from server
        do {
            let rankingResponse = try await serverService.getRanking(userID: userID)
            self.shortDistanceRanking = rankingResponse.shortDistanceRanking
            self.longDistanceRanking = rankingResponse.longDistanceRanking
            self.resetRanking = false
        }catch {
            self.resetRanking = false
            self.longDistanceRanking = []
            self.shortDistanceRanking = []
            print("Error fetching rankings")
            self.errorMessage = "An error occurred retrieving rankings from server, please try again later."
        }
    }
    
    func computeTotalDuration (duration: Int) -> String {
        return DurationAsString.convertTotalDurationToString(totalDuration: duration/1000000000)
    }
    
    func getCurrentRanking(_ leaderboardType: Bool) -> [RankingElement] {
        if leaderboardType {
            return self.longDistanceRanking
        }
        else {
            return self.shortDistanceRanking
        }
    }
}

extension RankingViewModel: Hashable {
    nonisolated static func == (lhs: RankingViewModel, rhs: RankingViewModel) -> Bool {
        return lhs.uuid == rhs.uuid
    }
    
    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
}
