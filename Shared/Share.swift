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
    guard let source = UIApplication.shared.lastViewController else {
        return false
    }
    let vc = UIActivityViewController(
        activityItems: items,
        applicationActivities: nil
    )
    vc.modalTransitionStyle = .coverVertical
    vc.excludedActivityTypes = excludedActivityTypes
    vc.popoverPresentationController?.sourceView = source.view
    let r = source.view.bounds
    vc.popoverPresentationController?.sourceRect = .init(x: 0, y: r.height - 100, width: r.width, height: 50)
    vc.popoverPresentationController?.permittedArrowDirections = .any
    source.present(vc, animated: true)
    return true
}
