//
//  LocalStorageClient.swift
//  Domain
//
//  Created by Young Bin on 2023/08/10.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import ComposableArchitecture
import Foundation

public struct LocalStorage {
    public enum Key: String {
        case isLoggedIn
        case visitCount
        
        var valueType: Any.Type {
            switch self {
            case .isLoggedIn:
                return Bool.self
            case .visitCount:
                return Int.self
            }
        }
    }
    
    private let storage: UserDefaults
    
    init(storage: UserDefaults = .standard) {
        self.storage = storage
    }
    
    /// 알아서 파싱해서 쓰시길.. 더 빡세게 잡으려면 우리가 귀찮아짐
    public func get(_ key: Key) -> Any? {
        switch key {
        case .isLoggedIn:
            return storage.bool(forKey: key.rawValue)
        case .visitCount:
            return storage.integer(forKey: key.rawValue)
        }
    }
    
    public func set(_ value: Any, forKey key: Key) {
        guard type(of: value) == key.valueType else {
            assertionFailure("Invalid type for key: \(key.rawValue)")
            return
        }
        
        storage.set(value, forKey: key.rawValue)
    }
}

extension LocalStorage {
    public static let shared = LocalStorage()
}

extension LocalStorage: DependencyKey {
    public static var liveValue = LocalStorage()
    public static func testValue(storage: UserDefaults) -> LocalStorage {
        LocalStorage(storage: storage)
    }
}

extension DependencyValues {
    public var localStorage: LocalStorage {
        get { self[LocalStorage.self] }
        set { self[LocalStorage.self] = newValue }
    }
}
