//
//  DimLoadingViewController.swift
//  PixelArtMaker (iOS)
//
//  Created by 서창열 on 2022/04/12.
//

import Foundation
import UIKit
import Network

class DimLoadingViewController : UIViewController {

    let monitor = NWPathMonitor()
    
    let indicator = UIActivityIndicatorView(frame: UIScreen.main.bounds)
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
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isInternetConnected = path.status == .satisfied
            if self?.isInternetConnected == false {
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5)) {
                    self?.dismiss(animated: true)
                }
            }
        }
        monitor.start(queue: DispatchQueue(label: "NetworkMonitor"))

    }
    deinit {
        monitor.cancel()
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
