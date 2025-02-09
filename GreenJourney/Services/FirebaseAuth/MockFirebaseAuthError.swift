enum MockFirebaseAuthError: Error {
    case invalidCredentials
    case resetPasswordFailed
    case createFirebaseUserFailed
    case sendEmailVerificationFailed
    case reloadUserFailed
    case isEmailVerifiedFailed
    case signInWithGoogleFailed
    case deleteFirebaseUserFailed
    case getFirebaseTokenFailed
    case getFirebaseUIDFailed
    case getUserFullNameFailed
}
