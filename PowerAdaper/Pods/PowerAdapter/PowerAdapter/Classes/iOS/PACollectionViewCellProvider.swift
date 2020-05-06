//
//  PACollectionViewCellProvider.swift
//  PowerAdapter
//
//  Created by Prashant Rathore on 07/04/20.
//

import Foundation

import UIKit

open class PACollectionViewCellProvider  {
    
    private var cellsRegistered = false
    
    public init() {
    }
    
    internal func registerCellsInternal(_ collectionView : UICollectionView) {
        if(cellsRegistered) {
            return
        }
        cellsRegistered = true
        registerCells(collectionView)
    }
    
    open func registerCells(_ collectionView : UICollectionView) {
        preconditionFailure("This method must be implemented")
    }
    
    open func cellNameForController(_ controller : PAController) -> String {
        preconditionFailure("This method must be implemented")
    }
    
    open func cellForController(_ collectionView : UICollectionView,_ controller : PAController, _ indexPath : IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: cellNameForController(controller), for: indexPath)
    }
    
}
