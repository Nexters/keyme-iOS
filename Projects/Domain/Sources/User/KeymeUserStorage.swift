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

    var nickname: String?
    var isLoggedIn: Bool?
    
    public init() {
        self.nickname = self.get(.nickname)
        self.isLoggedIn = self.get(.isLoggedIn) ?? false
    }
    
    public func get<T>(_ key: UserStorageKey) -> T? {
        return localStorage.get(key) as? T
    }
    
    public func set<T>(_ value: T, forKey key: UserStorageKey) {
        switch key {
        case .isLoggedIn:
            guard let flag = value as? Bool else { return }
            self.isLoggedIn = flag
        case .nickname:
            guard let name = value as? String else { return }
            self.nickname = name
        }
        
        localStorage.set(value, forKey: key)
    }
}

public extension KeymeUserStorage {
    enum UserStorageKey: StorageKeyType {
        case isLoggedIn
        case nickname
        
        var name: String {
            switch self {
            case .isLoggedIn:
                return "UserStorageKey_isLoggedIn"
            case .nickname:
                return "UserStorageKey_nickname"
            }
        }
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
