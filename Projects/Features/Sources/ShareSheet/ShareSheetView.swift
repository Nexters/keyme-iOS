//
//  ShareSheetView.swift
//  Features
//
//  Created by Young Bin on 2023/08/19.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Foundation

import ComposableArchitecture
import SwiftUI
import UIKit

public struct ShareSheetFeature: Reducer {
    public struct State: Equatable {
        public let url: URL
    }
    
    public enum Action: Equatable {}
    
    public var body: some ReducerOf<Self> {
        Reduce { _, _ in
            return .none
        }
    }
}

struct ActivityViewController: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    var activityItems: [Any]
    
    let store: StoreOf<ShareSheetFeature>?
    
    init(isPresented: Binding<Bool>, activityItems: [Any]) {
        self._isPresented = isPresented
        self.activityItems = activityItems
        store = nil
    }
    
    init(store: StoreOf<ShareSheetFeature>) {
        self._isPresented = .constant(false)
        self.activityItems = []
        self.store = store
    }
    
    var applicationActivities: [UIActivity]?

    func makeUIViewController(
        context: UIViewControllerRepresentableContext<ActivityViewController>
    ) -> UIActivityViewController {
        if let store {
            let viewStore = ViewStore(store, observe: { $0 })
            let controller = UIActivityViewController(
                activityItems: [viewStore.state.url],
                applicationActivities: applicationActivities)
            
            return controller
        } else {
            let controller = UIActivityViewController(
                activityItems: activityItems,
                applicationActivities: applicationActivities)
            
            // Set the completion handler
            controller.completionWithItemsHandler = { (_, _, _, _) in
                // Dismiss the share sheet when the share action completes (whether successful or not)
                self.isPresented = false
            }
            
            return controller
        }
    }

    func updateUIViewController(
        _ uiViewController: UIActivityViewController,
        context: UIViewControllerRepresentableContext<ActivityViewController>) {
        // Update code here if needed
    }
}

extension ActivityViewController {
    struct SharedURL: Identifiable {
        let id = UUID()
        let sharedURL: String
        
        init(_ sharedURL: String) {
            self.sharedURL = sharedURL
        }
    }
}
