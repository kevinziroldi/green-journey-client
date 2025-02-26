import Combine
import SwiftUI
import SwiftData
import Testing

@testable import GreenJourney

@MainActor
final class UserPreferencesViewModelUnitTest {
    private var viewModel: UserPreferencesViewModel
    private var mockServerService: MockServerService
    private var mockFirebaseAuthService: MockFirebaseAuthService
    private var mockModelContainer: ModelContainer
    private var mockModelContext: ModelContext
    
    init() throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: User.self, Travel.self, Segment.self, CityFeatures.self, CityCompleterDataset.self, configurations: configuration)
        self.mockModelContainer = container
        self.mockModelContext = container.mainContext
        
        self.mockServerService = MockServerService()
        self.mockFirebaseAuthService = MockFirebaseAuthService()
        self.viewModel = UserPreferencesViewModel(modelContext: container.mainContext, serverService: mockServerService)
    }
    
    private func addUserToSwiftData() throws {
        let mockUser = User(
            userID: 1,
            firstName: "John",
            lastName: "Doe",
            gender: "male",
            firebaseUID: "john_doe_firebase_uid",
            zipCode: 19,
            city: "London",
            scoreShortDistance: 50,
            scoreLongDistance: 100
        )
        
        self.mockModelContext.insert(mockUser)
        try self.mockModelContext.save()
    }
    
    private func addUserToSwiftDataNoGender() throws {
        let mockUser = User(
            userID: 1,
            firstName: "John",
            lastName: "Doe",
            gender: nil,
            firebaseUID: "john_doe_firebase_uid",
            zipCode: 19,
            city: "London",
            scoreShortDistance: 50,
            scoreLongDistance: 100
        )
        
        self.mockModelContext.insert(mockUser)
        try self.mockModelContext.save()
    }
    
    private func addUserToSwiftDataNoId() throws {
        let mockUser = User(
            userID: nil,
            firstName: "John",
            lastName: "Doe",
            gender: "male",
            firebaseUID: "john_doe_firebase_uid",
            zipCode: 19,
            city: "London",
            scoreShortDistance: 50,
            scoreLongDistance: 100
        )
        
        self.mockModelContext.insert(mockUser)
        try self.mockModelContext.save()
    }
    
    @Test
    func testGetUserDataNoUser() async throws {
        // no user present
        viewModel.getUserData()
        
        #expect(viewModel.firstName == "")
        #expect(viewModel.lastName == "")
        #expect(viewModel.birthDate == nil)
        #expect(viewModel.gender == Gender.notSpecified)
        #expect(viewModel.city == nil)
        #expect(viewModel.streetName == nil)
        #expect(viewModel.houseNumber == nil)
        #expect(viewModel.zipCode == nil)
        #expect(viewModel.errorMessage != nil)
    }
    
    @Test
    func testGetUserDataNoGender() async throws {
        try addUserToSwiftDataNoGender()
        viewModel.getUserData()
        
        #expect(viewModel.firstName == "John")
        #expect(viewModel.lastName == "Doe")
        #expect(viewModel.birthDate == nil)
        #expect(viewModel.gender == Gender.notSpecified)
        #expect(viewModel.city == "London")
        #expect(viewModel.streetName == nil)
        #expect(viewModel.houseNumber == nil)
        #expect(viewModel.zipCode == 19)
        #expect(viewModel.errorMessage == nil)
    }
        
    @Test
    func testGetUserDataWithUser() async throws {
        // add a user
        try addUserToSwiftData()
        
        viewModel.getUserData()
        
        #expect(viewModel.firstName == "John")
        #expect(viewModel.lastName == "Doe")
        #expect(viewModel.birthDate == nil)
        #expect(viewModel.gender == Gender.male)
        #expect(viewModel.city == "London")
        #expect(viewModel.streetName == nil)
        #expect(viewModel.houseNumber == nil)
        #expect(viewModel.zipCode == 19)
        #expect(viewModel.errorMessage == nil)
    }
    
    @Test
    func testSaveModificationsNoUser() async {
        // no user present
        
        await viewModel.saveModifications()
        
        #expect(viewModel.errorMessage != nil)
    }
    
    @Test
    func testSaveModificationsUserNoId() async throws {
        // add user without userId to SwiftData
        try addUserToSwiftDataNoId()
        
        await viewModel.saveModifications()
        
        #expect(viewModel.errorMessage != nil)
    }
    
    @Test
    func testSaveModificationsServerFails() async throws {
        // set server service
        self.mockServerService.shouldSucceed = false
        
        // add user with userId to SwiftData
        try addUserToSwiftData()
        viewModel.getUserData()
        
        // add new data, correct type
        viewModel.houseNumber = 10
        // modify data, correct type
        viewModel.zipCode = 20
        
        await viewModel.saveModifications()
        
        #expect(viewModel.firstName == "John")
        #expect(viewModel.lastName == "Doe")
        #expect(viewModel.birthDate == nil)
        #expect(viewModel.gender == Gender.male)
        #expect(viewModel.city == "London")
        #expect(viewModel.streetName == nil)
        #expect(viewModel.houseNumber == 10)
        #expect(viewModel.zipCode == 20)
        #expect(viewModel.errorMessage != nil)
        
        let user = try mockModelContext.fetch(FetchDescriptor<User>()).first!
        #expect(user.userID == 1)
        #expect(user.firstName == "John")
        #expect(user.lastName == "Doe")
        #expect(user.birthDate == nil)
        #expect(user.gender == "male")
        #expect(user.firebaseUID == "john_doe_firebase_uid")
        #expect(user.zipCode == 19)
        #expect(user.streetName == nil)
        #expect(user.houseNumber == nil)
        #expect(user.city == "London")
        #expect(user.scoreShortDistance == 50)
        #expect(user.scoreLongDistance == 100)
        #expect(user.badges == [])
    }
    
    @Test
    func testSaveModificationsCorrectDataType() async throws {
        // set server service
        self.mockServerService.shouldSucceed = true
        
        // add user with userId to SwiftData
        try addUserToSwiftData()
        viewModel.getUserData()
        
        // add new data, correct type
        viewModel.houseNumber = 10
        // modify data, correct type
        viewModel.zipCode = 20
        
        await viewModel.saveModifications()
        
        #expect(viewModel.firstName == "John")
        #expect(viewModel.lastName == "Doe")
        #expect(viewModel.birthDate == nil)
        #expect(viewModel.gender == Gender.male)
        #expect(viewModel.city == "London")
        #expect(viewModel.streetName == nil)
        #expect(viewModel.houseNumber == 10)
        #expect(viewModel.zipCode == 20)
        #expect(viewModel.errorMessage == nil)
        
        let user = try mockModelContext.fetch(FetchDescriptor<User>()).first!
        #expect(user.userID == 1)
        #expect(user.firstName == "John")
        #expect(user.lastName == "Doe")
        #expect(user.birthDate == nil)
        #expect(user.gender == "male")
        #expect(user.firebaseUID == "john_doe_firebase_uid")
        #expect(user.zipCode == 20)
        #expect(user.streetName == nil)
        #expect(user.houseNumber == 10)
        #expect(user.city == "London")
        #expect(user.scoreShortDistance == 50)
        #expect(user.scoreLongDistance == 100)
        #expect(user.badges == [])
    }
    
    @Test
    func testSaveModificationsEmptyStrings() async throws {
        // set server service
        self.mockServerService.shouldSucceed = true
        
        // add user with userId to SwiftData
        try addUserToSwiftData()
        viewModel.getUserData()
        
        // must be interpreted as nil
        viewModel.city = ""
        viewModel.streetName = ""
        
        await viewModel.saveModifications()
        
        #expect(viewModel.firstName == "John")
        #expect(viewModel.lastName == "Doe")
        #expect(viewModel.birthDate == nil)
        #expect(viewModel.gender == Gender.male)
        #expect(viewModel.city == nil)
        #expect(viewModel.streetName == nil)
        #expect(viewModel.houseNumber == nil)
        #expect(viewModel.zipCode == 19)
        #expect(viewModel.errorMessage == nil)
        
        let user = try mockModelContext.fetch(FetchDescriptor<User>()).first!
        #expect(user.userID == 1)
        #expect(user.firstName == "John")
        #expect(user.lastName == "Doe")
        #expect(user.birthDate == nil)
        #expect(user.gender == "male")
        #expect(user.firebaseUID == "john_doe_firebase_uid")
        #expect(user.zipCode == 19)
        #expect(user.streetName == nil)
        #expect(user.houseNumber == nil)
        #expect(user.city == nil)
        #expect(user.scoreShortDistance == 50)
        #expect(user.scoreLongDistance == 100)
        #expect(user.badges == [])
    }
    
    @Test
    func testGetBindingValue() {
        var number: Int? = 42
        let intBinding = Binding<Int?>(
            get: { number },
            set: { number = $0 }
        )
        
        let stringBinding = viewModel.binding(for: intBinding)
        
        #expect(stringBinding.wrappedValue == "42")
    }
    
    @Test
    func testGetBindingNil() {
        var number: Int? = nil
        let intBinding = Binding<Int?>(
            get: { number },
            set: { number = $0 }
        )
        
        let stringBinding = viewModel.binding(for: intBinding)
        
        #expect(stringBinding.wrappedValue == "")
    }
    
    @Test
    func testSetBindingValue() {
        var number: Int? = nil
        let intBinding = Binding<Int?>(
            get: { number },
            set: { number = $0 }
        )
        
        let stringBinding = viewModel.binding(for: intBinding)
        stringBinding.wrappedValue = "123"
        
        #expect(number == 123)
    }
    
    @Test
    func testSetBindingNil() {
        var number: Int? = 50
        let intBinding = Binding<Int?>(
            get: { number },
            set: { number = $0 }
        )
        
        let stringBinding = viewModel.binding(for: intBinding)
        stringBinding.wrappedValue = "non-numeric"
        
        #expect(number == nil)
    }
    
    @Test
    func testCancelModifications() async throws {
        // set server service
        self.mockServerService.shouldSucceed = true
        
        // add user with userId to SwiftData
        try addUserToSwiftData()
        viewModel.getUserData()
        
        // add new data, correct type
        viewModel.houseNumber = 10
        // modify data, correct type
        viewModel.zipCode = 20
        
        viewModel.cancelModifications()
        
        #expect(viewModel.firstName == "John")
        #expect(viewModel.lastName == "Doe")
        #expect(viewModel.birthDate == nil)
        #expect(viewModel.gender == Gender.male)
        #expect(viewModel.city == "London")
        #expect(viewModel.streetName == nil)
        #expect(viewModel.houseNumber == nil)
        #expect(viewModel.zipCode == 19)
        #expect(viewModel.errorMessage == nil)
        
        let user = try mockModelContext.fetch(FetchDescriptor<User>()).first!
        #expect(user.userID == 1)
        #expect(user.firstName == "John")
        #expect(user.lastName == "Doe")
        #expect(user.birthDate == nil)
        #expect(user.gender == "male")
        #expect(user.firebaseUID == "john_doe_firebase_uid")
        #expect(user.zipCode == 19)
        #expect(user.streetName == nil)
        #expect(user.houseNumber == nil)
        #expect(user.city == "London")
        #expect(user.scoreShortDistance == 50)
        #expect(user.scoreLongDistance == 100)
        #expect(user.badges == [])
    }
}
