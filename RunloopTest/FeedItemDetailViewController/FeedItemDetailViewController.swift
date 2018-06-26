//
//  FeedItemDetailViewController.swift
//  RunloopTest
//
//  Created by Dmitry Kanivets on 6/26/18.
//  Copyright © 2018 Dmitry Kanivets. All rights reserved.
//

import UIKit

class FeedItemDetailViewController: UIViewController {
    @IBOutlet weak var textView: UITextView!
    var feedItem: FeedItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
    }

    fileprivate func setupUI() {
        textView.text = feedItem?.descriptionText
        title = feedItem?.title
    }
}
