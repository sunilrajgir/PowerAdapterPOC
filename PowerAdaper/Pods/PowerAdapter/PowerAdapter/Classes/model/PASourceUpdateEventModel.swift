//
//  PSSourceUpdateEventModel.swift
//  PowerAdapter
//
//  Created by Prashant Rathore on 14/02/20.
//  Copyright © 2020 Prashant Rathore. All rights reserved.
//

import Foundation
import RxSwift

enum UpdateEventType {
    case updateBegins
    case itemsChanges
    case itemsRemoved
    case itemsAdded
    case itemMoved
    case sectionMoved
    case updateEnds
    case sectionInserted
}

internal struct PASourceUpdateEventModel  {
    
    let type: UpdateEventType
    let position: Int
    let itemCount: Int
    let newPosition : Int
    
    init(type: UpdateEventType, position: Int, itemCount: Int) {
        self.type = type
        self.position = position
        self.itemCount = itemCount
        self.newPosition = -1
    }
    
    init(type: UpdateEventType, oldPosition: Int, newPosition: Int) {
        self.type = type
        self.position = oldPosition
        self.itemCount = -1
        self.newPosition = newPosition
    }

}
