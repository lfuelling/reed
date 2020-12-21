//
//  ArticleView.swift
//  reed
//
//  Created by Lukas Fülling on 21.12.20.
//

import Foundation
import SwiftUI

struct ArticleView: View {
    let article: Article

    var body: some View {
        VStack(alignment: .leading) {
            Text(article.title)
                .font(.headline)
            Text(article.date, style: .date)
            Text(article.content)
        }
    }
}
