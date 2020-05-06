//
//  PALifecycle.swift
//  PowerAdapter
//
//  Created by Prashant Rathore on 06/04/20.
//

import Foundation
import RxSwift

public class PALifecycle  {
    
    public enum State {
        case initialized
        case create
        case resume
        case paused
        case destroy
    }
    
    public private(set) var viewState : State {
        didSet {
            viewStatePublisher.onNext(self.viewState)
        }
    }
    
    private let viewStatePublisher = BehaviorSubject(value: State.initialized)
    
    public init() {
        self.viewState = .initialized
    }
    
    func observeViewState() -> Observable<State> {
        return viewStatePublisher.distinctUntilChanged()
    }
    
    
    internal func setViewState(state : State) {
        self.viewState = state
    }
    
    
}
