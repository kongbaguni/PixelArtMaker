//
//  TempModel.swift
//  PixelArtMaker (iOS)
//
//  Created by Changyul Seo on 2022/04/09.
//

import RealmSwift

class TempModel : Object {
    @Persisted(primaryKey: true) var uid:String = ""
    @Persisted var data:String = ""
    @Persisted var documentId:String = ""
}
