//
//  File.swift
//
//
//  Created by Prashant Rathore on 17/02/20.
//

import Foundation
import RxSwift

open class PASectionDatasource : ViewInteractor {
    
    private var sections = [PATableSection]()
    private let disposeBag = DisposeBag()
    private let sectionUpdatePubliser = PublishSubject<(Int,PASourceUpdateEventModel)>()
    private let itemUpdatePublisher = PAItemUpdatePublisher()
    private var isAttached = false
    private var sectionsCount = 0
    
    public init() {
        
    }
    
    public func processWhenSafe(_ runnable: @escaping () -> Void) {
        if(Thread.isMainThread) {
            runnable()
        }
        else {
            DispatchQueue.main.sync {
                runnable()
            }
        }
    }
    
    public func cancelOldProcess(_ runnable: () -> Void) {
        
    }
    
    public func onAttached() {
        self.isAttached = true
        sections.forEach { (value) in
            value.item.performCreate(itemUpdatePublisher)
            value.source.onAttached()
        }
    }
    
    func count() -> Int {
        return sectionsCount
    }
    
    public func addSection(item : PAController, source : PAItemControllerSource) {
        if(Thread.isMainThread) {
            addSectionImmediate(item: item, source: source)
        }
        else {
            DispatchQueue.main.async {
                self.addSectionImmediate(item: item, source: source)
            }
        }
    }
    
    private func addSectionImmediate(item : PAController, source : PAItemControllerSource) {
        if(isAttached) {
            item.onCreate(self.itemUpdatePublisher)
            source.onAttached()
        }
        let section = PATableSection(PAItemController(item), source: source)
        section.index = sections.count
        source.viewInteractor = self
        source.observeAdapterUpdates().map { [unowned self] (value) -> PASourceUpdateEventModel in
            self.sectionContentUpdate(section, value)
            return value
        }.subscribe().disposed(by: disposeBag)
        sections.append(section)
        notifySectionInserted(section)
    }
    
    
    
    func invalidateContentCount() {
        sectionsCount = sections.count
        sections.forEach { (section) in
            section.count = section.source.itemCount
        }
    }
    
    
    public func numberOfRowsInSection(_ section : Int) -> Int {
        return sections[section].count
    }
    
    func sectionContentUpdate(_ section : PATableSection, _ update : PASourceUpdateEventModel) {
        sendSectionEvent((section.index, update))
    }
    
    func endUpdates() {
        sectionUpdatePubliser.onNext((0,PASourceUpdateEventModel(type: UpdateEventType.updateEnds, position: 0, itemCount: 0)))
    }

    func beginUpdates() {
        sectionUpdatePubliser.onNext((0,PASourceUpdateEventModel(type: UpdateEventType.updateBegins, position: 0, itemCount: 0)))
    }
    
    func notifySectionInserted(_ section : PATableSection) {
        beginUpdates()
        sendSectionEvent((section.index,PASourceUpdateEventModel(type: UpdateEventType.sectionInserted, position: 0, itemCount: 0)))
        endUpdates()
    }
    
    func sendSectionEvent(_ event : (Int,PASourceUpdateEventModel)) {
        sectionUpdatePubliser.onNext(event)
    }
    
    func observeSectionUpdateEvents() -> Observable<(Int,PASourceUpdateEventModel)> {
        return sectionUpdatePubliser
    }
    
    func sectionItemAtIndex(_ index : Int) -> PAItemController {
        return self.sections[index].item
    }
    
    func itemAtIndexPath(_ indexPath : IndexPath) -> PAItemController {
        return self.sections[indexPath.section].source.getItem(indexPath.row)
    }
    
    public func onDetached() {
        self.isAttached = false
        sections.forEach { (value) in
            value.source.onDetached()
        }
    }
    
}


internal class PATableSection {
    
    let item : PAItemController
    let source : PAItemControllerSource
    var index = 0
    var count = 0

    init(_ item : PAItemController, source : PAItemControllerSource) {
        self.item = item
        self.source = source
    }
}
