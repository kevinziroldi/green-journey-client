import Foundation
import Testing

@testable import GreenJourney

struct RankingResponseUnitTest {
    @Test
    func testEmptyInitializer() {
        let rankingResponse = RankingResponse()
        
        #expect(rankingResponse.shortDistanceRanking.isEmpty)
        #expect(rankingResponse.longDistanceRanking.isEmpty)
    }
    
    @Test
    func testEncodingDecoding() throws {
        let json = """
        {
            "short_distance_ranking": [
                {
                    "user_id": 1,
                    "first_name": "Mock",
                    "last_name": "Mock",
                    "total_distance": 100,
                    "score": 100,
                    "total_duration": 100,
                    "total_co_2_emitted": 100,
                    "total_co_2_compensated": 100,
                    "badges": []
                }
            ],
            "long_distance_ranking": []
        }
        """
        
        guard let data = json.data(using: .utf8) else {
            fatalError("Impossibile creare Data dal JSON")
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decodedResponse = try decoder.decode(RankingResponse.self, from: data)

        #expect(decodedResponse.shortDistanceRanking.count == 1)
        #expect(decodedResponse.longDistanceRanking.isEmpty)
    }
        
}
