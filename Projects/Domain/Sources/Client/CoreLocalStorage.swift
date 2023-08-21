//
//  LocalStorageClient.swift
//  Domain
//
//  Created by Young Bin on 2023/08/10.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import ComposableArchitecture
import Foundation

struct CoreLocalStorage {
    private let storage: UserDefaults
    
    init(storage: UserDefaults = .standard) {
        self.storage = storage
    }
    
    /// 알아서 파싱해서 쓰시길.. 더 빡세게 잡으려면 우리가 귀찮아짐
    public func get(_ key: some StorageKeyType) -> Any? {
        storage.object(forKey: key.name)
    }
    
    public func set(_ value: Any, forKey key: some StorageKeyType) {
        storage.set(value, forKey: key.name)
    }
}

extension CoreLocalStorage: DependencyKey {
    static var liveValue = CoreLocalStorage()
    static func testValue(storage: UserDefaults) -> CoreLocalStorage {
        CoreLocalStorage(storage: storage)
    }
}

extension DependencyValues {
    var localStorage: CoreLocalStorage {
        get { self[CoreLocalStorage.self] }
        set { self[CoreLocalStorage.self] = newValue }
    }
}
