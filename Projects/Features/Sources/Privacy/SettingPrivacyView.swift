//
//  SettingPrivacyView.swift
//  Features
//
//  Created by 고도현 on 2023/08/12.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import SwiftUI
import PhotosUI

// FIXME: 폰트, 컬러(도형, 폰트) 추후에 한 번에 변경 예정
// FIXME: 텍스트도 Constants로 변경 예정
/// 회원가입 이후, 프로필 이미지와 닉네임을 등록하는 페이지입니다.
/// - 뷰의 상단부터 순차적으로 구현하였으며 각각의 컴포넌트별로 구분할 수 있게끔 주석을 달아놓았으니 참고하시면 됩니다.
struct SettingPrivacyView: View {
    // 닉네임 관련 프로퍼티
    @State private var nickname = "" // 사용자가 새롭게 입력한 닉네임
    @State private var beforeNickname = "" // 기존에 입력했던 닉네임
    @State private var isValidNickname = false // 사용 가능한 닉네임인지?
    @State private var isShake = false // 최대 글자 수를 넘긴 경우 좌, 우로 떨리는 애니메이션
    @State private var isToggle = false // 다음 페이지로 넘어가기
    
    // 프로필 이미지 관련 프로퍼티들
    @State private var selectedImage: PhotosPickerItem? = nil // 사용자 프로필 이미지
    @State private var selectedImageData: Data? = nil // Image -> Data
    
    var body: some View {
        VStack(spacing: 12) {
            // 프로필 이미지를 등록하는 Circle
            PhotosPicker(
                selection: $selectedImage,
                matching: .images,
                photoLibrary: . shared()) {
                    if let selectedImageData, let profileImage = UIImage(data: selectedImageData) {
                        Image(uiImage: profileImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 160, height: 160)
                            .clipShape(Circle())
                            .overlay(
                                ZStack {
                                    Circle()
                                        .foregroundColor(.gray)
                                        .frame(width: 50, height: 50)
                                    
                                    Image(systemName: "photo")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 33.3, height: 33.3)
                                        .foregroundColor(.white)
                                }
                                .offset(x: 50, y: 50)
                            )
                            .padding(32)
                    } else {
                        Circle()
                            .frame(width: 160, height: 160)
                            .foregroundColor(.gray)
                            .overlay(
                                Circle()
                                    .stroke(.white, lineWidth: 1)
                            )
                            .overlay(
                                ZStack {
                                    Circle()
                                        .foregroundColor(.gray)
                                        .frame(width: 50, height: 50)
                                    
                                    Image(systemName: "photo")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 33.3, height: 33.3)
                                        .foregroundColor(.white)
                                }
                                .offset(x: 50, y: 50)
                            )
                            .padding(32)
                    }
                }
            
                // Image -> Data
                .onChange(of: selectedImage) { newImage in
                    Task {
                        if let data = try await newImage?.loadTransferable(type: Data.self) {
                            selectedImageData = data
                        }
                    }
                }
            
            // 닉네임 관련 안내메세지
            HStack(alignment: .center, spacing: 4) {
                Text("닉네임")
                    .font(.system(size: 14))
                
                Text("(\(nickname.count)/6)")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                
                Spacer()
                
                Text("2~6자리 한글, 영어, 숫자")
                    .font(.system(size: 12))
            }
            .padding(.horizontal, 2)
            
            // 닉네임을 입력하는 TextField
            TextField("닉네임을 입력해주세요.", text: $nickname)
                .font(.system(size: 16))
                .frame(height: 50)
                .padding(.horizontal)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(.gray, lineWidth: 1)
                )
                .modifier(ShakeTextFieldWhenIsFulled(isShake: $isShake))
            
            if !nickname.isEmpty { // FIXME: API 연결
                ValidateNicknameView(isValid: $isValidNickname)
            }
            
            // 닉네임 관련 안내메세지
            Rectangle()
                .frame(height: 80)
                .foregroundColor(.gray)
                .cornerRadius(8)
                .overlay(
                    Text("친구들이 원할하게 문제를 풀 수 있도록, 나를 가장 잘 나타내는 닉네임으로 설정해주세요.")
                        .font(.system(size: 14))
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                )
            
            // 위쪽 정렬을 위한 Spacer
            Spacer()
            
            // 다음 페이지로 넘어가기 위한 Button
            // FIXME: API 연결
            Button(action: {}) {
                HStack {
                    Spacer()
                    
                    Text("다음")
                        .font(.system(size: 18))
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .frame(height: 60)
                    
                    Spacer()
                }
            }
            .background(isToggle ? .white : .gray)
            .cornerRadius(16)
            .disabled(isToggle ? false : true)
        }
        .padding(.horizontal, 16)
        
        // 사용자가 입력한 닉네임을 (클라이언트 단에서) 검증하는 부분
        .onChange(of: nickname) { newValue in
            if newValue.count >= 1, newValue.count <= 6 {
                isToggle = true
                isShake = false
                beforeNickname = newValue
            } else {
                isToggle = false
                
                if newValue.count > 6 {  // 최대 글자 수를 넘겼으므로 Shake Start
                    isShake = true
                    nickname = beforeNickname // 최대 글자 수를 넘기기 전에 입력한 닉네임으로 고정
                }
            }
        }
    }
}

// 닉네임에 대한 검증 여부를 보여주는 뷰
struct ValidateNicknameView: View {
    @Binding var isValid: Bool
    
    var body: some View {
        HStack {
            Image(systemName: isValid ? "checkmark.circle" : "xmark.circle")
                .foregroundColor(isValid ? .green : .red)
                .frame(width: 10, height: 10)
            
            Text(isValid ? "사용 가능한 닉네임입니다." : "중복된 닉네임입니다.")
                .font(.system(size: 12))
                .foregroundColor(.gray)
            
            Spacer()
        }
        .padding(8)
    }
}

struct SettingPrivacyView_Previews: PreviewProvider {
    static var previews: some View {
        SettingPrivacyView()
    }
}
