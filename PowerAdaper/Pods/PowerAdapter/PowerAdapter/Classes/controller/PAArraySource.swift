//
//  File.swift
//  
//
//  Created by Prashant Rathore on 17/02/20.
//

import Foundation
import RxSwift
import DeepDiff

open class PAArraySource : PAItemControllerSource {
    
    private var controllers = [PAItemController]()
    private var isAttached = false
    private let itemUpdatePublisher = PAItemUpdatePublisher()
    private var disposeBag : DisposeBag?
    
    override func onAttached() {
        isAttached = true
        disposeBag = DisposeBag()
        observeItemUpdates().disposed(by: disposeBag!)
        for item in controllers {
            item.performCreate(itemUpdatePublisher)
        }
    }
    
    override func onItemAttached(position: Int) {
        
    }
    
    public func items() -> [PAItemController] {
        return controllers
    }
    
    
    public func setItems(_ items: [PAController]?) {
        switchItems(items)
    }
    
    private func switchItems(_ items:  [PAController]?, useDiffProcess: Bool) {
        let newItems = (items != nil) ? items! : [PAController]()
        var transformation = newItems.map({ (input) -> PAItemController in
            return PAItemController(input)
        })
        processWhenSafe { self.switchItemImmediate(useDiffProcess, &transformation) }
    }
    
    private func switchItemImmediate(_ useDiffProcess: Bool,_ newItems: inout [PAItemController]) {
        let oldCount = controllers.count
        let newCount = newItems.count
        let retained = Set<PAItemController>()
        
        let diffResult = diff(old: controllers, new: newItems)
//        diffResult.
        var oldItems = controllers
        
        if (isAttached) {
            for item in newItems {
                item.performCreate(itemUpdatePublisher)
            }
        }
        
        controllers = newItems
        beginUpdates()
        if (useDiffProcess && false) {
//            diffResult.dispatchUpdatesTo(self)
        } else {
            let diff = newCount - oldCount
            if (diff > 0) {
                notifyItemsInserted(oldCount, diff)
                notifyItemsChanged(0, itemCount: oldCount)
            } else if (diff < 0) {
                notifyItemsRemoved(newCount, diff * -1)
                notifyItemsChanged(0, itemCount: newCount)
            } else {
                notifyItemsChanged(0, itemCount: newCount)
            }
        }
        endUpdates()

        
        oldItems.removeAll { (item) -> Bool in
            return retained.contains(item)
        }
        
        for item in oldItems {
            item.performDestroy()
        }
    }
    
    func switchItems(_ items: [PAController]?) {
        switchItems(items, useDiffProcess: false)
    }
    
    func switchItemsWithDiffRemovalAndInsertions(_ items: [PAController]?) {
        switchItems(items, useDiffProcess: true)
    }
    
//    private func diffResults(_ oldItems: List<Controller>,_ newItems: MutableList<Controller>, retained: inout Set<Controller>): DiffUtil.DiffResult {
//        return DiffUtil.calculateDiff(object : DiffUtil.Callback() {
//            override fun getOldListSize(): Int {
//                return oldItems.size
//            }
//
//            override fun getNewListSize(): Int {
//                return newItems.size
//            }
//
//            override fun areItemsTheSame(oldPosition: Int, newPosition: Int): Boolean {
//                val itemOld = oldItems[oldPosition]
//                val itemNew = newItems[newPosition]
//                val equals = itemOld === itemNew || itemOld.hashCode() == itemNew.hashCode() && itemOld == itemNew
//                if (equals) {
//                    newItems[newPosition] = itemOld
//                    retained.add(itemOld)
//                }
//                return equals
//            }
//
//            override fun areContentsTheSame(oldPosition: Int, newPosition: Int) -> Boolean {
//                return areItemsTheSame(oldPosition, newPosition)
//            }
//        }, false)
//    }
    
    func replaceItem(_ index: Int, _ item: PAController) {
        processWhenSafe{ self.replaceItemWhenSafe(index, item) }
    }
    
    private func replaceItemWhenSafe(_ index: Int,_ item: PAController) {
        let old = controllers[index]
        controllers[index] = PAItemController(item)
        old.performDestroy()
        notifyItemsChanged(index, itemCount: 1)
        if (isAttached) {
            item.onCreate(itemUpdatePublisher)
        }
    }
    
    
    override func getItemPosition(_ item: PAItemController) -> Int {
        return controllers.firstIndex(of: item) ?? -1
    }
    
    
    override func computeItemCount() -> Int {
        return controllers.count
    }
    
    override func getItemForPosition(_ position: Int) -> PAItemController {
        return controllers[position]
    }
    
    //    @Override
    //    public void onItemDetached(int position) {
    //
    //    }
    private func observeItemUpdates() -> Disposable {
        return itemUpdatePublisher.observeEvents().map({[weak self] (it) -> Any in
            self?.postItemUpdate(it)
            return it
        }).subscribe()
    }
    
    private func postItemUpdate(_ itemController: Any) {
        processWhenSafe{
            let index = self.controllers.firstIndex(of: itemController as! PAItemController)
            if (index ?? -1 >= 0) {
                self.notifyItemsChanged(index!, itemCount: 1)
            }
        }
    }
    
    override func onDetached() {
        disposeBag = nil
        isAttached = false
    }
    
}
