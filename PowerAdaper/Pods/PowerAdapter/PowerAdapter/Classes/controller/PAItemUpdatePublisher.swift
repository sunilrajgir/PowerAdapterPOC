//
//  PAItemUpdatePublisher.swift
//  PowerAdapter
//
//  Created by Prashant Rathore on 14/02/20.
//  Copyright © 2020 Prashant Rathore. All rights reserved.
//

import Foundation
import RxSwift

public class PAItemUpdatePublisher {
    
    private let updateEventPublisher = ReplaySubject<Any>.create(bufferSize: 1)
    
    func observeEvents() -> Observable<Any> {
        return updateEventPublisher
    }

    func notifyItemUpdated(itemController: Any) {
        updateEventPublisher.onNext(itemController)
    }
}
