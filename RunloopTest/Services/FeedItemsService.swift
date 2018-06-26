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

enum FeedType: Int {
    case business = 0, entertainmentEnvironment = 1
}

struct FeedItemsService {
    
    static var pullFeedAction: Action<FeedType, [FeedItem], NSError> = Action { feedType in
        switch feedType {
        case .business:
            return FeedItemsService.pullBusinessFeed()
        case .entertainmentEnvironment:
            return FeedItemsService.pullEntertainmentAndEnvironmentFeed()
        }
    }
    
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

    static func pullEntertainmentAndEnvironmentFeed() -> SignalProducer<[FeedItem], NSError> {
        var arrayOfSignalProducers: [SignalProducer<XMLIndexer, NSError>] = []
        arrayOfSignalProducers.append(NetworkService.entertainment.xmlSignalProducer())
        arrayOfSignalProducers.append(NetworkService.environment.xmlSignalProducer())
        
        return SignalProducer(arrayOfSignalProducers).flatten(.merge).collect().flatMap(FlattenStrategy.concat, { xmls -> SignalProducer<[FeedItem], NSError> in
            var result: [FeedItem] = []
            
            for xml in xmls {
                guard let itemsArray = try? xml["rss"]["channel"].byKey("item").all, let xmlResult = itemsArray.failableMap({$0.xmlToFeedItem()})
                    else  {
                        return SignalProducer(error: NSError(domain: "Response can't be parsed", code: 100, userInfo: nil))
                }
                result.append(contentsOf: xmlResult)
            }
            // FIXME: workaround to keep order of topics, should be done with correct producers concat
            return SignalProducer(value: result.sorted(by: {$0.category > $1.category}))
        })
    }
    
}

private extension XMLIndexer {
    
    func xmlToFeedItem() -> FeedItem? {
        guard let title = self["title"].element?.innerXML,
        let descriptionText = self["description"].element?.children.first?.description,
        let link = self["link"].element?.innerXML,
        let pubDate = self["title"].element?.innerXML,
        let category = self["category"].element?.innerXML
        else { return nil }
        return FeedItem(title: title, descriptionText: descriptionText, link: link, pubDate: pubDate, category: category)
    }

}
