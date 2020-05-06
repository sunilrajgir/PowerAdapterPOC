//
//  PASegmentViewProvider.swift
//  PowerAdapter
//
//  Created by Prashant Rathore on 17/04/20.
//

import Foundation

public protocol PASegmentViewProvider  {
    
    func segmentViewForType(_ flipperView : PAFlipperView, _ type : Int) -> PASegmentView
    
}
