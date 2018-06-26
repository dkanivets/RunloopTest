//
//  FeedsViewModel.swift
//  RunloopTest
//
//  Created by Dmitry Kanivets on 26.06.18.
//  Copyright © 2018 Dmitry Kanivets. All rights reserved.
//

import Foundation
import ReactiveSwift

protocol FeedsViewModelProtocol {
    var updateItemsAction: Action<FeedType, [FeedItem], NSError> { get }
    var items: [FeedItem] { get set }
    var selectedFeed: MutableProperty<FeedItem?> { get set }
    var selectedFeedType: FeedType { get set }
}

class FeedsViewModel: FeedsViewModelProtocol {
    var selectedFeedType: FeedType = .business
    lazy var updateItemsAction = FeedItemsService.pullFeedAction
    var items: [FeedItem] = []
    var selectedFeed: MutableProperty<FeedItem?> = MutableProperty(nil)
}
