//
//  AuthManager.swift
//  PixelArtMaker
//
//  Created by Changyeol Seo on 2022/03/17.
//

import Foundation
import CryptoKit
import AuthenticationServices
import Firebase
import FirebaseAuth
import GoogleSignIn

extension Notification.Name {
    static let authDidSucessed = Notification.Name("authDidSucessed_observer")
}
class AuthManager : NSObject {
    static let shared = AuthManager()
    let auth = Auth.auth()
    
    var userId:String? {
        return auth.currentUser?.uid
    }
    
    var isSignined:Bool {
        return auth.currentUser != nil
    }
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError(
                        "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
                    )
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    
    fileprivate var didComplete:(_ loginSucess:Bool)->Void = { _ in }
    // Unhashed nonce.
    fileprivate var currentNonce: String?

    //    MARK: - 구글 아이디로 로그인하기
        func startSignInWithGoogleId(complete:@escaping(_ loginSucess:Bool)->Void) {
            didComplete = complete
            guard let clientID = FirebaseApp.app()?.options.clientID,
                  let vc = rootViewController
            else { return }

            // Create Google Sign In configuration object.
            let config = GIDConfiguration(clientID: clientID)

            // Start the sign in flow!
            GIDSignIn.sharedInstance.signIn(with: config, presenting: vc) { user, error in
                
                if let error = error {
                    print(error.localizedDescription)
                    complete(false)
                    return
                }
                
                guard
                    let authentication = user?.authentication,
                    let idToken = authentication.idToken
                else {
                    return
                }
                
                let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                               accessToken: authentication.accessToken)
                
                
                print(credential)
                Auth.auth().signIn(with: credential) { result, error in
                    if let err = error {
                        print(err.localizedDescription)
                        complete(false)
                        return
                    }
                    
                    complete(true)
                
                }
            }
        }
        
//MARK: - 애플 아이디로 로그인하기
    func startSignInWithAppleFlow(complete:@escaping(_ loginSucess:Bool)->Void) {
        didComplete = complete
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
//MARK: - 익명 로그인
    func startSignInAnonymously(complete:@escaping(_ loginSucess:Bool)->Void) {
        Auth.auth().signInAnonymously { authResult, error in
            if let err = error {
                print("error : \(err.localizedDescription)")
                complete(false)
                return
            }
            complete(true)
        }
    }
    
    func signout() {
        do {
            try auth.signOut()
            
            StageManager.shared.stage?.layers.removeAll()
            StageManager.shared.stage?.documentId = nil 
        } catch {
            print(error.localizedDescription)
        }
    }
}


extension AuthManager : ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return .init()
    }
}

extension AuthManager: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            // Initialize a Firebase credential.
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)
            // Sign in with Firebase.
            auth.signIn(with: credential) { [self] (authResult, error) in
                if let error = error {
                    // Error. If error.code == .MissingOrInvalidNonce, make sure
                    // you're sending the SHA256-hashed nonce as a hex string with
                    // your request to Apple.
                    print(error.localizedDescription)
                    return
                }
                print("login sucess")
                didComplete(true)
                print(authResult?.user.email ?? "없다")
                StageManager.shared.loadTemp { _ in 
                    NotificationCenter.default.post(name: .authDidSucessed, object: nil)
                }
                // User is signed in to Firebase with Apple.
                // ...
            }
            
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print("Sign in with Apple errored: \(error)")
    }
    
}

