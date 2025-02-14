import Foundation
import Testing

@testable import GreenJourney

struct UserTest {
    @Test
    func testEmptyInitializer() {
        let user = User()
        
        #expect(user.userID == -1)
        #expect(user.firstName == "")
        #expect(user.lastName == "")
        #expect(user.birthDate == nil)
        #expect(user.gender == nil)
        #expect(user.firebaseUID == "")
        #expect(user.zipCode == nil)
        #expect(user.streetName == nil)
        #expect(user.houseNumber == nil)
        #expect(user.city == nil)
        #expect(user.scoreShortDistance == -1)
        #expect(user.scoreLongDistance == -1)
        #expect(user.badges.isEmpty)
    }
    
    @Test
    func testInitializerWithRequestedAttributes() {
        let user = User(
            firstName: "John",
            lastName: "Doe",
            firebaseUID: "firebase_uid",
            scoreShortDistance: 50,
            scoreLongDistance: 100
        )
        
        #expect(user.userID == nil)
        #expect(user.firstName == "John")
        #expect(user.lastName == "Doe")
        #expect(user.birthDate == nil)
        #expect(user.gender == nil)
        #expect(user.firebaseUID == "firebase_uid")
        #expect(user.zipCode == nil)
        #expect(user.streetName == nil)
        #expect(user.houseNumber == nil)
        #expect(user.city == nil)
        #expect(user.scoreShortDistance == 50)
        #expect(user.scoreLongDistance == 100)
        #expect(user.badges.isEmpty)
    }
    
    @Test
    func testInitializerWithAllAttributes() {
        let user = User(
            userID: 1,
            firstName: "John",
            lastName: "Doe",
            gender: "male",
            firebaseUID: "firebase_uid",
            zipCode: 100,
            streetName: "via via",
            houseNumber: 10,
            city: "city",
            scoreShortDistance: 50,
            scoreLongDistance: 100
        )
        
        #expect(user.userID == 1)
        #expect(user.firstName == "John")
        #expect(user.lastName == "Doe")
        #expect(user.birthDate == nil)
        #expect(user.gender == "male")
        #expect(user.firebaseUID == "firebase_uid")
        #expect(user.zipCode == 100)
        #expect(user.streetName == "via via")
        #expect(user.houseNumber == 10)
        #expect(user.city == "city")
        #expect(user.scoreShortDistance == 50)
        #expect(user.scoreLongDistance == 100)
        #expect(user.badges.isEmpty)
    }
    
    @Test
    func testEncodingDecoding() throws {
        let user = User(
            userID: 1,
            firstName: "John",
            lastName: "Doe",
            gender: "male",
            firebaseUID: "firebase_uid",
            zipCode: 100,
            streetName: "via via",
            houseNumber: 10,
            city: "city",
            scoreShortDistance: 50,
            scoreLongDistance: 100
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(user)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decodedUser = try decoder.decode(User.self, from: data)
        
        #expect(decodedUser.userID == user.userID)
        #expect(decodedUser.firstName == user.firstName)
        #expect(decodedUser.lastName == user.lastName)
        #expect(decodedUser.birthDate == user.birthDate)
        #expect(decodedUser.gender == user.gender)
        #expect(decodedUser.firebaseUID == user.firebaseUID)
        #expect(decodedUser.zipCode == user.zipCode)
        #expect(decodedUser.streetName == user.streetName)
        #expect(decodedUser.houseNumber == user.houseNumber)
        #expect(decodedUser.city == user.city)
        #expect(decodedUser.scoreShortDistance == user.scoreShortDistance)
        #expect(decodedUser.scoreLongDistance == user.scoreLongDistance)
        #expect(decodedUser.badges.isEmpty)
    }
}
