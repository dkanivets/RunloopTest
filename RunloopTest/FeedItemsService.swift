//
//  FeedItemsService.swift
//  RunloopTest
//
//  Created by Dmitry Kanivets on 25.06.18.
//  Copyright © 2018 Dmitry Kanivets. All rights reserved.
//

import Foundation
import ReactiveSwift
import SWXMLHash

struct FeedItemsService {
    
    static func pullBusinessFeed() -> SignalProducer<[FeedItem], NSError> {
        return NetworkService.business.xmlSignalProducer()
        .flatMap(.concat, {xml -> SignalProducer<[FeedItem], NSError> in
           
            guard let itemsArray = try? xml["rss"]["channel"].byKey("item").all, let result = itemsArray.failableMap({$0.xmlToFeedItem()})
            else  {
                return SignalProducer(error: NSError(domain: "Response can't be parsed", code: 100, userInfo: nil))
            }
            return SignalProducer(value: result)
        })
    }

    static func pullEntertainmentAndEnvironment() -> SignalProducer<[FeedItem], NSError> {
        var arrayOfSignalProducers: [SignalProducer<XMLIndexer, NSError>] = []
        arrayOfSignalProducers.append(NetworkService.entertainment.xmlSignalProducer())
        arrayOfSignalProducers.append(NetworkService.environment.xmlSignalProducer())
        
        return SignalProducer(arrayOfSignalProducers).flatten(.merge).collect().flatMap(FlattenStrategy.concat, { value -> SignalProducer<[FeedItem], NSError> in
            var result: [FeedItem] = []
            
            for xml in value {
                guard let itemsArray = try? xml["rss"]["channel"].byKey("item").all, let xmlResult = itemsArray.failableMap({$0.xmlToFeedItem()})
                    else  {
                        return SignalProducer(error: NSError(domain: "Response can't be parsed", code: 100, userInfo: nil))
                }
                result.append(contentsOf: xmlResult)
            }
            return SignalProducer(value: result)
        })
    }
    
}

extension XMLIndexer {
    
    func xmlToFeedItem() -> FeedItem? {
        guard let title = self["title"].element?.description,
        let descriptionText = self["description"].element?.description,
        let link = self["link"].element?.description,
        let pubDate = self["title"].element?.description
        else { return nil }
        return FeedItem(title: title, descriptionText: descriptionText, link: link, pubDate: pubDate)
    }

}
