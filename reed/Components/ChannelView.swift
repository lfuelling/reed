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
    let persistenceProvider: PersistenceProvider
    @Binding var selectedArticle: Article?

    var body: some View {
        List(selection: $selectedArticle) {
            ForEach(articles) { article in
                NavigationLink(
                    destination: ArticleView(article: article, persistenceProvider: persistenceProvider),
                    tag: article,
                    selection: $selectedArticle
                ) {
                    VStack(alignment: .leading) {
                        Text(article.title!)
                            .font(.headline)
                        if let date = article.date {
                            Text(date, style: .date)
                        }
                    }
                }
            }
        }.navigationTitle(channel.title ?? "untitled")
    }
}
