//
//  PAAdapterAsItem.swift
//  PowerAdapter
//
//  Created by Prashant Rathore on 19/02/20.
//

import Foundation
import RxSwift

class PAAdapterAsItem {
    
    let adapter: PAItemControllerSource
    var startPosition = 0
    private var disposeBag = DisposeBag()
    weak var parent : PAProxySource?
    
    init(adapter: PAItemControllerSource,
         parent : PAProxySource) {
        self.adapter = adapter
        self.parent = parent
        self.subscribeUpdates()
    }
    
    private func subscribeUpdates() {
        adapter.observeAdapterUpdates().map({[weak self] (event) -> Bool in
            self?.transformUpdateEvent(event)
            return true
        }).subscribe().disposed(by: disposeBag)
    }
    
    func transformUpdateEvent(_ event: PASourceUpdateEventModel) {
        let actualStartPosition = startPosition + event.position
        switch (event.type) {
        case .updateBegins : parent?.beginUpdates()
        case .itemsChanges : parent?.notifyItemsChanged(actualStartPosition, itemCount: event.itemCount)
        case .itemsRemoved : parent?.notifyItemsRemoved(actualStartPosition, event.itemCount)
        case .itemsAdded : parent?.notifyItemsInserted(actualStartPosition, event.itemCount)
        case .itemMoved : parent?.notifyItemMoved(actualStartPosition, newPosition: event.newPosition)
        case .updateEnds : parent?.endUpdates()
        case .sectionMoved: preconditionFailure("This is invalid call")
        case .sectionInserted : preconditionFailure("This is invalid call")
        }
        parent?.updateIndexes(self)
    }

    
}
