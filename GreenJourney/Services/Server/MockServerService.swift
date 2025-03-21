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
    
    func getFirstReviewsForCity(iata: String, countryCode: String) async throws -> CityReviewElement {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        if shouldSucceed {
            // read mock 2 reviews from json
            guard let path = Bundle.main.path(forResource: "mock_prev_page_reviews", ofType: "json") else {
                print("Mock review file not found")
                throw ServerServiceError.getReviewsCityFailed
            }
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            return try decoder.decode(CityReviewElement.self, from: data)
        }
        
        throw ServerServiceError.getReviewsCityFailed
    }
    
    func getLastReviewsForCity(iata: String, countryCode: String) async throws -> CityReviewElement {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        if shouldSucceed {
            guard let path = Bundle.main.path(forResource: "mock_next_page_reviews", ofType: "json") else {
                print("Mock review file not found")
                throw ServerServiceError.getReviewsCityFailed
            }
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            return try decoder.decode(CityReviewElement.self, from: data)
        }
        
        throw ServerServiceError.getReviewsCityFailed
    }
    
    func getReviewsForCity(iata: String, countryCode: String, reviewID: Int, direction: Bool) async throws -> CityReviewElement {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        if shouldSucceed {
            if direction == true {
                guard let path = Bundle.main.path(forResource: "mock_next_page_reviews", ofType: "json") else {
                    print("Mock review file not found")
                    throw ServerServiceError.getReviewsCityFailed
                }
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                return try decoder.decode(CityReviewElement.self, from: data)
            } else {
                guard let path = Bundle.main.path(forResource: "mock_prev_page_reviews", ofType: "json") else {
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
                var bestCitiesPrefix: [CityReviewElement] = []
                for bc in bestCities {
                    let bestCity = bc
                    bestCity.reviews = Array(bc.reviews.prefix(10))
                    bestCitiesPrefix.append(bestCity)
                }
                return bestCitiesPrefix
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
                       date: String, time: String, isOutward: Bool) async throws -> [TravelOption] {
        if shouldSucceed {
            // read mock review from json
            guard let path = Bundle.main.path(forResource: "mock_travel_options", ofType: "json") else {
                print("Mock travel options file not found")
                return [TravelOption(segments: [])]
            }
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let travelOptionsRaw = try decoder.decode(TravelOptionsResponse.self, from: data)
                
                // convert to [TravelOption]
                var travelOptions: [TravelOption] = []
                for segments in travelOptionsRaw.options {
                    travelOptions.append(TravelOption(segments: segments))
                }
                
                return travelOptions
            } catch {
                print(error)
                return [TravelOption(segments: [])]
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
    
    func resetTestDatabase() async throws {
        // nothing to do, the test database is used by the real server
    }
}
