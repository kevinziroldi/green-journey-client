protocol ServerServiceProtocol {
    // user
    func saveUser(firstName: String, lastName: String, firebaseUID: String) async throws
    func getUser() async throws -> User
    func modifyUser(modifiedUser: User) async throws -> User
    
    // ranking
    func getRanking(userID: Int) async throws -> RankingResponse
    
    // reviews
    func getFirstReviewsForCity(iata: String, countryCode: String) async throws -> CityReviewElement
    func getLastReviewsForCity(iata: String, countryCode: String) async throws -> CityReviewElement
    func getReviewsForCity(iata: String, countryCode: String, reviewID: Int, direction: Bool) async throws -> CityReviewElement
    func getBestReviewedCities() async throws -> [CityReviewElement]
    func uploadReview(review: Review) async throws -> Review
    func modifyReview(modifiedReview: Review) async throws -> Review
    func deleteReview(reviewID: Int) async throws
    
    // search travels
    func computeRoutes(departureIata: String, departureCountryCode: String,
                       destinationIata: String, destinationCountryCode: String,
                       date: String, time: String, isOutward: Bool) async throws -> [TravelOption]
    func saveTravel(travelDetails: TravelDetails) async throws -> TravelDetails
    
    // travels
    func getTravels() async throws -> [TravelDetails]
    func updateTravel(modifiedTravel: Travel) async throws -> Travel
    func deleteTravel(travelID: Int) async throws
    
    // reset test database
    func resetTestDatabase() async throws
}
