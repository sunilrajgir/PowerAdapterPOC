//
//  PACollecionViewDelegate.swift
//  PowerAdapter
//
//  Created by Prashant Rathore on 07/04/20.
//

import Foundation
import RxSwift
import UIKit


open class PACollectionViewDelegate : NSObject, UICollectionViewDelegate, UICollectionViewDataSource {
    
    private let cellProvider : PACollectionViewCellProvider
    public let sections : PASectionDatasource
    private let disposeBag = DisposeBag()
    private let parentLifecycle : PALifecycle
    private weak var parent : PAParent?
    public private(set) weak var collectionView : UICollectionView?
    private var updates = [(Int, PASourceUpdateEventModel)]()
    
    public private(set) var totalNumberOfRowsInAllSections : Int = 0
    
    public init(_ cellProvider : PACollectionViewCellProvider,_ sections : PASectionDatasource, _ parent : PAParent) {
        self.cellProvider = cellProvider
        self.sections = sections
        self.parentLifecycle = parent.getLifecycle()
        self.parent = parent
    }
    
    public func bind(_ collectionView : UICollectionView) {
        unBind()
        self.collectionView = collectionView
        self.sections.invalidateContentCount()
        collectionView.dataSource = self
        collectionView.delegate = self
        self.sections.observeSectionUpdateEvents().map {[weak collectionView,weak self] (update) -> Bool in
            if(collectionView != nil) {
                self?.performUpdate(collectionView!, update)
            }
            return true
        }.subscribe().disposed(by: disposeBag)
        self.cellProvider.registerCellsInternal(collectionView)
        self.sections.onAttached()
    }
    
    
    
    private func performUpdate(_ collectionView : UICollectionView, _ update : (Int, PASourceUpdateEventModel) ){
        switch update.1.type {
        case .updateBegins: updates = [(Int, PASourceUpdateEventModel)]()
        case .updateEnds: collectionView.performBatchUpdates({
            updates.forEach { (value) in
                performUpdateImmediate(collectionView, value)
                self.sections.invalidateContentCount()
            }
        }) { (value) in
            self.sections.invalidateContentCount()
            }
        updateTotalRows()
        updateEnds()
        default : updates.append(update)
        }
    }
    
    open func updateEnds() {
        
    }
    
    private func updateTotalRows() {
        var rows = 0;
        for i in 0..<self.sections.count() {
            rows = rows + self.sections.numberOfRowsInSection(i)
        }
        self.totalNumberOfRowsInAllSections = rows
    }
    
    
    private func performUpdateImmediate(_ collectionView : UICollectionView, _ update : (Int, PASourceUpdateEventModel) )
    {
        switch update.1.type {
        case .updateBegins: return
        //            collectionView.beginUpdates()
        case .sectionInserted:
            collectionView.insertSections(IndexSet.init(arrayLiteral: update.0))
        case .itemsChanges:
            collectionView.reloadItems(at: createIndexPathArray(update.0, update.1))
        case .itemsRemoved:
            collectionView.deleteItems(at:  createIndexPathArray(update.0, update.1))
        case .itemsAdded:
            collectionView.insertItems(at:  createIndexPathArray(update.0, update.1))
        case .itemMoved:
            let oldPath = IndexPath(row: update.1.position, section: update.0)
            let newPath = IndexPath(row: update.1.newPosition, section: update.0)
            collectionView.moveItem(at: oldPath, to: newPath)
        case .sectionMoved:
            collectionView.moveSection(update.1.position, toSection: update.1.newPosition)
        case .updateEnds: return
        }
        
        
        
    }
    
    private func createIndexPathArray(_ section : Int,_ update : PASourceUpdateEventModel) -> [IndexPath] {
        var arr = [IndexPath]()
        for i in update.position..<update.position + update.itemCount {
            arr.append(IndexPath.init(row: i, section:section ))
        }
        return arr
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.sections.numberOfRowsInSection(section)
    }
    
    
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count()
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = itemAtIndexPath(indexPath)
        let cell = self.cellProvider.cellForController(collectionView, item.controller, indexPath)
        let paTableCell = (cell as! PACollectionViewCell)
        paTableCell.bind(item,self.parent!)
        return cell
    }
    
    open func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let tableCell = cell as! PACollectionViewCell
        tableCell.willDisplay()
    }
    
    open func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let tableCell = cell as! PACollectionViewCell
        tableCell.willEndDisplay()
    }
    
    public func itemAtIndexPath(_ indexPath: IndexPath) -> PAItemController {
        return self.sections.itemAtIndexPath(indexPath)
    }
    
    public func sectionAtIndex(_ index : Int) -> PAItemController {
        return sections.sectionItemAtIndex(index)
    }
    
    func unBind() {
        self.collectionView?.dataSource = nil
        self.collectionView?.delegate = nil
        self.collectionView = nil
        sections.onDetached()
    }
    
}
