import Foundation
import SwiftData
import Testing

@testable import GreenJourney

@MainActor
final class DestinationPredictionViewModelIntegrationTest {
    private var serverService: ServerService
    
    init() async throws {
        self.serverService = ServerService()
        // clean database
        try await serverService.resetTestDatabase()
    }
}
