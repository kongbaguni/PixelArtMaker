//
//  Realm.Object+Extensions.swift
//  LivePixel
//
//  Created by Changyeol Seo on 2023/08/24.
//

import Foundation
import RealmSwift

extension Object {
    var dictionmaryValue:[String:Any] {
        var dictionary: [String: Any] = [:]
        for property in objectSchema.properties {
            let value = self[property.name]
            if let obj = value as? Object {
                dictionary[property.name] = obj.dictionmaryValue
            }
            else if let date = value as? Date {
                dictionary[property.name] = date.timeIntervalSince1970
            }
            else {
                dictionary[property.name] = value
            }
        }
        return dictionary
    }
    
    var stringValue:String? {
        do {
            // 딕셔너리를 Data로 변환
            let jsonData = try JSONSerialization.data(withJSONObject: dictionmaryValue, options: [])

            // 변환된 Data를 출력
            print("Data: \(jsonData)")
            
            // Data를 String으로 변환하여 출력 (옵션)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("JSON 문자열: \(jsonString)")
                return jsonString
            } else {
                print("유효한 문자열로 변환할 수 없는 데이터입니다.")
            }
        } catch {
            print("JSON 데이터를 변환하는 동안 에러가 발생했습니다: \(error.localizedDescription)")
        }
        return nil
    }
}
