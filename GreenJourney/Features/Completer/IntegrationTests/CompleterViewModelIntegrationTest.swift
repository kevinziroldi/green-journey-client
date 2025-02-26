import SwiftData
import Testing

@testable import GreenJourney

@MainActor
final class CompleterViewModelIntegrationTest {
    private var serverService: ServerService
    
    init() async throws {
        self.serverService = ServerService()
        // clean database
        try await serverService.resetTestDatabase()
    }
}
