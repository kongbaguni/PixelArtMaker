//
//  StagePreviewModel.swift
//  PixelArtMaker (iOS)
//
//  Created by Changyul Seo on 2022/03/24.
//

import Foundation
import UIKit

struct StagePreviewModel : Hashable {
    public static func == (lhs: StagePreviewModel, rhs: StagePreviewModel) -> Bool {
        return lhs.documentId == rhs.documentId
    }

    let documentId:String
    let image:UIImage
    let updateDt:Date
}
