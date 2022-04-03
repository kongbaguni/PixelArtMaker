//
//  Share.swift
//  PixelArtMaker (iOS)
//
//  Created by Changyul Seo on 2022/04/03.
//

import SwiftUI

@discardableResult
func share(
    items: [Any],
    excludedActivityTypes: [UIActivity.ActivityType] = [
        .postToTwitter,
        .postToFlickr,
        .postToFacebook,
        .assignToContact,
        .addToReadingList
    ]
) -> Bool {
    guard let source = rootViewController else {
        return false
    }
    let vc = UIActivityViewController(
        activityItems: items,
        applicationActivities: nil
    )
    
    vc.excludedActivityTypes = excludedActivityTypes
    vc.popoverPresentationController?.sourceView = source.view
    source.present(vc, animated: true)
    return true
}
