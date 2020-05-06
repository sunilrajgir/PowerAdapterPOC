//
//  PASegment.swift
//  PowerAdapter
//
//  Created by Prashant Rathore on 09/04/20.
//

import Foundation

open class PASegment  {
    
    public let segmentView : PASegmentView
    let itemController : PAItemController
    public let controller : PAController
    var currentState = PAItemController.State.FRESH
    
    public init(_ segmentView : PASegmentView, _ controller : PAController) {
        self.segmentView = segmentView
        self.controller = controller
        self.itemController = PAItemController(controller)
    }
    
    
}
