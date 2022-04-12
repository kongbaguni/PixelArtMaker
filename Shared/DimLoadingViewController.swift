//
//  DimLoadingViewController.swift
//  PixelArtMaker (iOS)
//
//  Created by 서창열 on 2022/04/12.
//

import Foundation
import UIKit

class DimLoadingViewController : UIViewController {

    let indicator = UIActivityIndicatorView(frame: UIScreen.main.bounds)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .init(white: 0, alpha: 0.8)
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overCurrentContext
        indicator.style = .large
        view.addSubview(indicator)
    }
    
    func show() {
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overCurrentContext
        UIApplication.shared.keyWindow?.rootViewController?.present(self, animated: true)
        indicator.startAnimating()
    }
    
    func hide() {
        indicator.stopAnimating()
        dismiss(animated: true)
    }
}
