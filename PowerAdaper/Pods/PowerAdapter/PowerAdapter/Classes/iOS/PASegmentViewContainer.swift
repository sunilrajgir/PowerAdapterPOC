//
//  PASegmentViewContainer.swift
//  PowerAdapter
//
//  Created by Prashant Rathore on 09/04/20.
//

import Foundation
import UIKit
import RxSwift

public class PASegmentViewContainer: UIView, PAParent {
    
    private weak var parent : PAParent?
    private var parentLifecycle : PALifecycle?
    
    private var segment : PASegment?
    private var disposeBag = DisposeBag()
    private let itemUpdatePublisher = PAItemUpdatePublisher()
    
    public func bindParent(_ parent : PAParent) {
        if(self.parent == nil) {
            self.parent = parent
            self.parentLifecycle = parent.getLifecycle()
        }
    }
    
    public func setSegment(_ segment : PASegment) {
        removeSegment()
        self.segment = segment
        addSubview(segment.segmentView)
        observeLifecycle()
    }
    
    private func observeLifecycle() {
        self.parentLifecycle!.observeViewState()
            .map {[weak self] (state) -> PALifecycle.State in
                self?.syncCurrentState()
                return state
            }.subscribe().disposed(by: disposeBag)
    }
    
    private func syncCurrentState() {
        if let segment = self.segment {
            switch self.parentLifecycle!.viewState {
            case .create:
                segment.itemController.performCreate(itemUpdatePublisher)
                segment.segmentView.bindInternal(self,segment.itemController)
                segment.currentState = .CREATE
            case .resume:
                if(segment.currentState == .FRESH) {
                    segment.itemController.performCreate(itemUpdatePublisher)
                    segment.segmentView.bindInternal(self,segment.itemController)
                }
                segment.segmentView.viewWillAppear()
                segment.currentState = .RESUME
            case .paused:
                if(segment.currentState == .FRESH) {
                    segment.itemController.performCreate(itemUpdatePublisher)
                    segment.segmentView.bindInternal(self,segment.itemController)
                }
                segment.itemController.performPause()
            case .destroy :
                if(segment.currentState != .FRESH) {
                    segment.segmentView.unBind()
                }
                segment.itemController.performDestroy()
            default : return
            }
            

        }
    }
    
    public func removeSegment() {
        if let segment = self.segment {
            self.disposeBag = DisposeBag()
            segment.segmentView.viewDidDisappear()
            segment.segmentView.removeFromSuperview()
            segment.segmentView.unBind()
            segment.itemController.performDestroy()
            self.segment = nil
        }
    }
    
    public func getParent() -> PAParent? {
        return self.parent
    }
    
    public func getLifecycle() -> PALifecycle {
        return self.parentLifecycle!
    }
    
    public func getRootParent() -> PAParent {
        if(self.parent == nil) {
            return self
        }
        else {
            return self.parent!.getRootParent()
        }

    }
    
    public func unbind() {
        
    }
    
    
    
    
    
}
