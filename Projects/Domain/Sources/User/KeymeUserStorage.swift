//
//  KeymeUserStorage.swift
//  Domain
//
//  Created by 이영빈 on 2023/08/21.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import ComposableArchitecture
import Foundation
protocol StorageKeyType {
    var name: String { get }
}

public final class KeymeUserStorage {
    @Dependency(\.localStorage) private var localStorage

    private func get(_ key: UserStorageKey) -> Any? {
        localStorage.get(key)
    }
    
    private func set(_ value: Any?, forKey key: UserStorageKey) {
        localStorage.set(value, forKey: key)
    }
    
    private enum UserStorageKey: String, StorageKeyType {
        case accessToken
        case nickname
        case profileImageURL
        case profileThumbnailURL

        public var name: String {
            return "UserStorageKey_\(self.rawValue)"
        }
    }
}

public extension KeymeUserStorage {
    var accessToken: String? {
        get { get(.accessToken) as? String }
        set { set(newValue, forKey: .accessToken) }
    }
    
    var nickname: String? {
        get { get(.nickname) as? String }
        set { set(newValue, forKey: .nickname) }
    }
    
    var profileImageURL: URL? {
        get { get(.profileImageURL) as? URL }
        set { set(newValue, forKey: .profileImageURL) }
    }

    var profileThumbnailURL: URL? {
        get { get(.profileThumbnailURL) as? URL }
        set { set(newValue, forKey: .profileThumbnailURL) }
    }
}

extension KeymeUserStorage: DependencyKey {
    public static var liveValue = KeymeUserStorage()
    public static var testValue: KeymeUserStorage {
        KeymeUserStorage() // FIXME:
    }
}

extension DependencyValues {
    public var userStorage: KeymeUserStorage {
        get { self[KeymeUserStorage.self] }
        set { self[KeymeUserStorage.self] = newValue }
    }
}
