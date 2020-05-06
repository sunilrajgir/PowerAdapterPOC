import Foundation
import RxSwift
import UIKit

public protocol PATableViewPageDelegate : AnyObject {
    func onPageChanged(_ tableView : UITableView, pagePath: IndexPath)
}

public class PATableDelegate : NSObject, UITableViewDataSource, UITableViewDelegate {

    
    private let cellProvider : PATableCellProvider
    private let sections : PASectionDatasource
    private let disposeBag = DisposeBag()
    private let parentLifecycle : PALifecycle
    private let isPagingEnabled : Bool
    weak var tableView : UITableView?
    private var currentPage : IndexPath = IndexPath.init(row: 0, section: 0)
    public weak var pageChangeDelegate : PATableViewPageDelegate?
    private weak var parent : PAParent?
    
    public init(_ cellProvider : PATableCellProvider,_ sections : PASectionDatasource, _ parent : PAParent, _ isPagingEnabled : Bool) {
        self.cellProvider = cellProvider
        self.sections = sections
        self.parent = parent
        self.parentLifecycle = parent.getLifecycle()
        self.isPagingEnabled = isPagingEnabled
    }
    
    public func bind(_ tableView : UITableView) {
        unBind()
        self.tableView = tableView
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isPagingEnabled = isPagingEnabled
        self.sections.observeSectionUpdateEvents().map {[weak tableView,weak self] (update) -> Bool in
            if(tableView != nil) {
                self?.performUpdate(tableView!, update)
            }
            return true
        }.subscribe().disposed(by: disposeBag)
        self.cellProvider.registerCellsInternal(tableView)
        self.sections.onAttached()
    }
    
    private func performUpdate(_ tableView : UITableView, _ update : (Int, PASourceUpdateEventModel) ){
        switch update.1.type {
        case .updateBegins:
            tableView.beginUpdates()
        case .itemsChanges:
            tableView.reloadRows(at: createIndexPathArray(update.0, update.1), with: UITableView.RowAnimation.automatic)
        case .itemsRemoved:
            tableView.deleteRows(at:  createIndexPathArray(update.0, update.1), with: UITableView.RowAnimation.automatic)
        case .itemsAdded:
            tableView.insertRows(at:  createIndexPathArray(update.0, update.1), with: UITableView.RowAnimation.automatic)
        case .itemMoved:
            let oldPath = IndexPath(row: update.1.position, section: update.0)
            let newPath = IndexPath(row: update.1.newPosition, section: update.0)
            tableView.moveRow(at: oldPath, to: newPath)
        case .updateEnds:
            tableView.endUpdates()
        case .sectionMoved:
            tableView.moveSection(update.1.position, toSection: update.1.newPosition)
        case .sectionInserted:
            tableView.insertSections(IndexSet.init(arrayLiteral: update.0), with: .automatic)
        }
        
    }
    
    private func createIndexPathArray(_ section : Int,_ update : PASourceUpdateEventModel) -> [IndexPath] {
        var arr = [IndexPath]()
        for i in update.position..<update.position + update.itemCount {
            arr.append(IndexPath.init(row: i, section:section ))
        }
        return arr
    }
    
    
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections.numberOfRowsInSection(section)
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count()
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = itemAtIndexPath(indexPath)
        let cell = self.cellProvider.cellForController(tableView, item.controller,indexPath)
        let paTableCell = (cell as! PATableViewCell)
        paTableCell.bind(item,parent!)
        return cell
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if(!self.isPagingEnabled || self.currentPage == indexPath) {
            let tableCell = cell as! PATableViewCell
            tableCell.willDisplay()
        }
    }
    
    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let tableCell = cell as! PATableViewCell
        tableCell.willEndDisplay()
        if(self.currentPage == indexPath) {
            self.currentPage = IndexPath(row: -1, section: -1)
        }
    }
    
    public func itemAtIndexPath(_ indexPath: IndexPath) -> PAItemController {
        return self.sections.itemAtIndexPath(indexPath)
    }
    
    public func sectionAtIndex(_ index : Int) -> PAItemController {
        return sections.sectionItemAtIndex(index)
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellProvider.heightForCell(tableView, itemAtIndexPath(indexPath).controller)
    }
    
    func unBind() {
        self.tableView?.dataSource = nil
        self.tableView?.delegate = nil
        self.tableView = nil
        sections.onDetached()
    }
    
    
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateCurrentPage()
    }
    
    
    open func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        updateCurrentPage()
    }
    
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        updateCurrentPage()
    }
    
    
    private func updateCurrentPage() {
        if(self.isPagingEnabled) {
            if let tableView = self.tableView {
                let center = CGPoint(x: tableView.contentOffset.x + (tableView.frame.width / 2), y: tableView.contentOffset.y + (tableView.frame.height / 2))
                if let ip = tableView.indexPathForRow(at: center) {
                    if(self.currentPage != ip) {
                        setCurrentPage(tableView, ip)
                    }
                }
            }
        }
    }
    
    private func setCurrentPage(_ tableView : UITableView, _ ip : IndexPath) {
        let oldCell = tableView.cellForRow(at: self.currentPage)
        (oldCell as? PATableViewCell)?.willEndDisplay()
        self.currentPage = ip
        let newCell = tableView.cellForRow(at: self.currentPage)
        (newCell as? PATableViewCell)?.willDisplay()
        self.pageChangeDelegate?.onPageChanged(tableView, pagePath: ip)
    }
    
    
    
}
