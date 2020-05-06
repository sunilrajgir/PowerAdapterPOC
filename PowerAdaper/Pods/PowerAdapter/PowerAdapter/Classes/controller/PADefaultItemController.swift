//
//  PADefaultItemController.swift
//  presenter
//
//  Created by Prashant Rathore on 07/04/20.
//  Copyright © 2020 TIL. All rights reserved.
//

import Foundation

public class PADefaultItemController: PAController {
    
    private let id : String
    private let type : Int
    
    public init(_ id : Int, _ type : Int) {
        self.id = id.description
        self.type = type
    }
    
    public func getType() -> Int {
        return type
    }
    
    public func getId() -> String {
        self.id
    }
    
    public func onCreate(_ itemUpdatePublisher: PAItemUpdatePublisher) {
        
    }
    
    public func onViewDidLoad() {
        
    }
    
    
    public func onViewWillAppear() {
        
    }
    
    public func onViewDidDisapper() {
        
    }
    
    public func onViewDidUnload() {
        
    }
    
    
    public func onDestroy() {
        
    }
    
    public func isContentEqual(_ rhs: PAController) -> Bool {
        return false
    }
    
    public func hash(into hasher: inout Hasher) {
        
    }
    
    
}
