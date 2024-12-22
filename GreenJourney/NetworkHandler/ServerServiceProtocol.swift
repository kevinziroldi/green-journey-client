protocol ServerServiceProtocol {
    // user
    func saveUserToServer(firebaseToken: String, firstName: String, lastName: String, firebaseUID: String) async throws
    func getUserFromServer(firebaseToken: String) async throws -> User
    
    // reviews
    func getReviewsForCity(firebaseToken: String, iata: String, countryCode: String) async throws -> CityReviewElement
    func getBestReviewedCities() async throws -> [CityReviewElement]
    func uploadReview(firebaseToken: String, review: Review) async throws -> Review
    func modifyReview(firebaseToken: String, modifiedReview: Review) async throws -> Review
    func deleteReview(firebaseToken: String, reviewID: Int) async throws
    
    // travels
    func getTravelsFromServer(firebaseToken: String) async throws -> [TravelDetails]
    func updateTravelOnServer(firebaseToken: String, modifiedTravel: Travel) async throws -> Travel
    func deleteTravelFromServer(firebaseToken: String, travelID: Int) async throws
}
