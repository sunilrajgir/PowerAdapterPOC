//
//  PSItemControllerSource.swift
//  PowerAdapter
//
//  Created by Prashant Rathore on 14/02/20.
//  Copyright © 2020 Prashant Rathore. All rights reserved.
//

import Foundation
import RxSwift


public protocol ViewInteractor : AnyObject {
    func processWhenSafe(_ runnable: @escaping () -> Void)
    func cancelOldProcess(_ runnable: @escaping () -> Void)
}


@objcMembers open class PAItemControllerSource : NSObject {
    
    private let updateEventPublisher = PublishSubject<PASourceUpdateEventModel>()
    public private(set) var itemCount = 0
    private var maxCount = -1
    private var hasMaxLimit = false

    weak var viewInteractor: ViewInteractor?

    private var lastItem: PAItemController?
    //    ItemControllerSource<Item,Controller> getRootAdapter(int position);
    private (set) var lastItemIndex = -1
        

    func onAttached() {
        
    }
    
    func onItemAttached(position: Int) {
        
    }
    
    func observeAdapterUpdates() -> Observable<PASourceUpdateEventModel> {
        return updateEventPublisher
    }

    func getItemId(position: Int) -> String {
        return getItem(position).id()
    }

    func getItemType(position: Int) -> Int {
        return getItem(position).type()
    }

    public func setMaxLimit(limit: Int) {
        var newLimit = limit
        if(limit < 0) {
            newLimit = 0
        }
        processWhenSafe { self.setMaxLimitWhenSafe(newLimit) }
    }

    private func setMaxLimitWhenSafe(_ limit: Int) {
        hasMaxLimit = true
        maxCount = limit
        if (maxCount < itemCount) {
            notifyItemsRemoved(maxCount, itemCount - maxCount)
        }
    }

    func removeMaxLimit() {
        processWhenSafe{ self.removeMaxLimitWhenSafe() }
    }

    private func removeMaxLimitWhenSafe() {
        let oldItemCount = itemCount
        let newItemCount = computeItemCount()
        if (oldItemCount < newItemCount) {
            let diff = newItemCount - oldItemCount
            notifyItemsInserted(oldItemCount, diff)
        }
    }

    func getItemPosition(_ item: PAItemController) -> Int
    {
        return 0
    }
    
    public func getItem(index: Int) -> PAController {
        return getItem(index).controller
    }
    
    func getItem(_ position: Int) -> PAItemController {
        if (lastItemIndex == position) {
            return lastItem!
        } else {
            let item = getItemForPosition(position)
            lastItem = item
            lastItemIndex = position
            return item
        }
    }

   func getItemForPosition(_ position: Int) -> PAItemController {
        return nil!
    }
    //    public abstract void onItemDetached(int position);
    func onDetached() {
        
    }

    func notifyItemsInserted(_ startPosition: Int,_ itemsInserted: Int) {
        resetCachedItems(startPosition)
        let oldItemCount = itemCount
        itemCount = computeItemCountOnItemsInserted(startPosition, itemsInserted)
        let diff = itemCount - oldItemCount
        publishUpdateEvent(startPosition, UpdateEventType.itemsAdded, diff)
        resetCachedItems(startPosition)
    }
    
    func notifyItemMoved(_ position : Int, newPosition : Int) {
        resetCachedItems(min(position,newPosition))
        updateEventPublisher.onNext(PASourceUpdateEventModel(type: .itemMoved, oldPosition: position, newPosition: newPosition))
        resetCachedItems(min(position,newPosition))
    }

    private func computeItemCountOnItemsInserted(_ startPosition: Int,_ itemCount: Int) -> Int {
        return (hasMaxLimit) ? itemCountIfLimitEnabled(startPosition + itemCount) : self.itemCount + itemCount
    }

    func notifyItemsRemoved(_ startPosition: Int,_ itemsRemoved: Int) {
        resetCachedItems(startPosition)
        let oldItemCount = itemCount
        itemCount = computeItemCountOnItemsRemoved(oldItemCount, itemsRemoved)
        let diff = oldItemCount - itemCount
        publishUpdateEvent(startPosition, UpdateEventType.itemsRemoved, diff)
        resetCachedItems(startPosition)
    }

    private func computeItemCountOnItemsRemoved(_ oldItemCount: Int,_ itemCount: Int) -> Int {
        return  (hasMaxLimit) ? itemCountIfLimitEnabled(oldItemCount - itemCount) : (oldItemCount - itemCount)
    }

    private func itemCountIfLimitEnabled(_ newItemCount: Int) -> Int {
        return min(newItemCount, maxCount)
    }

    private func resetCachedItems(_ startPosition: Int) {
        if (startPosition <= lastItemIndex) {
            lastItemIndex = -1
            lastItem = nil
        }
    }

    internal func computeItemCount() -> Int {
        return 0
    }

    private func publishUpdateEvent(_ startPosition: Int,_ type: UpdateEventType,_ itemCount: Int) {
        updateEventPublisher.onNext(PASourceUpdateEventModel(type: type, position: startPosition, itemCount: itemCount))
    }


    func notifyItemsChanged(_ startIndex: Int, itemCount: Int) {
        if (self.itemCount > startIndex) {
            resetCachedItems(startIndex)
            publishUpdateEvent(startIndex, UpdateEventType.itemsChanges, min(self.itemCount - startIndex, itemCount))
        }
    }

    func endUpdates() {
        publishUpdateEvent(0, UpdateEventType.updateEnds, 0)
    }

    func beginUpdates() {
        publishUpdateEvent(0, UpdateEventType.updateBegins, 0)
    }

    func processWhenSafe(_ runnable: @escaping () -> Void) {
        if(viewInteractor != nil) {
            viewInteractor?.processWhenSafe(runnable)
        }
        else {
          runnable()
        }
         
    }

    func notifyItemsMoved(fromPosition: Int, toPosition: Int) {
        
    }

    
}
