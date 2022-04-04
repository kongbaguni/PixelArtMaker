//
//  InAppPurchaseModel.swift
//  PixelArtMaker (iOS)
//
//  Created by Changyul Seo on 2022/04/04.
//

import Foundation
import RealmSwift
import SwiftyStoreKit

class InAppPurchaseModel: Object {
    @Persisted(primaryKey: true) var id:String = ""
    @Persisted var title:String = ""
    @Persisted var desc:String = ""
    @Persisted var price:Float = 0
    @Persisted var priceLocaleId:String = ""
    @Persisted var expireDate:Date = Date(timeIntervalSince1970: 0)
}

extension InAppPurchaseModel {
    var isExpire:Bool {
        return expireDate < Date()
    }

    var localeFormatedPrice:String? {
        let locale = Locale(identifier: priceLocaleId)
        
        return price.getFormatString(locale: locale, style: .currency)
    }
    
    static var isEmpty:Bool {
        let list = try! Realm().objects(InAppPurchaseModel.self)
        return list.count == 0
    }
    
    static func make(result:RetrieveResults) {
        let purch = InAppPurchase()
        let realm = try! Realm()
        realm.beginWrite()
        for product in result.retrievedProducts {
            let data:[String:Any] = [
                "id": product.productIdentifier,
                "title" : product.localizedTitle.isEmpty ? (purch.title[product.productIdentifier] ?? "") : product.localizedTitle,
                "desc" : product.localizedDescription.isEmpty ? (purch.desc[product.productIdentifier] ?? "") : product.localizedDescription,
                "price" : product.price.floatValue,
                "priceLocaleId" : product.priceLocale.identifier,
            ]
            realm.create(InAppPurchaseModel.self, value: data, update: .modified)
        }
        try! realm.commitWrite()
    }
    
    static func set(productId:String, expireDt:Date?) {
        let data:[String:Any] = [
            "id":productId,
            "expireDate":expireDt ?? Date(timeIntervalSince1970: 0)
        ]
        let realm = try! Realm()
        realm.beginWrite()
        realm.create(InAppPurchaseModel.self, value: data, update: .modified)
        try! realm.commitWrite()
    }
    
    static func model(productId:String)->InAppPurchaseModel? {
        return try! Realm().object(ofType: InAppPurchaseModel.self, forPrimaryKey: productId)
    }
    
    /** 구독중인가?*/
    static var isSubscribe:Bool {
        let list = try! Realm().objects(InAppPurchaseModel.self)
        for model in list {
            if model.isExpire == false {
                return true
            }
        }
        return false
    }
    
}
