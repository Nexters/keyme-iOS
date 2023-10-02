//
//  OnboardingGuideView.swift
//  Features
//
//  Created by 이영빈 on 10/2/23.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Core
import ComposableArchitecture
import DSKit
import SwiftUI

public struct OnboardingGuideFeature: Reducer {
    public struct State: Equatable {}
    public enum Action: Equatable {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            return .none
        }
    }
}

struct OnboardingGuideView: View {
    @State private var currentTabIndex = 0
    
    private let store: StoreOf<OnboardingGuideFeature>
    private let images: [GuideImage] = [
        GuideImage(image: DSKitAsset.Image.Guide.first.swiftUIImage),
        GuideImage(image: DSKitAsset.Image.Guide.second.swiftUIImage),
        GuideImage(image: DSKitAsset.Image.Guide.third.swiftUIImage),
        GuideImage(image: DSKitAsset.Image.Guide.fourth.swiftUIImage),
        GuideImage(image: DSKitAsset.Image.Guide.fifth.swiftUIImage)
    ]
    
    init(store: StoreOf<OnboardingGuideFeature>) {
        self.store = store
    }
    
    var body: some View {
        VStack {
            Group {
                if !isLastPage {
                    topBar {
                        
                    }
                } else {
                    EmptyView()
                }
            }
            .transition(.opacity)
            .padding(.horizontal, 16)
            .padding(.top, 30)
            
            Spacer()
            
            TabView(selection: $currentTabIndex) {
                ForEach(0..<images.count, id: \.self) { index in
                    let guideImage = images[index]
                    
                    guideImage.image
                        .modifyForGuideView()
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            
            Group {
                if isLastPage {
                    Button(action: {
                        HapticManager.shared.boong()
                    }) {
                        HStack {
                            Spacer()
                            Text.keyme("시작해볼까요?", font: .body2).frame(height: 60)
                            Spacer()
                        }
                    }
                    .foregroundColor(.black)
                    .background(.white)
                    .cornerRadius(16)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                } else {
                    Spacer().frame(height: 60)
                }
            }
            .transition(.opacity)
        }
        .background(DSKitAsset.Color.keymeBlack.swiftUIColor)
        .animation(Animation.customInteractiveSpring(), value: currentTabIndex)
    }
    
    private func topBar(action: @escaping () -> Void) -> some View {
        HStack {
            Button(action: { }) {
                Text.keyme("건너뛰기", font: .body4)
            }
            
            Spacer()
            
            Button(action: {
                print(images.endIndex)
                guard !isLastPage else {
                    return
                }
                
                currentTabIndex += 1
            }) {
                Text.keyme("다음 >", font: .body4)
            }
        }
        .foregroundStyle(.white)
    }
}

private extension OnboardingGuideView {
    var isLastPage: Bool {
        currentTabIndex == images.endIndex - 1
    }
    
    struct GuideImage: Identifiable {
        let id = UUID()
        let image: Image
    }
}

fileprivate extension Image {
    func modifyForGuideView() -> some View {
        self
            .resizable()
            .frame(maxWidth: .infinity)
            .scaledToFit()
    }
}
