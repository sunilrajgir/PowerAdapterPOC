//  Converted to Swift 5.1 by Swiftify v5.1.31847 - https://swiftify.com/
//
//  MSSCustomHeightNavigationBar.swift
//  Paged Tabs Example
//
//  Created by Merrick Sapsford on 27/03/2016.
//  Copyright © 2016 Merrick Sapsford. All rights reserved.
//

import UIKit

let MSSStandardBarHeightInvalid: CGFloat = -1.0

class MSSCustomHeightNavigationBar: UINavigationBar {
    private var _offsetTransformRequired = false
    var offsetTransformRequired: Bool {
        get {
            _offsetTransformRequired
        }
        set(`required`) {
            if `required` {
                transform = CGAffineTransform(translationX: 0, y: -(heightIncreaseValue()))
            } else {
                transform = .identity
            }
        }
    }

    func baseInit() {
        standardBarHeight = MSSStandardBarHeightInvalid
    }

    func heightIncreaseValue() -> CGFloat {
        return 0.0
    }

    func heightIncreaseRequired() -> Bool {
        return true
    }

    private var standardBarHeight: CGFloat = 0.0

// MARK: - Init
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
            baseInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
            baseInit()
    }

// MARK: - Lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()

        let classNamesToReposition = MSS_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO("10.0") ? ["_UIBarBackground"] : ["_UINavigationBarBackground"]
        for view in subviews {

            if classNamesToReposition.contains(NSStringFromClass(type(of: view).self)) {

                let bounds = self.bounds
                var frame = view.frame
                let statusBarFrame = UIApplication.shared.statusBarFrame
                let heightIncrease = heightIncreaseRequired() ? heightIncreaseValue() : 0.0
                let statusBarHeight = UIApplication.shared.isStatusBarHidden ? 0.0 : statusBarFrame.size.height

                if !(transform == .identity) {
                    frame.origin.y = bounds.origin.y + heightIncrease - statusBarHeight
                    frame.size.height = bounds.size.height + statusBarHeight
                } else {
                    frame.origin.y = -statusBarHeight
                    frame.size.height = bounds.size.height + statusBarHeight + heightIncrease
                }

                view.frame = frame
            }
        }
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var originalSize = super.sizeThatFits(size)

        // capture original size
        if standardBarHeight == MSSStandardBarHeightInvalid {
            standardBarHeight = originalSize.height
        }

        // if a transform is active always account for the height increase
        if !transform.isIdentity {
            originalSize.height += heightIncreaseValue()
        } else {
            originalSize.height += safeHeightIncreaseValue()
        }
        return originalSize
    }

// MARK: - Public

// MARK: - Internal
    func safeHeightIncreaseValue() -> CGFloat {
        if heightIncreaseRequired() && frame.size.height == standardBarHeight {
            return heightIncreaseValue()
        }
        return 0.0
    }
}

func MSS_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(_ v: String) -> Bool {
    UIDevice.current.systemVersion.compare(v, options: .numeric, range: nil, locale: .current) != .orderedAscending
}
