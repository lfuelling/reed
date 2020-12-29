//
//  ChannelView.swift
//  reed
//
//  Created by Lukas Fülling on 21.12.20.
//

import Foundation
import SwiftUI
import CoreData

extension String {
    func unhtml() -> String {
        let str = self.replacingOccurrences(of: "<style>[^>]+</style>", with: "", options: .regularExpression, range: nil)
        return str.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }
}

struct ChannelView: View {
    let articles: [Article]
    let channel: Channel
    @Binding var selectedArticle: Article?
    
    var body: some View {
        List(selection: $selectedArticle) {
            ForEach(articles) { article in
                HStack(alignment: .top) {
                    if !article.read {
                        Image(systemName: "circle.fill")
                            .foregroundColor(.accentColor)
                            .font(.footnote)
                    }
                    NavigationLink(
                        destination: ArticleView(article: article, channel: channel),
                        tag: article,
                        selection: $selectedArticle
                    ) {
                        VStack(alignment: .leading) {
                            HStack {
                                Text(article.title!)
                                    .font(.headline)
                                    .lineLimit(1)
                                if let date = article.date {
                                    Spacer()
                                    Text(date, style: .date)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            if let description = article.articleDescription {
                                Text(description.unhtml())
                                    .font(.callout)
                                    .lineLimit(3)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                Divider()
            }
        }.navigationTitle(channel.title ?? "untitled")
        .navigationSubtitle(channel.channelDescription ?? "")
    }
}
