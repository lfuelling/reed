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
    @State var articles: [Article]
    @State var channel: Channel
    @Binding var updater: Bool
    let persistenceProvider: PersistenceProvider
    let refreshData: () -> Void
    
    @Binding var selectedArticle: Article?
    
    @AppStorage("descriptionMaxLines") private var descriptionMaxLines = 3.0
    
    var body: some View {
        if articles.count > 0 {
            List(articles, id: \.self.id, selection: $selectedArticle) { article in
                VStack(alignment: .leading) {
                    HStack(alignment: .center) {
                        VStack(alignment: .leading) {
                            if !article.read {
                                Image(systemName: "circle.fill")
                                    .foregroundColor(.accentColor)
                                    .font(.footnote)
                            } else {
                                if article.bookmarked {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                        .font(.footnote)
                                } else {
                                    Image(systemName: "circle.fill")
                                        .foregroundColor(.accentColor)
                                        .font(.footnote)
                                        .opacity(0.0)
                                }
                            }
                        }
                        NavigationLink(
                            destination: ArticleView(article: article, channel: channel, persistenceProvider: persistenceProvider, refreshData: refreshData, updater: $updater),
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
                                        .lineLimit(Int(descriptionMaxLines))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }.padding(4)
                    if(selectedArticle?.id != article.id) {
                        Divider()
                    } else {
                        Divider().opacity(0)
                    }
                }.padding(0)
            }.navigationTitle(channel.title ?? "untitled")
            .navigationSubtitle(channel.channelDescription ?? "")
        } else {
            Text("No articles...")
                .navigationTitle(channel.title ?? "untitled")
                .navigationSubtitle(channel.channelDescription ?? "")
        }
    }
}
