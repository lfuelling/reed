//
//  FeedUtils.swift
//  reed
//
//  Created by Lukas Fülling on 01.01.21.
//

import Foundation
import FeedKit

class FeedUtils {
    
    let persistenceProvider: PersistenceProvider
    
    init(persistenceProvider: PersistenceProvider) {
        self.persistenceProvider = persistenceProvider
    }
    
    func fetchAndPersistFeed(feedUrl: URL, callback: @escaping () -> Void) {
        
        let parser = FeedParser(URL: feedUrl)
        
        // Parse asynchronously, not to block the UI.
        parser.parseAsync(queue: DispatchQueue.global(qos: .userInitiated)) {(result) in
            
            switch result {
            case .success(let feed):
                var rssFeed: RSSFeed? = nil
                switch feed {
                case .rss(let feed):
                    rssFeed = feed
                    break
                default:
                    print("Currently only RSS is supported!")
                    break
                }
                
                DispatchQueue.main.async {
                    var called = false
                    self.persistenceProvider.save(callback: {() -> Void in
                        if let safeFeed = rssFeed {
                            self.persistenceProvider.persistFeed(feed: safeFeed, feedUrl: feedUrl)
                            self.persistenceProvider.save {
                                if !called {
                                    callback()
                                    called = true
                                }
                            }
                        }
                        if !called {
                            callback()
                        }
                    })
                }
                
            case .failure(let error):
                print("Error parsing feed!")
                print(error)
            }
        }
    }
}
