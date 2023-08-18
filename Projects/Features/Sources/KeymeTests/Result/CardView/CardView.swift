//
//  CardView.swift
//  Features
//
//  Created by 고도현 on 2023/08/18.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import SwiftUI

// CarouselView의 카드 한 장에 해당하는 뷰
struct CardView: View {
    let index: Int
    let minCircleRadius: CGFloat = 210
    
    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            Spacer()
            
            VStack(alignment: .leading, spacing: 8) {
                Text("표현력")
                    .font(.system(size: 14)) // FIXME: font system으로 변경
                    .foregroundColor(.gray)
                
                Text("키미미미미미님의 애정표현 정도는?")
                    .font(.system(size: 24)) // FIXME: font system으로 변경
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                
                Rectangle()
                    .frame(height: 0.3)
                    .foregroundColor(.hex("#FFFFFF"))
                
                HStack {
                    Text("04")
                        .font(.system(size: 32))
                        .fontWeight(.bold)
                    
                    Text("점")
                        .font(.system(size: 12))
                    
                    Spacer()
                }
            }
            .frame(width: 256)
            
            Spacer()
            
            HStack {
                Spacer()
                
                ZStack(alignment: .center) {
                    Circle() // 큰 원
                        .frame(width: 280, height: 280)
                        .foregroundColor(.hex("#3A3A3A"))
                        .overlay( // 큰 원의 테두리
                            Circle()
                                .stroke(
                                    Color.hex("#3A3A3A"),
                                    lineWidth: 1
                                )
                        )
                    
                    Circle() // 작은 원
                        .frame(width: minCircleRadius, height: minCircleRadius)
                        .foregroundColor(.mint)
                }
                
                Spacer()
            }
            
            Spacer()
        }
        .padding() // MARGIN
        .frame(width: 341, height: 491)
        .background(Color.hex("#232323"))
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    Color.hex("#3A3A3A"),
                    lineWidth: 1
                )
        )
    }
}

struct KeymeCardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(index: 0)
    }
}
