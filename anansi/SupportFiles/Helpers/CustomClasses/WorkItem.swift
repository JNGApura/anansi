//
//  WorkItem.swift
//  anansi
//
//  Created by João Nuno Gaspar Apura on 24/06/2019.
//  Copyright © 2019 João Apura. All rights reserved.
//

import UIKit

class WorkItem {
    
    private var pendingRequestWorkItem: DispatchWorkItem?
    
    func perform(after: TimeInterval, _ block: @escaping () -> Void) {
        // Cancel the currently pending item
        pendingRequestWorkItem?.cancel()
        
        // Wrap our request in a work item
        let requestWorkItem = DispatchWorkItem(block: block)
        pendingRequestWorkItem = requestWorkItem
        
        DispatchQueue.main.asyncAfter(deadline: .now() + after, execute: requestWorkItem)
    }
}
