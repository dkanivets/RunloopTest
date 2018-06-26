//
//  ViewController.swift
//  RunloopTest
//
//  Created by Dmitry Kanivets on 6/25/18.
//  Copyright © 2018 Dmitry Kanivets. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa

class InitialViewController: UIViewController {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var rssLabel: UILabel!
    var timer: Timer?
    let formatter: DateFormatter = {
        let tmpFormatter = DateFormatter()
        tmpFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        return tmpFormatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setTime()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(setTime), userInfo: nil, repeats: true)
        nameLabel.text = "Dmitry"

        if let tabBarViewControllers = self.tabBarController?.viewControllers, let navigationControllerControllers = (tabBarViewControllers[1] as? UINavigationController)?.viewControllers, let feedItemsVC = navigationControllerControllers.first as? FeedsTableViewController {
            feedItemsVC.viewModel.selectedFeed.signal.observeValues({ [weak self] value in
                if let title = value?.title {
                    self?.rssLabel.text = title
                }
            })
        }
    }
    
    deinit {
        timer?.invalidate()
    }
    
    @objc func setTime() {
        dateLabel.text = formatter.string(from: Date())
    }

}

