import SwiftData
import SwiftUI
import Testing

@testable import GreenJourney

@MainActor
final class CitiesReviewsViewModelIntegrationTest {
    private var serverService: ServerService
    
    init() async throws {
        self.serverService = ServerService()
        // clean database
        try await serverService.resetTestDatabase()
    }
}
