//
//  NetworkService.swift
//  RunloopTest
//
//  Created by Dmitry Kanivets on 10.06.18.
//  Copyright © 2018 Dmitry Kanivets. All rights reserved.
//

import Foundation
import Alamofire
import ReactiveSwift
import Result
import SWXMLHash

enum NetworkService {
    private static let baseURL = "http://feeds.reuters.com/reuters/"
    
    case
    business,
    environment,
    entertainment
    
    var path : (Alamofire.HTTPMethod, String) {
        switch self {
        case .business:      return (.get, "businessNews")
        case .entertainment: return (.get, "entertainment")
        case .environment:   return (.get, "environment")
        }
    }
    
    fileprivate func dataSignalProducer() -> SignalProducer<(response: HTTPURLResponse, data: Data), NSError> {
            let (responseProducerSignal, observerResponse) = SignalProducer<(response: HTTPURLResponse, data: Data), NSError>.ProducedSignal.pipe()
            let responseProducer = SignalProducer(responseProducerSignal)
            
            let alamofireRequest = Alamofire.request(NetworkService.baseURL + self.path.1, method: self.path.0, parameters: nil)
            
            alamofireRequest.responseString { response in
                print("REQUEST: \(response.request.debugDescription)")
                print("RESPONSE: \(response.result.debugDescription)")
                DispatchQueue.main.async {
                    if response.response?.statusCode != 200 {
                        observerResponse.send(error: NSError(domain: "Error 200", code: 200, userInfo: nil))
                    } else if let alamofireError = response.result.error {
                        observerResponse.send(error: alamofireError as NSError)
                    } else if let data = response.data, let res = response.response {
                        observerResponse.send(value: (response: res, data: data))
                        observerResponse.sendCompleted()
                    }
                }
            }
            
            return responseProducer
    }
    
    func xmlSignalProducer() -> SignalProducer<XMLIndexer, NSError> {
        return self.dataSignalProducer()
            .flatMap(FlattenStrategy.merge) { (response: HTTPURLResponse, data: Data) in
                return self.serializedXMLProducer(data)
            }
            .on (failed: {
                print("---ERROR---\n\($0)\n-----------")
            }
        )
    }
    
    fileprivate func serializedXMLProducer(_ data: Data) -> SignalProducer<XMLIndexer, NSError> {
        return SignalProducer { observer, _ in
                let xml = SWXMLHash.parse(data)
                
                observer.send(value: xml)
                observer.sendCompleted()
        }
    }
}
