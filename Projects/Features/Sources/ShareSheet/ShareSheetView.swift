//
//  ShareSheetView.swift
//  Features
//
//  Created by Young Bin on 2023/08/19.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Foundation

import SwiftUI
import UIKit

struct ActivityViewController: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    var activityItems: [Any]
    
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        
        // Set the completion handler
        controller.completionWithItemsHandler = { (activityType, completed, returnedItems, error) in
            // Dismiss the share sheet when the share action completes (whether successful or not)
            self.isPresented = false
        }
        
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityViewController>) {
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
