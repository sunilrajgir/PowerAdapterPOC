//
//  PALifecycleRegistry.swift
//  DeepDiff
//
//  Created by Prashant Rathore on 05/04/20.
//

import Foundation
import RxSwift

public class PALifecycleRegistry {
    
    
    public let lifecycle = PALifecycle()
    
    private var isInView = false
    private let parentLifecycle : PALifecycle?
    private let disposeBag = DisposeBag()
    
    
    
    public init(_ parentLifecycle : PALifecycle?) {
        self.parentLifecycle = parentLifecycle
        observeParentLifecycle()
    }
    
    
    public func create() {
        switch lifecycle.viewState {
        case .initialized,.create : self.lifecycle.setViewState(state: .create);
        default : return
        }
    }
    
    private func observeParentLifecycle() {
        parentLifecycle?.observeViewState()
            .map({[weak self] (value) -> PALifecycle.State in
                self?.lifecycleUpdates(value)
                return value
            }).subscribe().disposed(by: disposeBag)
    }
    
    private func lifecycleUpdates(_ state : PALifecycle.State) {
        switch state {
        case .resume: viewWillAppearInternal()
        case .paused, .destroy: viewDidDisapperInternal()
        default: return
        }
    }
    
    
    private func viewWillAppearInternal() {
        if(self.isInView && self.parentLifecycle?.viewState ?? .resume == PALifecycle.State.resume) {
            switch lifecycle.viewState {
            case .create,.paused : self.lifecycle.setViewState(state: .resume);
            default : return
            }
        }
    }
    
    public func viewWillAppear() {
        create()
        if(!self.isInView) {
            self.isInView = true
            viewWillAppearInternal()
        }
    }
    
    private func viewDidDisapperInternal() {
        switch lifecycle.viewState {
        case .resume : self.lifecycle.setViewState(state: .paused);
        default : return
        }
    }
    
    
    
    public func viewDidDisappear() {
        create()
        if(self.isInView) {
            self.isInView = false
            viewDidDisapperInternal()
        }
    }
    
    public func destroy() {
        viewDidDisappear()
        self.lifecycle.setViewState(state: .destroy);
    }
    
}
