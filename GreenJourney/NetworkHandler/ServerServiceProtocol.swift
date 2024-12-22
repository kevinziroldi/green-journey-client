protocol ServerServiceProtocol {
    // user
    func saveUser(firebaseToken: String, firstName: String, lastName: String, firebaseUID: String) async throws
    func getUser(firebaseToken: String) async throws -> User
    
    // ranking
    func getRanking(userID: Int) async throws -> RankingResponse
    
    // reviews
    func getReviewsForCity(firebaseToken: String, iata: String, countryCode: String) async throws -> CityReviewElement
    func getBestReviewedCities() async throws -> [CityReviewElement]
    func uploadReview(firebaseToken: String, review: Review) async throws -> Review
    func modifyReview(firebaseToken: String, modifiedReview: Review) async throws -> Review
    func deleteReview(firebaseToken: String, reviewID: Int) async throws
    
    // search travels
    func computeRoutes(departureIata: String, departureCountryCode: String,
                       destinationIata: String, destinationCountryCode: String,
                       date: String, time: String, isOutward: Bool) async throws -> TravelOptionsResponse
    func saveTravel(firebaseToken: String, travelDetails: TravelDetails) async throws -> TravelDetails
    
    // travels
    func getTravels(firebaseToken: String) async throws -> [TravelDetails]
    func updateTravel(firebaseToken: String, modifiedTravel: Travel) async throws -> Travel
    func deleteTravel(firebaseToken: String, travelID: Int) async throws
}
