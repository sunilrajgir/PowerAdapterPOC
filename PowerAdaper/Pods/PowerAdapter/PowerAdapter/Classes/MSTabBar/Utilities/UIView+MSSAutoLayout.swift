//  Converted to Swift 5.1 by Swiftify v5.1.31847 - https://swiftify.com/
//
//  UIView+MSSAutoLayout.swift
//  TabbedPageViewController
//
//  Created by Merrick Sapsford on 24/12/2015.
//  Copyright © 2015 Merrick Sapsford. All rights reserved.
//

import UIKit

let MSSViewDefaultZIndex = -1

extension UIView {
    func mss_addExpandingSubview(_ subview: UIView?) {
        mss_addExpandingSubview(subview, edgeInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
    }

    func mss_addExpandingSubview(_ subview: UIView?, edgeInsets insets: UIEdgeInsets) {
        mss_addExpandingSubview(subview, edgeInsets: insets, atZIndex: MSSViewDefaultZIndex)
    }

    func mss_addExpandingSubview(_ subview: UIView?, edgeInsets insets: UIEdgeInsets, atZIndex index: Int) {
        add(subview, atZIndex: index)
        let views = [
            "subview" : subview
        ]

        let verticalConstraints = "V:|-\(insets.top)-[subview]-\(insets.bottom)-|"
        let horizontalConstraints = "H:|-\(insets.left)-[subview]-\(insets.right)-|"
        if let views = views as? [String : Any] {
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: verticalConstraints, options: [], metrics: nil, views: views))
        }
        if let views = views as? [String : Any] {
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: horizontalConstraints, options: [], metrics: nil, views: views))
        }
    }

    func mss_addPinned(toTopAndSidesSubview subview: UIView?, withHeight height: CGFloat) {
        add(subview, atZIndex: MSSViewDefaultZIndex)
        let views = [
            "subview" : subview
        ]

        let metrics = [
            "viewHeight": NSNumber(value: Float(height))
        ]
        let verticalConstraints = "V:|-[subview(viewHeight)]"
        let horizontalConstraints = "H:|-[subview]-|"
        if let views = views as? [String : Any] {
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: verticalConstraints, options: [], metrics: metrics, views: views))
        }
        if let views = views as? [String : Any] {
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: horizontalConstraints, options: [], metrics: nil, views: views))
        }
    }

    func mss_clearSubviews() {
        for subview in subviews {
            subview.removeFromSuperview()
        }
    }

// MARK: - Utils

// MARK: - Internal
    func add(_ subview: UIView?, atZIndex index: Int) {
        if subview?.superview != nil {
            subview?.removeFromSuperview()
        }
        if index >= 0 {
            if let subview = subview {
                insertSubview(subview, at: index)
            }
        } else {
            if let subview = subview {
                addSubview(subview)
            }
        }
        subview?.translatesAutoresizingMaskIntoConstraints = false
    }
}