//
//  DummyStores.swift
//  reed
//
//  Created by Lukas Fülling on 21.12.20.
//

import Foundation

let dummyChannelOne = Channel.init(title: "Some Author's Blog", description: "A simple blog.", link: "https://127.0.0.1/", image: ChannelImage.init(url: "http://127.0.0.1/favicon.ico", title: "Favicon", link: "http://127.0.0.1/"), generator: "Some Software", lastBuildDate: "Mon, 21 Dec 2020 00:01:01 GMT", ttl: 60, updateUri: "http://127.0.0.1/rss")

let dummyChannelTwo = Channel.init(title: "Some Other Author's Blog", description: "Another simple blog.", link: "https://127.0.1.1/", image: ChannelImage.init(url: "http://127.0.1.1/favicon.ico", title: "Favicon", link: "http://127.0.1.1/"), generator: "Some other Software", lastBuildDate: "Mon, 21 Dec 2020 00:01:01 GMT", ttl: 60, updateUri: "http://127.0.1.1/rss")

final class DummyArticleStore: ObservableObject {
    @Published var allArticles: [UUID: [Article]] = [
        dummyChannelOne.id: [Article.init(date: Date(), title: "Hello World!", description: "A simple Hello World article.", link: "http://127.0.0.1/hello", guid: "wertzuiuztrd", categories: ["Hello", "World"], author: "Some Author", content: "This is a simple hello world article. Hello world.", mediaUris: ["http://127.0.0.1/favicon.ico"], channelId: dummyChannelOne.id)],
        dummyChannelTwo.id: [Article.init(date: Date(), title: "Also Hello World!", description: "Another simple Hello World article.", link: "http://127.0.1.1/hello", guid: "wertauiuztrd", categories: ["Hello", "World"], author: "Some Author", content: "This is another simple hello world article. Hello world.", mediaUris: ["http://127.0.1.1/favicon.ico"], channelId: dummyChannelTwo.id)]
    ]
}

final class DummyChannelStore: ObservableObject {
    @Published var allChannels: [Channel] = [
        dummyChannelOne,
        dummyChannelTwo
    ]
    
    func getChannelById (id: UUID) -> Channel? {
        var channel: Channel? = nil
        allChannels.forEach { c in
            if(c.id == id) {
                channel = c
            }
        }
        return channel
    }
}
