//
//  Realm+Extensions.swift
//  LivePixel
//
//  Created by Changyeol Seo on 2023/08/24.
//

import Foundation
import RealmSwift

extension Realm {
    static var shared:Realm {
        do {
            let config = Realm.Configuration(schemaVersion:11) { migration, oldSchemaVersion in
                
            }
            Realm.Configuration.defaultConfiguration = config
            return try Realm(configuration: config)
        } catch {
            print(error.localizedDescription)
            abort()
        }
    }
}
