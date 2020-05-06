//  Converted to Swift 5.1 by Swiftify v5.1.31847 - https://swiftify.com/
//
//  UIViewController+MSSUtilities.swift
//  TabbedPageViewController
//
//  Created by Merrick Sapsford on 13/01/2016.
//  Copyright © 2016 Merrick Sapsford. All rights reserved.
//

import UIKit

extension UIViewController {
    func mss_add(toParentViewController parentViewController: UIViewController?) {
        mss_add(toParentViewController: parentViewController, atZIndex: MSSViewDefaultZIndex)
    }

    func mss_add(toParentViewController parentViewController: UIViewController?, atZIndex index: Int) {
        mss_add(toParentViewController: parentViewController, with: parentViewController?.view, atZIndex: index)
    }

    func mss_add(toParentViewController parentViewController: UIViewController?, with view: UIView?) {
        mss_add(toParentViewController: parentViewController, with: view, atZIndex: MSSViewDefaultZIndex)
    }

    func mss_add(toParentViewController parentViewController: UIViewController?, with view: UIView?, atZIndex index: Int) {
        if parent != nil {
            self.view.removeFromSuperview()
            removeFromParent()
        }

        parentViewController?.addChild(self)
        view?.mss_addExpandingSubview(self.view, edgeInsets: .zero, atZIndex: index)
        didMove(toParent: parentViewController)
    }
}