//
//  PAHeaderWithChildrenSource.swift
//  DeepDiff
//
//  Created by Prashant Rathore on 18/02/20.
//

import Foundation
import RxSwift

class PAHeaderWithChildrenSource : PAProxySource {
    
    private var headerItemSource: PAAdapterAsItem?
    private var childrenItemSource: PAAdapterAsItem?
    private var isAttached = false

    override func onAttached() {
        isAttached = true
        headerItemSource?.adapter.onAttached()
        childrenItemSource?.adapter.onAttached()
    }
    
    override var viewInteractor: ViewInteractor? {
        didSet{
            if (headerItemSource != nil) {
                headerItemSource!.adapter.viewInteractor = viewInteractor
            }
            if (childrenItemSource != nil) {
                childrenItemSource!.adapter.viewInteractor = viewInteractor
            }
        }
    }

//    var viewInteractor: ViewInteractor? = null
//        set(viewInteractor) {
//            field = viewInteractor
            
//        }

    override func onItemAttached(position: Int) {
        let adapterAsItem = decodeAdapterItem(position)
        adapterAsItem.adapter.onItemAttached(position: position - adapterAsItem.startPosition)
    }


    //    public void addAdapter(ItemControllerSource<? extends ItemController> adapter) {
//        AdapterAsItem item = new AdapterAsItem(adapter);
//        if (adapters.size() > 0) {
//            AdapterAsItem previousItem = adapters.get(adapters.size() - 1);
//            item.startPosition = previousItem.startPosition + previousItem.adapter.getItemCount();
//        }
//        adapters.add(item);
//        if(isAttached) {
//            item.adapter.onAttached();
//        }
//        notifyItemsInserted(item.startPosition, item.adapter.getItemCount());
//    }
    override func computeItemCount() -> Int {
        return headerCount + childrenCount()
    }

    override func getItemForPosition(_ position: Int) -> PAItemController {
        let item = decodeAdapterItem(position)
        return item.adapter.getItem(position - item.startPosition)
    }

    //    @Override
//    public void onItemDetached(int position) {
//        AdapterAsItem adapterAsItem = decodeAdapterItem(position);
//        adapterAsItem.adapter.onItemDetached(position - adapterAsItem.startPosition);
//    }
    override func onDetached() {
        headerItemSource?.adapter.onDetached()
        childrenItemSource?.adapter.onDetached()
        isAttached = false
    }

    private func decodeAdapterItem(_ position: Int) -> PAAdapterAsItem {
        if (childrenItemSource != nil && childrenItemSource!.startPosition < position) {
            return childrenItemSource!
        } else {
            return headerItemSource!
        }
    }

    override func getItemPosition(_ item: PAItemController) -> Int {
//        let top = 0
        var itemPosition = getItemPositionHeader(item)
        if (itemPosition < 0) {
            itemPosition = getItemPositionChildren(item)
        }
        return itemPosition
    }

    private func getItemPositionHeader(_ item: PAItemController) -> Int {
        return headerItemSource?.adapter.getItemPosition(item) ?? -1
    }

    func getItemPositionChildren(_ item: PAItemController) -> Int {
        if (childrenItemSource == nil) {
            return -1
        } else {
            return childrenItemSource!.adapter.getItemPosition(item) - childrenItemSource!.startPosition
        }
    }

    override func updateIndexes(_ modifiedItem: PAAdapterAsItem) {
        if (modifiedItem === headerItemSource && childrenItemSource != nil) {
            childrenItemSource!.startPosition = headerCount
        }
    }

    private func childrenCount() -> Int {
        return childrenItemSource?.adapter.itemCount ?? 0
    }

    private var headerCount: Int {
        get {
            return headerItemSource?.adapter.itemCount ?? 0
        }
    }

    
}
