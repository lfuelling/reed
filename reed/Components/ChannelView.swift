//
//  ChannelView.swift
//  reed
//
//  Created by Lukas Fülling on 21.12.20.
//

import Foundation
import SwiftUI

struct ChannelView: View {
    let title: String
    let articles: [Article]
    @Binding var selectedArticle: Article?

    var body: some View {
        List(selection: $selectedArticle) {
            ForEach(articles) { article in
                NavigationLink(
                    destination: ArticleView(article: article),
                    tag: article,
                    selection: $selectedArticle
                ) {
                    VStack(alignment: .leading) {
                        Text(article.title)
                        Text(article.date, style: .date)
                    }
                }
            }
        }.navigationTitle(title)
    }
}
