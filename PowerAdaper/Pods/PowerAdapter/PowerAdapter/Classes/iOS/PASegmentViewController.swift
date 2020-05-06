//
//  PASegmentViewController.swift
//  PowerAdapter
//
//  Created by Prashant Rathore on 06/04/20.
//

import Foundation
import RxSwift

open class PASegmentViewController : PAViewController {
    
    @IBOutlet public var segmentView : PASegmentView?
    private var controller : PAItemController!
    private let itemUpdatePublisher = PAItemUpdatePublisher()
    private let disposeBag = DisposeBag()
    
    override open func viewDidLoad() {
        if(segmentView != nil) {
            controller = PAItemController(createController())
            observeLifecyle()
            self.segmentView!.bindInternal(self, self.controller)
            controller.performViewDidLoad()
        }
        return super.viewDidLoad()
    }
    
    private func observeLifecyle() {
        self.getLifecycle()
            .observeViewState()
            .map {[weak self] (state) -> PALifecycle.State in
                self?.lifecycleUpdated(state: state)
            return state
        }.subscribe().disposed(by: disposeBag)
    }
    
    private func lifecycleUpdated(state : PALifecycle.State) {
        switch state {
        case .create: controller.performCreate(itemUpdatePublisher)
        case .resume: controller.performResume()
        case .paused: controller.performPause()
        case .destroy: controller.performDestroy()
        default: return
        }
    }
    
    open func createController() -> PAController {
        preconditionFailure("Should override this method")
    }
    
    
}
