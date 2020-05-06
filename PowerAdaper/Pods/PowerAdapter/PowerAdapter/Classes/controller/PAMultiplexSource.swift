//
//  PAProxySource.swift
//  PowerAdapter
//
//  Created by Prashant Rathore on 19/02/20.
//

import Foundation
import RxSwift


/**
 * Created by prashant.rathore on 24/06/18.
 */
public class PAMultiplexSource : PAProxySource {
    
    private var sources = [PAAdapterAsItem]()
    private var isAttached = false
    
    public override init() {
        
    }
    
    
    override func onAttached() {
        isAttached = true
        for item in sources {
            item.adapter.onAttached()
        }
    }

    override public var viewInteractor: ViewInteractor? {
        didSet {
            sources.forEach({ (it) in
                it.adapter.viewInteractor = viewInteractor
            })
        }
    }


    override func onItemAttached(position: Int) {
        let adapterAsItem = decodeAdapterItem(position)
        adapterAsItem.adapter.onItemAttached(position: position - adapterAsItem.startPosition)
    }


    public func addSource(source: PAItemControllerSource) {
        insertSource(sources.count, source)
    }
    
    public func sourceAtIndex(_ index : Int) -> PAItemControllerSource {
        return sources[index].adapter
    }
    
    public func removeAllSources() {
        processWhenSafe {
            while(self.sources.count > 0) {
                self.removeSourceImmediate(self.sources.count-1)
            }
        }
    }

    public func insertSource(_ index: Int, _  source: PAItemControllerSource) {
        let item = PAAdapterAsItem(adapter: source ,parent: self)
        source.viewInteractor = viewInteractor
        processWhenSafe{ self.addSourceImmediate(index, item) }
    }

    private func addSourceImmediate(_ index: Int,_ item: PAAdapterAsItem) {
        if (sources.count > index) {
            let previousItem = sources[index]
            item.startPosition = previousItem.startPosition
        } else if (sources.count > 0) {
            let lastItem = sources[sources.count - 1]
            item.startPosition = lastItem.startPosition + lastItem.adapter.itemCount
        }
        sources.insert(item,at: index)
        updateIndexes(item)
        if (isAttached) {
            item.adapter.onAttached()
        }
        beginUpdates()
        notifyItemsInserted(item.startPosition, item.adapter.itemCount)
        endUpdates()
    }

    override func computeItemCount() -> Int {
        if (sources.count > 0) {
            let item = sources[sources.count - 1]
            return item.startPosition + item.adapter.itemCount
        }
        return 0
    }

    override func getItemForPosition(_ position: Int) -> PAItemController {
        let item = decodeAdapterItem(position)
        return item.adapter.getItem(position - item.startPosition)
    }
    
    public func numberOfSources() -> Int {
        return self.sources.count
    }

    //    @Override
//    public void onItemDetached(int position) {
//        AdapterAsItem adapterAsItem = decodeAdapterItem(position);
//        adapterAsItem.adapter.onItemDetached(position - adapterAsItem.startPosition);
//    }
    override func onDetached() {
        for item in sources {
            item.adapter.onDetached()
        }
        isAttached = false
    }

    private func decodeAdapterItem(_ position: Int) -> PAAdapterAsItem {
        var previous: PAAdapterAsItem!
        for adapterAsItem in sources {
            if (adapterAsItem.startPosition > position) {
                return previous
            } else {
                previous = adapterAsItem
            }
        }
        return previous
    }

    override func getItemPosition(_ item: PAItemController) -> Int {
        let top = 0
        var itemPosition = -1
        for adapterAsItem in sources {
            let foundPosition = adapterAsItem.adapter.getItemPosition(item)
            if (foundPosition >= 0) {
                itemPosition = top + foundPosition
                break
            }
        }
        return itemPosition
    }

    public func removeSource(_ removeSourceAtPosition: Int) {
        processWhenSafe{ self.removeSourceImmediate(removeSourceAtPosition) }
    }

    private func removeSourceImmediate(_ removeSourceAtPosition: Int) {
        let remove: PAAdapterAsItem = sources.remove(at: removeSourceAtPosition)
        let removePositionStart = remove.startPosition
        var nextsourcestartPosition = removePositionStart
        for index in removeSourceAtPosition..<sources.count {
            let adapterAsItem = sources[index]
            adapterAsItem.startPosition = nextsourcestartPosition
            nextsourcestartPosition = adapterAsItem.startPosition + adapterAsItem.adapter.itemCount
        }
        updateIndexes(remove)
        beginUpdates()
        notifyItemsRemoved(removePositionStart, remove.adapter.itemCount)
        endUpdates()
        remove.adapter.viewInteractor = nil
    }

    override func updateIndexes(_ modifiedItem: PAAdapterAsItem) {
        var modifiedItem = modifiedItem
        var continueUpdating = false
        for item in sources {
            if (continueUpdating) {
                item.startPosition = modifiedItem.startPosition + modifiedItem.adapter.itemCount
                modifiedItem = item
            } else if (item === modifiedItem) {
                continueUpdating = true
            }
        }
    }
}
