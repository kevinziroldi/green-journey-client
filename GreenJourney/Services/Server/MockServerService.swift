import Foundation

class MockServerService: ServerServiceProtocol {
    var shouldSucceed: Bool = true
    
    func saveUser(firstName: String, lastName: String, firebaseUID: String) async throws {
        if !shouldSucceed {
            throw MockServerError.saveUserFailed
        }
        // don't save anything
    }
    
    func getUser() async throws -> User {
        if shouldSucceed {
            // read mock user from json
            guard let path = Bundle.main.path(forResource: "mock_user", ofType: "json") else {
                print("Mock user file not found")
                return User()
            }
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let user = try decoder.decode(User.self, from: data)
                return user
            } catch {
                print(error)
                return User()
            }
        } else {
            throw MockServerError.getUserFailed
        }
    }
    
    func modifyUser(modifiedUser: User) async throws -> User {
        if shouldSucceed {
            // return the modified user itself
            return modifiedUser
        } else {
            throw MockServerError.modifyUserFailed
        }
    }
    
    func getRanking(userID: Int) async throws -> RankingResponse {
        if shouldSucceed {
            // read mock ranking from json
            guard let path = Bundle.main.path(forResource: "mock_ranking", ofType: "json") else {
                print("Mock ranking file not found")
                return RankingResponse()
            }
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let ranking = try decoder.decode(RankingResponse.self, from: data)
                return ranking
            } catch {
                print(error)
                return RankingResponse()
            }
        } else {
            throw MockServerError.getRankingFailed
        }
    }
    
    func getReviewsForCity(iata: String, countryCode: String) async throws -> CityReviewElement {
        if shouldSucceed {
            // read mock review from json
            guard let path = Bundle.main.path(forResource: "mock_review", ofType: "json") else {
                print("Mock review file not found")
                return CityReviewElement()
            }
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let reviews = try decoder.decode(CityReviewElement.self, from: data)
                return reviews
            } catch {
                print(error)
                return CityReviewElement()
            }
        } else {
            throw MockServerError.getReviewsCityFailed
        }
    }
    
    func getBestReviewedCities() async throws -> [CityReviewElement] {
        if shouldSucceed {
            // read mock review from json
            guard let path = Bundle.main.path(forResource: "mock_best_reviewed_cities", ofType: "json") else {
                print("Mock best reviewed cities file not found")
                return []
            }
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let bestCities = try decoder.decode([CityReviewElement].self, from: data)
                return bestCities
            } catch {
                print(error)
                return []
            }
        } else {
            throw MockServerError.getBestReviewsFailed
        }
    }
    
    func uploadReview(review: Review) async throws -> Review {
        if shouldSucceed {
            return review
        } else {
            throw MockServerError.uploadReviewFailed
        }
    }
    
    func modifyReview(modifiedReview: Review) async throws -> Review {
        if shouldSucceed {
            return modifiedReview
        } else {
            throw MockServerError.modifyReviewFailed
        }
    }
    
    func deleteReview(reviewID: Int) async throws {
        if shouldSucceed {
            return
        } else {
            throw MockServerError.deleteReviewFailed
        }
    }

    func computeRoutes(departureIata: String, departureCountryCode: String,
                       destinationIata: String, destinationCountryCode: String,
                       date: String, time: String, isOutward: Bool) async throws -> TravelOptionsResponse {
        if shouldSucceed {
            // read mock review from json
            guard let path = Bundle.main.path(forResource: "mock_travel_options", ofType: "json") else {
                print("Mock travel options file not found")
                return TravelOptionsResponse(options: [])
            }
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let travelOptions = try decoder.decode(TravelOptionsResponse.self, from: data)
                return travelOptions
            } catch {
                print(error)
                return TravelOptionsResponse(options: [])
            }
        } else {
            throw MockServerError.computeRoutesFailed
        }
    }
    
    // TODO
    func saveTravel(travelDetails: TravelDetails) async throws -> TravelDetails {
        if shouldSucceed {
            // TODO need to add info
            return travelDetails
        } else {
            throw MockServerError.saveTravelFailed
        }
    }
    
    func getTravels() async throws -> [TravelDetails] {
        if shouldSucceed {
            // read mock review from json
            guard let path = Bundle.main.path(forResource: "mock_user_travels", ofType: "json") else {
                print("Mock user travel file not found")
                return []
            }
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let travels = try decoder.decode([TravelDetails].self, from: data)
                return travels
            } catch {
                print(error)
                return []
            }
        } else {
            throw MockServerError.getTravelsFailed
        }
    }
    
    func updateTravel(modifiedTravel: Travel) async throws -> Travel {
        if shouldSucceed {
            return modifiedTravel
        } else {
            throw MockServerError.modifyTravelFailed
        }
    }
    
    func deleteTravel(travelID: Int) async throws {
        if shouldSucceed {
            return
        } else {
            throw MockServerError.deleteTravelFailed
        }
    }
}
