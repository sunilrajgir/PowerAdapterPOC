//
//  PAFlipperViewPageSourceAndDelegate.swift
//  DeepDiff
//
//  Created by Prashant Rathore on 17/04/20.
//

import Foundation
import RxSwift

public protocol PAFlipperPageChangeDelegate : AnyObject {
    func onPageChanged(_ flipperView : PAFlipperView, pageIndex: Int)
}

public class PAFlipperViewPageSourceAndDelegate : PAFlipperViewDataSource, PAFlipperViewPageDelegate, ViewInteractor  {
    
    private let viewProvider : PASegmentViewProvider
    private let itemSource : PAItemControllerSource
    private var disposeBag = DisposeBag()
    private let parentLifecycle : PALifecycle
    weak var flipperView : PAFlipperView?
    private var currentPage : Int = 0
    public weak var pageChangeDelegate : PAFlipperPageChangeDelegate?
    private weak var parent : PAParent?
    private var primaryItem : PASegmentView?
        
    public init(_ viewProvider : PASegmentViewProvider, _ itemSource : PAItemControllerSource, _ parent : PAParent) {
        self.viewProvider = viewProvider
        self.itemSource = itemSource
        self.parent = parent
        self.parentLifecycle = parent.getLifecycle()
        itemSource.viewInteractor = self
    }
    
    public func bind(_ flipperView : PAFlipperView) {
        unBind()
        self.flipperView = flipperView
        flipperView.delegate = self
        flipperView.dataSource = self
        observeLifecycle()
        self.itemSource.observeAdapterUpdates()
            .map {[weak flipperView,weak self] (update) -> Bool in
            if(flipperView != nil) {
                self?.performUpdate(flipperView!, update)
            }
            return true
        }.subscribe().disposed(by: disposeBag)
        self.itemSource.onAttached()
    }
    
    private func observeLifecycle() {
        parentLifecycle.observeViewState().map {[weak self] (state) -> Bool in
            self?.syncLifecycle()
            return true
        }.subscribe().disposed(by: disposeBag)
    }
    
    private func syncLifecycle() {
        switch parentLifecycle.viewState {
        case .resume:
            primaryItem?.viewWillAppear()
            
        case .paused:
            primaryItem?.viewDidDisappear()
        default : return
        }
    }
    
    private func performUpdate(_ flipperView : PAFlipperView, _ update : PASourceUpdateEventModel) {
        if(update.type == .updateEnds) {
            self.primaryItem?.viewDidDisappear()
            self.primaryItem = nil
            self.currentPage = 0
            flipperView.reset()
        }
    }
    
    
    private func createIndexPathArray(_ section : Int,_ update : PASourceUpdateEventModel) -> [IndexPath] {
        var arr = [IndexPath]()
        for i in update.position..<update.position + update.itemCount {
            arr.append(IndexPath.init(row: i, section:section ))
        }
        return arr
    }
    
    public func numberOfPagesinFlipper(_ flipperView: PAFlipperView) -> Int {
        return  self.itemSource.itemCount
    }
    
    
    public func flipperView(_ flipperView : PAFlipperView, loadPageAt index: Int) -> UIView {
        let item = itemAtIndexPath(index)
        let page = self.viewProvider.segmentViewForType(flipperView, item.controller.getType())
        page.bindInternal(parent!, item)
        return page
    }
    
    
    public func flipperView(_ flipperView: PAFlipperView, willUnload page: UIView, at index: Int) {
        let tableCell = page as! PASegmentView
        tableCell.unBindInternal()
    }
    
    public func flipperView(_ flipperView: PAFlipperView, current page: UIView, at index: Int) {
        if(self.primaryItem != page) {
            let oldCell = self.primaryItem
            oldCell?.viewDidDisappear()
            self.currentPage = index
            let newCell = page as! PASegmentView
            self.primaryItem = newCell
        }
        syncLifecycle()
    }
    
    
    public func onPageChanged(_ flipperView: PAFlipperView, pageIndex: Int) {
        self.pageChangeDelegate?.onPageChanged(flipperView, pageIndex: pageIndex)
    }
    
    
    public func itemAtIndexPath(_ index: Int) -> PAItemController {
        return self.itemSource.getItem(index)
    }
    
    
    
    func unBind() {
        self.flipperView?.delegate = nil
        self.flipperView?.dataSource = nil
        self.flipperView = nil
        itemSource.onDetached()
        disposeBag = DisposeBag()
        self.primaryItem = nil
        currentPage = 0
        pageChangeDelegate = nil
    }

    
}


extension PAFlipperViewPageSourceAndDelegate {
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
      
}
