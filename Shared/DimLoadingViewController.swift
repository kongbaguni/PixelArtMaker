//
//  DimLoadingViewController.swift
//  PixelArtMaker (iOS)
//
//  Created by 서창열 on 2022/04/12.
//

import Foundation
import UIKit
import Reachability

class DimLoadingViewController : UIViewController {

    let indicator = UIActivityIndicatorView(frame: UIScreen.main.bounds)
    let reachability = try? Reachability()
    var isInternetConnected:Bool? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .init(white: 0, alpha: 0.8)
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overCurrentContext
        indicator.style = .large
        indicator.frame.origin = .zero
        indicator.frame.size = view.frame.size
        indicator.color = .white
        view.addSubview(indicator)
        do {
            if let reachability = reachability {
                reachability.whenReachable = { [weak self] _ in
                    self?.isInternetConnected = true
                }
                reachability.whenUnreachable = { [weak self] _ in
                    self?.isInternetConnected = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5)) {
                        if self?.isInternetConnected == false {
                            self?.dismiss(animated: true)
                        }
                    }
                }
            }
            try reachability?.startNotifier()
        } catch {
            
        }
        
    }
    
    deinit {
        reachability?.stopNotifier()
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
