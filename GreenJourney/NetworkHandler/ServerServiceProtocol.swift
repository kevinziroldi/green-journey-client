protocol ServerServiceProtocol {
    func saveUserToServer(firebaseToken: String, firstName: String, lastName: String, firebaseUID: String) async throws
    func getUserFromServer(firebaseToken: String) async throws -> User
    func getReviewsForCity(firebaseToken: String, iata: String, countryCode: String) async throws -> CityReviewElement
    func getBestReviewedCities() async throws -> [CityReviewElement]
    func getTravelsFromServer(firebaseToken: String) async throws -> [TravelDetails]
}
