//
//  PAParent.swift
//  PowerAdapter
//
//  Created by Prashant Rathore on 10/04/20.
//

import Foundation

public protocol PAParent : AnyObject {
    
    func getParent() -> PAParent?
    func getLifecycle() -> PALifecycle
    func getRootParent() -> PAParent
}
