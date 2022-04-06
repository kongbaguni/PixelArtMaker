//
//  InAppPurchase.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/06/19.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import SwiftyStoreKit

struct InAppPurchase {
    let productIdSet:Set<String> = ["weeklyPlusMode","monthlyPlusMode","3monthPlusMode","6monthPlusMode","yearlyPlusMode"]
    
    let title:[String:String] = [
        "weeklyPlusMode":"1주",
        "monthlyPlusMode":"1개월",
        "3monthPlusMode":"3개월",
        "6monthPlusMode":"6개월",
        "yearlyPlusMode":"1년"
    ]
    
    let desc:[String:String] = [
        "weeklyADBonus":"1주일간 광고 없이 모든 기능을 사용합니다.",
        "monthlyADBonus":"한달동안 광고 없이 모든 기능을 사용합니다.",
        "3monthPlusMode":"3개월간 광고 없이 모든 기능을 사용합니다.",
        "6monthPlusMode":"6개월간 광고 없이 모든 기능을 사용합니다.",
        "yearlyPlusMode":"1년동안 광고 없이 모든 기능을 사용합니다."
    ]
    
    /** 인앱 결재 제품 정보 얻어오기*/
    func getProductInfo(force:Bool = false, complete:@escaping()->Void) {
        if InAppPurchaseModel.isEmpty == true || force {
            SwiftyStoreKit.retrieveProductsInfo(productIdSet) { (results) in
                InAppPurchaseModel.make(result: results)
                complete()
            }
        } else {
            complete()
        }
    }

    /** 구매내역 복원 */
    func restorePurchases(complete:@escaping(_ isSucess:Bool)->Void) {
        func restore() {
            let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: "ac8adb0c613b44a5bb4ebc1073cbfbfb")
            
            SwiftyStoreKit.verifyReceipt(using: appleValidator) { (result) in
                
                switch result {
                case .success(let receipt):
                    for id in productIdSet {
                        let sresult = SwiftyStoreKit.verifySubscription(ofType: .autoRenewable, productId: id, inReceipt: receipt)
                        switch sresult {
                        case .expired(let expiryDate, let items):
                            print("구독 복원 expired \(id) : \(expiryDate.formatted(date: .long, time: .standard))")
                            for item in items {
                                print("\(item.productId) \(item.purchaseDate)")
                            }
                            InAppPurchaseModel.set(productId: id, expireDt: expiryDate)
                            
                        case .purchased(let expiryDate, let items):
                            print("구독 복원 purchased \(id) : \(expiryDate.formatted(date: .long, time: .standard))")
                            for item in items {
                                print("\(item.productId) \(item.purchaseDate)")
                            }
                            UserDefaults.standard.lastInAppPurchaseExpireDate = expiryDate
                            InAppPurchaseModel.set(productId: id, expireDt: expiryDate)
                        default:
                            print("구독 복원 없음 \(id) purchased ")
                            InAppPurchaseModel.set(productId: id,  expireDt: nil)
                            
                        }
                    }
                    complete(true)
                case .error(let error):
                    print(error.localizedDescription)
                    complete(false)
                }
            }
        }
        
        if InAppPurchaseModel.isEmpty {
            SwiftyStoreKit.retrieveProductsInfo(productIdSet) { (results) in
                InAppPurchaseModel.make(result: results)
                restore()
            }
        } else {
            restore()
        }
    }
    
    /** 제품 구입 */
    func buyProduct(productId:String,complete:@escaping(_ isSucess:Bool)->Void) {
        
        SwiftyStoreKit.purchaseProduct(productId) { (result) in
            switch result {
            case .success(let purchase):
                print("Purchase Success: \(purchase.productId)")
                
                InAppPurchaseModel.set(productId: productId, purchaseDt: purchase.originalPurchaseDate)
                restorePurchases { isSucess in
                    complete(true)
                }

            case .error(let error):
                switch error.code {
                case .unknown: print("Unknown error. Please contact support")
                case .clientInvalid: print("Not allowed to make the payment")
                case .paymentCancelled: break
                case .paymentInvalid: print("The purchase identifier was invalid")
                case .paymentNotAllowed: print("The device is not allowed to make the payment")
                case .storeProductNotAvailable: print("The product is not available in the current storefront")
                case .cloudServicePermissionDenied: print("Access to cloud service information is not allowed")
                case .cloudServiceNetworkConnectionFailed: print("Could not connect to the network")
                case .cloudServiceRevoked: print("User has revoked permission to use this cloud service")
                default: print((error as NSError).localizedDescription)
                }
                complete(false)
            default:
                complete(false)
                break
            }
        }
    }
    
}