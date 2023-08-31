//
//  RegistrationView.swift
//  Features
//
//  Created by 고도현 on 2023/08/12.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Core
import DSKit
import SwiftUI
import PhotosUI

import ComposableArchitecture

/// 회원가입 이후, 프로필 이미지와 닉네임을 등록하는 페이지입니다.
/// - 뷰의 상단부터 순차적으로 구현하였으며 각각의 컴포넌트별로 구분할 수 있게끔 주석을 달아놓았으니 참고하시면 됩니다.
public struct RegistrationView: View {
    private let store: StoreOf<RegistrationFeature>
    
    public init(store: StoreOf<RegistrationFeature>) {
        self.store = store
    }
    
    // 닉네임 관련 프로퍼티
    @FocusState private var isTextFieldFocused: Bool
    @State private var nickname = "" // 사용자가 새롭게 입력한 닉네임
    @State private var beforeNickname = "" // 기존에 입력했던 닉네임
    @State private var isShake = false // 최대 글자 수를 넘긴 경우 좌, 우로 떨리는 애니메이션
    
    // 프로필 이미지 관련 프로퍼티들
    @State private var selectedImage: PhotosPickerItem?
    @State private var selectedImageData: Data?
    
    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: 0) {
                Text.keyme("회원가입", font: .body3Semibold)
                    .foregroundColor(.white)
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                
                // 프로필 이미지를 등록하는 Circle
                PhotosPicker(selection: $selectedImage, matching: .images, photoLibrary: .shared()) {
                    profileImage(imageData: selectedImageData)
                }
                .onChange(of: selectedImage) { newImage in
                    Task(priority: .utility) {
                        guard let imageData = try await newImage?.loadTransferable(type: Data.self) else {
                            // TODO: Throw error and show alert
                            return
                        }
                        
                        viewStore.send(.registerProfileImage(imageData))
                        DispatchQueue.main.async { selectedImageData = imageData }
                    }
                }
                
                Spacer().frame(height: 59)
                
                HStack(alignment: .center, spacing: 4) {
                    Text.keyme("닉네임", font: .body3Regular)
                        .foregroundColor(.white)
                    
                    Text.keyme("(\(nickname.count)/6)", font: .caption1)
                        .foregroundColor(DSKitAsset.Color.keymeMediumgray.swiftUIColor)
                    
                    Spacer()
                    
                    Text.keyme("2~6자리 한글, 영어, 숫자", font: .caption1)
                        .foregroundColor(.white)
                }
                
                Spacer().frame(height: 12)
                
                // 닉네임을 입력하는 TextField
                TextField("Nickname", text: $nickname)
                    .focused($isTextFieldFocused)
                    .placeholder(when: nickname.isEmpty, placeholder: {
                        Text.keyme("닉네임을 입력해주세요.", font: .body3Regular)
                            .foregroundColor(.white.opacity(0.4))
                    })
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .frame(height: 50)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(.white.opacity(0.3), lineWidth: 1)
                    )
                    .background(.black.opacity(0.4))
                    .modifier(Shake(isShake: $isShake))
                
                if
                    !nickname.isEmpty,
                    let isValid = viewStore.state.isNicknameAvailable
                {
                    ValidateNicknameView(isValid: isValid)
                        .padding(.top, 12)
                }
                
                Spacer(minLength: 50)
                
                // 닉네임 관련 안내메세지
                Rectangle()
                    .frame(height: 80)
                    .foregroundColor(
                        DSKitAsset.Color.keymeBlack.swiftUIColor.opacity(0.8))
                    .cornerRadius(8)
                    .overlay(
                        Text.keyme("친구들이 원활하게 문제를 풀 수 있도록, 나를 가장 잘 나타내는 닉네임으로 설정해주세요.", font: .body4)
                            .lineSpacing(10)
                            .foregroundColor(.white)
                    )
                    .padding(.vertical, 24)

                // 다음 페이지로 넘어가기 위한 Button
                Button(action: {
                    viewStore.send(
                        .finishRegister(
                            nickname: viewStore.nicknameTextFieldString,
                            thumbnailURL: viewStore.thumbnailURL,
                            originalImageURL: viewStore.originalImageURL))
                }) {
                    HStack {
                        Spacer()
                        
                        Text("다음")
                            .font(.system(size: 18))
                            .fontWeight(.bold)
                            .frame(height: 60)
                        
                        Spacer()
                    }
                }
                .foregroundColor(.white)
                .background(viewStore.state.canRegister ? .black : .white.opacity(0.3))
                .cornerRadius(16)
                .padding(.bottom, 20)
                .disabled(viewStore.state.canRegister ? false : true)
            }
            .onTapGesture {
                isTextFieldFocused = false
            }
            .padding(.horizontal, 16)
            .onChange(of: nickname) { newValue in
                guard 1 <= newValue.count, newValue.count <= 6 else {
                    if newValue.count > 6 {  // 최대 글자 수를 넘겼으므로 Shake Start
                        isShake = true
                        nickname = beforeNickname // 최대 글자 수를 넘기기 전에 입력한 닉네임으로 고정
                    }
                    
                    return
                }
                
                isShake = false
                beforeNickname = newValue
                
                viewStore.send(.debouncedNicknameUpdate(text: newValue))
            }
            .fullFrame()
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
    }
}

// 닉네임에 대한 검증 여부를 보여주는 뷰
extension RegistrationView {
    func profileImage(imageData: Data?) -> some View {
        let outercircleSize = 160.0
        let iconSize = 33.3
        
        return ZStack(alignment: .center) {
            Circle()
                .foregroundColor(.white.opacity(0.15))
                .overlay(Circle().stroke(.white.opacity(0.30), lineWidth: 1))
                .frame(width: outercircleSize, height: outercircleSize)
            
            Group {
                if
                    let selectedImageData = imageData,
                    let profileImage = UIImage(data: selectedImageData)
                {
                    Image(uiImage: profileImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: outercircleSize - 20, height: outercircleSize - 20)
                } else {
                    ZStack {
                        Circle()
                            .foregroundColor(.black.opacity(0.8))
                            .frame(width: outercircleSize - 20, height: outercircleSize - 20)
                        
                        Image(systemName: "photo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: iconSize, height: iconSize)
                            .foregroundColor(.white)
                    }
                }
            }
            .clipShape(Circle())
        }
    }
    
    struct ValidateNicknameView: View {
        let isValid: Bool
        
        var body: some View {
            HStack {
                Image(systemName: isValid ? "checkmark.circle" : "xmark.circle")
                    .foregroundColor(isValid ? .green : .red)
                    .frame(width: 10, height: 10)
                
                Text.keyme(isValid ? "사용 가능한 닉네임입니다." : "중복된 닉네임입니다.", font: .caption1)
                    .foregroundColor(.gray)
                
                Spacer()
            }
            .padding(8)
        }
    }
}

struct RegistrationView_preview: PreviewProvider {
    static var previews: some View {
        RegistrationView(store: Store(initialState: RegistrationFeature.State(), reducer: {
            RegistrationFeature()
        }))
    }
}
