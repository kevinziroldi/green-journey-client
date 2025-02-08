protocol FirebaseAuthServiceProtocol {
    func signInWithCredentials(email: String, password: String) async throws -> Bool
    func signInWithGoogle() async throws -> Bool
    func createFirebaseUser(email: String, password: String) async throws -> String
    func sendEmailVerification() async throws
    func isEmailVerified() async throws -> Bool
    func sendPasswordReset(email: String) async throws
    func deleteFirebaseUser() async throws
    func getFirebaseToken() async throws -> String
    func getFirebaseUID() async throws -> String
    func getUserFullName() async throws -> String
    func reloadFirebaseUser() async throws
}
