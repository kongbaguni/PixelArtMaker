//
//  AppGroup.swift
//  WidgetDemo
//
//  Created by Changyeol Seo on 2023/06/28.
//

import Foundation
import UIKit
import WidgetKit

struct AppGroup {    
    static var savedImage:UIImage? {
        if let appGroupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: CommonConst.AppGroupId) {
            let fileURL = appGroupURL.appendingPathComponent(CommonConst.lastMyPictureName)
            if let data = try? Data(contentsOf: fileURL) {
                return UIImage(data: data)
            }
        }
        return nil
    }
}
