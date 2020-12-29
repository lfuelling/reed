//
//  ArticleView.swift
//  reed
//
//  Created by Lukas Fülling on 21.12.20.
//

import Foundation
import SwiftUI
import WebKit

extension String {
    func replacingFirstOccurrence(of target: String, with replacement: String) -> String {
        guard let range = self.range(of: target) else { return self }
        return self.replacingCharacters(in: range, with: replacement)
    }
}

struct ArticleView: View {
    
    @AppStorage("fontSize") private var fontSize = 14.0
    
    let article: Article
    let channel: Channel

    private func getSubtitleString(article: Article, channel: Channel) -> String {
        if let channelTitle = channel.title {
            if let author = article.author {
                return author + " - " + channelTitle
            } else {
                return channelTitle
            }
        } else {
            if let safeLink = channel.link {
                return safeLink.absoluteString
            } else {
                return channel.updateUri!.absoluteString
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 4) {
                Text(article.title!)
                    .font(.headline)
                    .lineLimit(2)
                Text(getSubtitleString(article: article, channel: channel))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                if let date = article.date {
                    Text(date, style: .date)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }.padding(16)
            Divider()
            BrowserView(url: getDataUrl())
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
        var articleImage = ""
        if let safeImageUri = article.mediaUri {
            let httpsUriString = safeImageUri.absoluteString.replacingFirstOccurrence(of: "http://", with: "https://")
            articleImage += "<img style=\"margin-bottom: 8px;\" src=\"" + httpsUriString + "\" />"
        }
        let result = "<html><head><meta charset=\"UTF-8\"><meta name=\"viewport\" content=\"width=device-width\"/><style type=\"text/css\">" + css + "</style></head><body>" + articleImage + content + "</body></html>"
        let utf8str = result.data(using: .utf8)
        return "data:text/html;base64," + (utf8str?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0)))!
    }
}
