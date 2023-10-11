//
//  DetailCharacterView.swift
//  KeymeUI
//
//  Created by Young Bin on 2023/07/27.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Domain
import SwiftUI

final class DetailCharacterViewOption {
    var backgroundColor: Color
    var textColor: Color
    var dateFormat: String
    
    init(
        backgroundColor: Color = .hex("232323"),
        textColor: Color = .white,
        dateFormat: String = "M월 dd일 HH:MM"
    ) {
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.dateFormat = dateFormat
    }
}

struct DetailCharacterView: View {
    private let formatter: DateFormatter
    
    let title: String
    let subtitle: String
    let backgroundColor: Color
    let textColor: Color
    let scores: [CharacterScore]
    
    init(
        title: String,
        subtitle: String,
        scores: [CharacterScore],
        option: DetailCharacterViewOption = .init()
    ) {
        self.title = title
        self.subtitle = subtitle
        self.backgroundColor = option.backgroundColor
        self.textColor = option.textColor
        
        self.formatter = DateFormatter()
        formatter.dateFormat = option.dateFormat
        
        self.scores = scores
    }
    
    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()
            
            VStack(alignment: .center) {
                ScrollView {
                    LazyVStack(alignment: .leading) {
                        Text(title)
                            .font(.title)
                        
                        Text(subtitle)
                            .font(.subheadline)
                        
                        ForEach(scores) { data in
                            CharacterScoreListElement(score: data.score, date: formatter.string(from: data.date))
                        }
                    }
                    .padding(.bottom, 100)
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .foregroundColor(textColor)
        }
        .zIndex(1)
    }
}

private extension DetailCharacterView {
    struct CharacterScoreListElement: View {
        let score: Int
        let date: String

        var body: some View {
            ZStack(alignment: .center) {
                HStack {
                    Text("\(score)점")
                        .font(.headline)
                }
                
                HStack {
                    Spacer()
                    
                    Text(date)
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
            }
            .frame(height: 53)
            .background(.gray.opacity(0.2))
            .cornerRadius(12)
        }
    }
}

struct DetailCharacterView_Previews: PreviewProvider {
    static var previews: some View {
        let scores = [
            CharacterScore(score: 4, date: Date().toString()),
            CharacterScore(score: 5, date: Date().toString()),
            CharacterScore(score: 3, date: Date().toString()),
            CharacterScore(score: 1, date: Date().toString()),
            CharacterScore(score: 2, date: Date().toString())
        ]
        
        DetailCharacterView(title: "키미님의 애정도", subtitle: "서브타이틀", scores: scores)
    }
}
