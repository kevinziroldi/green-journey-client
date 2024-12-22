import FirebaseAuth

protocol FirebaseAuthServiceProtocol {
    func signIn(email: String, password: String) async throws -> AuthDataResult
    func createFirebaseUser(email: String, password: String) async throws -> AuthDataResult
    func sendEmailVerification(firebaseUser: FirebaseAuth.User) async throws
    func sendPasswordReset(email: String) async throws
    func getFirebaseToken(firebaseUser: FirebaseAuth.User) async throws -> String
    func reloadFirebaseUser(firebaseUser: FirebaseAuth.User) async throws
}
