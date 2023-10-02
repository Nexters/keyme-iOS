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
    private let localStorage: CoreLocalStorage
    
    init(localStorage: CoreLocalStorage) {
        self.localStorage = localStorage
    }

    private func get(_ key: UserStorageKey) -> Any? {
        localStorage.get(key)
    }
    
    private func set(_ value: Any?, forKey key: UserStorageKey) {
        localStorage.set(value, forKey: key)
    }
    
    private enum UserStorageKey: String, StorageKeyType {
        case accessToken
        case userId
        case friendCode
        case nickname
        case launchCount
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
    
    var userId: Int? {
        get { get(.userId) as? Int }
        set { set(newValue, forKey: .userId) }
    }
    
    var friendCode: String? {
        get { get(.friendCode) as? String }
        set { set(newValue, forKey: .friendCode) }
    }
    
    var nickname: String? {
        get { get(.nickname) as? String }
        set { set(newValue, forKey: .nickname) }
    }
    
    var launchCount: Int? {
        get { get(.launchCount) as? Int }
        set { set(newValue, forKey: .launchCount) }
    }
    
    var profileImageURL: URL? {
        get { get(.profileImageURL) as? URL }
        set { set(newValue?.absoluteString, forKey: .profileImageURL) }
    }

    var profileThumbnailURL: URL? {
        get { get(.profileThumbnailURL) as? URL }
        set { set(newValue?.absoluteString, forKey: .profileThumbnailURL) }
    }
}

extension KeymeUserStorage: DependencyKey {
    public static var liveValue = KeymeUserStorage(localStorage: CoreLocalStorage.liveValue)
    public static var testValue = KeymeUserStorage(
        localStorage: CoreLocalStorage.testValue(storage: .init(suiteName: "TestStorage")!))
}

extension DependencyValues {
    public var userStorage: KeymeUserStorage {
        get { self[KeymeUserStorage.self] }
        set { self[KeymeUserStorage.self] = newValue }
    }
}
