//
//  OnboardingResultView.swift
//  Features
//
//  Created by 고도현 on 2023/08/18.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import SwiftUI

struct OnboardingResultView: View {
    let datas = [1..<10]
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            HStack { // X 버튼
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "xmark")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                
                .frame(width: 16, height: 16)
                .foregroundColor(.white)
            }
            
            Spacer()
            
            HStack { // 결과 확인 텍스트 및 버튼
                Text("결과 확인")
                    .font(.system(size: 24))
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: {}) {
                    Circle()
                        .foregroundColor(.gray)
                        .frame(width: 30, height: 30)
                        .overlay(
                            Image(systemName: "photo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.white)
                                .frame(width: 20, height: 20)
                        )
                }
                
                Button(action: {}) {
                    Circle()
                        .foregroundColor(.gray)
                        .frame(width: 30, height: 30)
                        .overlay(
                            Image(systemName: "square.and.arrow.up")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.white)
                                .frame(width: 20, height: 20)
                        )
                }
            }
            
            Spacer()
            
            // CarouselView
            KeymeCarouselView(pageCount: 3,
                              visibleEdgeSpace: 0,
                              spacing: 8) { index in
                KeymeCardView(index: index)
            }
            
            Spacer()
            
            // TODO: Indicator 추가
            
            // 친구에게 공유하기 버튼
            Button(action: {}) {
                Text("친구에게 공유하기")
                    .font(.system(size: 18)) // FIXME: font system으로 변경
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(.white)
            .frame(width: 343, height: 60)
            .cornerRadius(16)
            .padding(.horizontal, 12)
        }
        .padding()
    }
}

struct OnboardingResultView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingResultView()
    }
}
