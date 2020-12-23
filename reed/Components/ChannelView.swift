//
//  ChannelView.swift
//  reed
//
//  Created by Lukas Fülling on 21.12.20.
//

import Foundation
import SwiftUI
import CoreData

struct ChannelView: View {
    let articles: [Article]
    let channel: Channel
    @Binding var selectedArticle: Article?

    var body: some View {
        List(selection: $selectedArticle) {
            ForEach(articles) { article in
                NavigationLink(
                    destination: ArticleView(article: article, channel: channel),
                    tag: article,
                    selection: $selectedArticle
                ) {
                    VStack(alignment: .leading) {
                        Text(article.title!)
                            .font(.headline)
                            .lineLimit(3)
                        if let date = article.date {
                            Text(date, style: .date)
                        }
                    }
                }
            }
        }.navigationTitle(channel.title ?? "untitled")
        .navigationSubtitle(channel.channelDescription ?? "")
    }
}
