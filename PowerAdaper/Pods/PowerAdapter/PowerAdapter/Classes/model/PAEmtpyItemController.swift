//
//  File.swift
//  
//
//  Created by Prashant Rathore on 17/02/20.
//

import Foundation

public class PAEmtpyItemController: PAController {
    
    
    public func getType() -> Int {
        1
    }
    
    public func getId() -> String {
        return "1"
    }
    
    public func onCreate(_ itemUpdatePublisher: PAItemUpdatePublisher) {
           
    }
    public func onViewDidUnload() {
        
    }
    
    public func onViewDidLoad() {
        
    }
    
    public func onViewWillAppear() {
        
    }
    
    public func onViewDidDisapper() {
        
    }
    
    public func onDestroy() {
        
    }
    
    
    public func isContentEqual(_ rhs: PAController) -> Bool {
        return true
    }
    
    
   
    public func hash(into hasher: inout Hasher) {
        
    }
    
}
