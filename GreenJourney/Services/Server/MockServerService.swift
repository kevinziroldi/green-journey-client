import Foundation

class MockServerService: ServerServiceProtocol {
    var shouldSucceed: Bool = true
    var twoReviews: Bool = true
    var tenReviews: Bool = false
    
    func saveUser(firstName: String, lastName: String, firebaseUID: String) async throws {
        if !shouldSucceed {
            throw ServerServiceError.saveUserFailed
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
            throw ServerServiceError.getUserFailed
        }
    }
    
    func modifyUser(modifiedUser: User) async throws -> User {
        if shouldSucceed {
            // return the modified user itself
            return modifiedUser
        } else {
            throw ServerServiceError.modifyUserFailed
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
            throw ServerServiceError.getRankingFailed
        }
    }
    
    func getReviewsForCity(iata: String, countryCode: String) async throws -> CityReviewElement {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        if shouldSucceed {
            if twoReviews {
                // read mock 2 reviews from json
                guard let path = Bundle.main.path(forResource: "mock_review_2_elements", ofType: "json") else {
                    print("Mock review file not found")
                    throw ServerServiceError.getReviewsCityFailed
                }
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                return try decoder.decode(CityReviewElement.self, from: data)
            } else if tenReviews {
                // read mock 10 reviews from json
                guard let path = Bundle.main.path(forResource: "mock_review_10_elements", ofType: "json") else {
                    print("Mock review file not found")
                    throw ServerServiceError.getReviewsCityFailed
                }
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                return try decoder.decode(CityReviewElement.self, from: data)
            }
        }
        
        throw ServerServiceError.getReviewsCityFailed
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
            throw ServerServiceError.getBestReviewsFailed
        }
    }
    
    func uploadReview(review: Review) async throws -> Review {
        if shouldSucceed {
            // set an id 
            review.reviewID = 1
            return review
        } else {
            throw ServerServiceError.uploadReviewFailed
        }
    }
    
    func modifyReview(modifiedReview: Review) async throws -> Review {
        if shouldSucceed {
            return modifiedReview
        } else {
            throw ServerServiceError.modifyReviewFailed
        }
    }
    
    func deleteReview(reviewID: Int) async throws {
        if !shouldSucceed {
            throw ServerServiceError.deleteReviewFailed
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
            throw ServerServiceError.computeRoutesFailed
        }
    }
    
    func saveTravel(travelDetails: TravelDetails) async throws -> TravelDetails {
        if shouldSucceed {
            // add custom travelID
            travelDetails.travel.travelID = 999
            return travelDetails
        } else {
            throw ServerServiceError.saveTravelFailed
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
            throw ServerServiceError.getTravelsFailed
        }
    }
    
    func updateTravel(modifiedTravel: Travel) async throws -> Travel {
        if shouldSucceed {
            return modifiedTravel
        } else {
            throw ServerServiceError.modifyTravelFailed
        }
    }
    
    func deleteTravel(travelID: Int) async throws {
        if shouldSucceed {
            return
        } else {
            throw ServerServiceError.deleteTravelFailed
        }
    }
}
