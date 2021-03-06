//
//  UIApplication+Extensions.swift
//  PixelArtMaker (iOS)
//
//  Created by Changyul Seo on 2022/03/24.
//

import Foundation
import UIKit
var rootViewController : UIViewController? {
    UIApplication.shared.keyWindow?.rootViewController
}

extension UIApplication {
    
    var keyWindow: UIWindow? {
        // Get connected scenes
        return UIApplication.shared.connectedScenes
            // Keep only active scenes, onscreen and visible to the user
            .filter { $0.activationState == .foregroundActive }
            // Keep only the first `UIWindowScene`
            .first(where: { $0 is UIWindowScene })
            // Get its associated windows
            .flatMap({ $0 as? UIWindowScene })?.windows
            // Finally, keep only the key window
            .first(where: \.isKeyWindow)
    }
    
    
    var statusFrame:CGRect {
        return keyWindow?.windowScene?.statusBarManager?.statusBarFrame ?? .zero
    }
    
    var safeAreaInsets:UIEdgeInsets {
        return keyWindow?.safeAreaInsets ?? .zero
    }
}
