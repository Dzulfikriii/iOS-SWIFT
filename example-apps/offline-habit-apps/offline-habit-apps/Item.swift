//
//  Item.swift
//  offline-habit-apps
//
//  Created by Dzulfikri Pysal on 27/10/2025.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
