//
//  widgetBundle.swift
//  widget
//
//  Created by Changyeol Seo on 2023/06/29.
//

import WidgetKit
import SwiftUI

@main
struct widgetBundle: WidgetBundle {
    var body: some Widget {
        widget()
        if #available(iOS 16.2, *) {
            widgetLiveActivity()
        }
        
    }
}
