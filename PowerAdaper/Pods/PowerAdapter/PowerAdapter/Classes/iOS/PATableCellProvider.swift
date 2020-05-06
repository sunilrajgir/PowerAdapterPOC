//
//  File.swift
//  
//
//  Created by Prashant Rathore on 17/02/20.
//

import Foundation
import UIKit

open class PATableCellProvider  {
    
    private var cellsRegistered = false
    
    public init() {
    }
    
    internal func registerCellsInternal(_ tableView : UITableView) {
        if(cellsRegistered) {
            return
        }
        cellsRegistered = true
        registerCells(tableView)
    }
    
    open func registerCells(_ tableView : UITableView) {
        preconditionFailure("This method must be implemented")
    }
    
    open func cellNameForController(_ controller : PAController) -> String {
        preconditionFailure("This method must be implemented")
    }
    
    open func cellForController(_ tableView : UITableView,_ controller : PAController, _ indexPath : IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: cellNameForController(controller))!
    }
    
    
    open func heightForCell(_ tableView : UITableView,_ controller : PAController) -> CGFloat {
        preconditionFailure("This method must be implemented")
    }
}
