//
//  ArticleView.swift
//  reed
//
//  Created by Lukas Fülling on 21.12.20.
//

import Foundation
import SwiftUI
import WebKit

struct ArticleView: View {
    
    @AppStorage("fontSize") private var fontSize = 14.0
    
    private let article: Article
    private let channel: Channel?
    
    init(article: Article, persistenceProvider: PersistenceProvider) {
        if let channelId = article.channelId {
            self.article = article
            self.channel = persistenceProvider.channels.getById(id: channelId)
        } else {
            fatalError("channelId is nil")
        }
    }
    
    var body: some View {
        if let channelSave = channel {
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    Text(article.title!)
                        .font(.headline)
                        .lineLimit(2)
                    Text(channelSave.title!)
                        .font(.subheadline)
                    if let date = article.date {
                        Text(date, style: .date)
                    }
                }.padding(16)
                Divider()
                BrowserView(url: getDataUrl())
            }
        }
    }
    
    func getDataUrl() -> String {
        return _getDataUrl(content: (article.content ?? article.description))
    }
    
    private func _getDataUrl(content: String) -> String {
        let css = """
img {
    width: 100%;
    height: auto;
}
body,
html {
    font-family: sans-serif;
    width: 90%;
    overflow-x: hidden;
    font-size: \(fontSize)px
}
@media (prefers-color-scheme: dark) {
a {
    color: #fff;
    font-family: sans-serif;
}
html, body {
    background: rgb(34,33,35);
    color: #fff;
}
}
"""
        let result = "<html><head><meta charset=\"UTF-8\"><meta name=\"viewport\" content=\"width=device-width\"/><style type=\"text/css\">" + css + "</style></head><body>" + content + "</body></html>"
        let utf8str = result.data(using: .utf8)
        return "data:text/html;base64," + (utf8str?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0)))!
    }
}
