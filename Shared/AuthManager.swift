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
import FirebaseFirestore
import FirebaseAuth
import GoogleSignIn
import RealmSwift
import SwiftUI
import Alamofire

extension Notification.Name {
    static let authDidSucessed = Notification.Name("authDidSucessed_observer")
    static let signoutDidSucessed = Notification.Name("signoutDidSucessed_observer")
}
class AuthManager : NSObject {
    static let shared = AuthManager()
    let auth = Auth.auth()
    var appleReAuth = false
    var userId:String? {
        return auth.currentUser?.uid
    }
    
    var profileModel:ProfileModel? {
        if let id = userId {
            return ProfileModel.findBy(uid: id)
        }
        return nil
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
    
    
    fileprivate var didComplete:(_ loginSucess:Bool, _ error: Error?)->Void = { _ , _ in }
    // Unhashed nonce.
    fileprivate var currentNonce: String?
    
    //MARK: - 구글 아이디로 로그인하기
    func startSignInWithGoogleId(complete:@escaping(_ loginSucess:Bool, _ error:Error? )->Void) {
        didComplete = complete
        guard let clientID = FirebaseApp.app()?.options.clientID,
              let vc = rootViewController
        else { return }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
            
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: vc) { result, error in
            
            if let error = error {
                print(error.localizedDescription)
                complete(false, error)
                return
            }
            
            
            guard
                let accessToken = result?.user.accessToken,
                let idToken = result?.user.idToken
            else {
                return
            }
            
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString,
                                                           accessToken: accessToken.tokenString)
            
            
            print(credential)
            Auth.auth().signIn(with: credential) { result, error in
                if let err = error {
                    print(err.localizedDescription)
                    complete(false, err)
                    return
                }
                StageManager.shared.loadTemp(isOnlineDownload: true) { error in
                    NotificationCenter.default.post(name: .authDidSucessed, object: nil)
                    complete(true, nil)
                }
                
            }
        }
    }
    
    //MARK: - 애플 아이디로 로그인하기
    func startSignInWithAppleFlow(complete:@escaping(_ loginSucess:Bool, _ error:Error?)->Void) {
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
    func startSignInAnonymously(complete:@escaping(_ loginSucess:Bool, _ error:Error?)->Void) {
        Auth.auth().signInAnonymously { authResult, error in
            if let err = error {
                print("error : \(err.localizedDescription)")
                complete(false, err)
                return
            }
            complete(true,nil)
        }
    }
    //MARK: - 로그아웃
    func signout() {
        StageManager.shared.saveTemp(isOnlineUpdate: true) { [self] error in
            do {
                try auth.signOut()
                
                StageManager.shared.initStage(canvasSize: StageManager.shared.canvasSize)
                StageManager.shared.stage?.documentId = nil
                StageManager.shared.stage?.previewImage = nil
                let realm = try! Realm()
                try! realm.write {
                    realm.deleteAll()
                }
                NotificationCenter.default.post(name: .layerDataRefresh, object: nil)
                NotificationCenter.default.post(name: .signoutDidSucessed, object: nil)

            } catch {
                print(error.localizedDescription)
            }
        }
    }

    //MARK: - 탈퇴하기
    func leave(progress:@escaping(_ progress:(title:Text,completed:Int,total:Int))->Void, complete:@escaping(_ error:Error?)->Void) {
        guard let uid = userId else {
            return
        }
        func deleteArticles(complete:@escaping(_ error:Error?)->Void) {
            Firestore.firestore().collection("public").whereField("uid", isEqualTo: uid).getDocuments { querySnapShot, error1 in
                if let err = error1 {
                    complete(err)
                    return
                }
                
                let totalCount = querySnapShot?.documents.count ?? 0
                var completeCount = 0
                var errors:[Error] = []
                if totalCount == 0 {
                    complete(nil)
                    return
                }
                
                for doc in querySnapShot?.documents ?? [] {
                    if let docId = doc.data()["documentId"] as? String {
                        FirebaseStorageHelper.shared.delete(deleteURL: "shareImages/\(docId)") { error2 in
                            Firestore.firestore().collection("public").document(doc.documentID).delete { error3 in
                                if error2 == nil && error3 == nil {
                                    completeCount += 1
                                    progress((title:Text("leave delete articles msg"),completed:completeCount, total:totalCount))
                                } else {
                                    errors.append((error2 ?? error3)!)
                                }
                                
                                if completeCount == totalCount {
                                    complete(nil)
                                    return
                                }
                                if completeCount + errors.count == totalCount && errors.count > 0 {
                                    complete(errors.first!)
                                }
                            }
                        }
                    }
                }
            }

        }
        
        func deleteReplys(complete:@escaping(_ error:Error?)->Void) {
            Firestore.firestore().collection("reply").whereField("uid", isEqualTo: uid).getDocuments { querysnapShot, error1 in
                if let err = error1 {
                    complete(err)
                    return
                }
                let totalCount = querysnapShot?.documents.count ?? 0
                var completedCount = 0
                if totalCount == 0 {
                    complete(nil)
                    return
                }
                var errors:[Error] = []
                for doc in querysnapShot?.documents ?? [] {
                    let id = doc.documentID
                    Firestore.firestore().collection("reply").document(id).delete { error2 in
                        if error2 == nil {
                            completedCount += 1
                            progress((title:Text("leave delete replys msg"),completed:completedCount,total:totalCount))
                        } else {
                            errors.append(error2!)
                        }
                        if totalCount == completedCount {
                            complete(nil)
                            return
                        }
                        if errors.count + completedCount == totalCount && errors.count > 0 {
                            complete(errors.first!)
                        }
                    }
                }
            }
        }
        
        func deleteLikes(complete:@escaping(_ error:Error?)->Void) {
            Firestore.firestore().collection("like").whereField("uid", isEqualTo: uid).getDocuments { querysnapshot, error1 in
                if let err = error1 {
                    complete(err)
                    return
                }
                let totalCount = querysnapshot?.documents.count ?? 0
                var completeCount = 0
                var errors:[Error] = []
                
                if totalCount == 0 {
                    complete(nil)
                    return
                }
                for doc in querysnapshot?.documents ?? [] {
                    let id = doc.documentID
                    Firestore.firestore().collection("like").document(id).delete { error2 in
                        if let err = error2 {
                            errors.append(err)
                        }
                        else {
                            completeCount += 1
                            progress((title:Text("leave delete like msg"), completed:completeCount, total:totalCount))
                        }
                        if totalCount == completeCount {
                            complete(nil)
                            return
                        }
                        if errors.count + completeCount == totalCount {
                            complete(errors.first)
                        }
                    }
                }
            }
        }

     
      
        
        
//        // Prompt the user to re-provide their sign-in credentials
//        user.reauthenticate(with: credential) { error,arg   in
//          if let error = error {
//            // An error happened.
//          } else {
//            // User re-authenticated.
//          }
//        }
        
        print(auth.currentUser?.providerID ?? "")
        print(auth.currentUser?.providerData.first?.providerID ?? "")
        func reauth(complete:@escaping(_ isSucess:Bool, _ error:Error?)->Void) {
            switch auth.currentUser?.providerData.first?.providerID {
            case "google.com":
                print("구글 이다")
                startSignInWithGoogleId { loginSucess , error in
                    complete(loginSucess, error)
                }
            case "apple.com":
                appleReAuth = true
                startSignInWithAppleFlow { loginSucess, error  in
                    self.appleReAuth = false
                    complete(loginSucess, error)
                }
                print("애플 이다")
            default:
                print("모르겠다")
            }
        }
        reauth { isSucess , errorA in
            if isSucess {
                deleteArticles { errorB in
                    deleteReplys { errorC in
                        deleteLikes { errorD in
                            Auth.auth().currentUser?.delete(completion: { errorE in
                                let error = errorA ?? errorB ?? errorC ?? errorD ?? errorE
                                print(error?.localizedDescription ?? "sucess")
                                if error == nil {
                                    StageManager.shared.initStage(canvasSize: StageManager.shared.canvasSize)
                                    StageManager.shared.stage?.documentId = nil
                                    StageManager.shared.stage?.previewImage = nil
                                    let realm = try! Realm()
                                    try! realm.write {
                                        realm.deleteAll()
                                    }
                                    NotificationCenter.default.post(name: .layerDataRefresh, object: nil)
                                    NotificationCenter.default.post(name: .signoutDidSucessed, object: nil)
                                }
                            })

                        }
                    }
                }
            }

        }
    }

    
    func upgradeAnonymousWithGoogleId(complete:@escaping(_ isSucess:Bool, _ error:Error?)->Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID,
              let vc = rootViewController
        else { return }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
            
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: vc) { [unowned self] result, error  in
            guard
                let accessToken = result?.user.accessToken.tokenString,
                let idToken = result?.user.idToken?.tokenString
            else {
              return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: accessToken)
            auth.currentUser?.link(with: credential, completion: { result, error in
                complete(error == nil, error)
            })
        }
    }
    
    func upgradeAnonymousWithAppleId(complete:@escaping(_ isSucess:Bool, _ error:Error?)->Void) {
        startSignInWithAppleFlow(complete: complete)
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
            
            if auth.currentUser == nil || appleReAuth {
                // Sign in with Firebase.
                auth.signIn(with: credential) { [self] (authResult, error) in
                    if let error = error {
                        // Error. If error.code == .MissingOrInvalidNonce, make sure
                        // you're sending the SHA256-hashed nonce as a hex string with
                        // your request to Apple.
                        print(error.localizedDescription)
                        didComplete(false, error)
                        return
                    }
                    print("login sucess")
                    didComplete(true, nil)
                    print(authResult?.user.email ?? "없다")
                    StageManager.shared.loadTemp(isOnlineDownload: true) { error in
                        NotificationCenter.default.post(name: .authDidSucessed, object: nil)
                    }
                    // User is signed in to Firebase with Apple.
                    // ...
                }
            } else {
                auth.currentUser?.link(with: credential, completion: { [unowned self] result, error in
                    didComplete(error == nil, error)
                })
            }
            
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print("Sign in with Apple errored: \(error)")
    }
    
}
