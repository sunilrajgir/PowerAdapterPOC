//  Converted to Swift 5.1 by Swiftify v5.1.31847 - https://swiftify.com/
//
//  MSSTabNavigationBar.swift
//  Paged Tabs Example
//
//  Created by Merrick Sapsford on 27/03/2016.
//  Copyright © 2016 Merrick Sapsford. All rights reserved.
//

let kMSSTabNavigationBarLayoutParameterInvalid: CGFloat = -1.0
let kMSSTabNavigationBarBottomPadding: CGFloat = 4.0

class MSSTabNavigationBar: MSSCustomHeightNavigationBar, MSSTabBarViewDelegate, MSSTabBarViewDataSource {
    func tabTitles(for tabBarView: MSSTabBarView) -> [String]? {
        return nil
    }
    
    func tabBarView(_ tabBarView: MSSTabBarView, tabSelectedAt index: Int) {
        
    }
    
    
    var tabBarRequired: Bool = false {
        didSet {
            tabBarView?.alpha = CGFloat(tabBarRequired ? 1 : 0)
            tabBarView?.isUserInteractionEnabled = tabBarRequired
        }
    }

//    func tabbedPageViewController(_ tabbedPageViewController: MSSTabbedPageViewController?, viewWillAppear animated: Bool, isInitial: Bool) {
//        activeTabbedPageViewController = tabbedPageViewController
//
//        offsetTransformRequired = isInitial
//        setTabBarRequired(true, animated: animated)
//    }
//
//    func tabbedPageViewController(_ tabbedPageViewController: MSSTabbedPageViewController?, viewWillDisappear animated: Bool) {
//        if tabbedPageViewController == activeTabbedPageViewController {
//            setTabBarRequired(false, animated: animated)
//        }
//    }

    /// The tab bar view in the navigation bar.
    private(set) var tabBarView: MSSTabBarView?
    /// The height for the tab bar in the navigation bar.
    /// Default: 44px.

    @IBInspectable private var _tabBarHeight: CGFloat = 0.0
    @IBInspectable var tabBarHeight: CGFloat {
        get {
            if _tabBarHeight == kMSSTabNavigationBarLayoutParameterInvalid {
                return MSSTabBarViewDefaultHeight
            }
            return _tabBarHeight
        }
        set(tabBarHeight) {
            _tabBarHeight = tabBarHeight
            setNeedsLayout()
        }
    }
    /// The padding to use between the bottom of the tab bar and navigation bar.
    /// Default: 4px.

    @IBInspectable private var _tabBarBottomPadding: CGFloat = 0.0
    @IBInspectable var tabBarBottomPadding: CGFloat {
        get {
            if _tabBarBottomPadding == kMSSTabNavigationBarLayoutParameterInvalid {
                return kMSSTabNavigationBarBottomPadding
            }
            return _tabBarBottomPadding
        }
        set(tabBarBottomPadding) {
            _tabBarBottomPadding = tabBarBottomPadding
            setNeedsLayout()
        }
    }
//    private weak var activeTabbedPageViewController: MSSTabbedPageViewController?

// MARK: - Init
    override func baseInit() {
        super.baseInit()

        tabBarHeight = kMSSTabNavigationBarLayoutParameterInvalid
        tabBarBottomPadding = kMSSTabNavigationBarLayoutParameterInvalid

        let tabBarView = MSSTabBarView()
        tabBarView.dataSource = self
        tabBarView.delegate = self
        tabBarView.tintColor = tintColor
        addSubview(tabBarView)
        self.tabBarView = tabBarView

        //tabBarRequired = tabBarRequired    // Skipping redundant initializing to itself
    }

// MARK: - Lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()

        let tabBarHeight = heightIncreaseValue() - tabBarBottomPadding
        let yOffset = heightIncreaseRequired() ? 0.0 : -heightIncreaseValue() // offset y if tab hidden to animate up

        tabBarView?.frame = CGRect(x: 0.0, y: bounds.size.height + yOffset, width: bounds.size.width, height: tabBarHeight)
    }

    override func heightIncreaseValue() -> CGFloat {
        return tabBarHeight + tabBarBottomPadding
    }

    override func heightIncreaseRequired() -> Bool {
        return tabBarRequired
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {

        if tabBarView?.frame.contains(point) ?? false && tabBarView?.isUserInteractionEnabled ?? false && tabBarRequired {
            let tabBarPoint = tabBarView?.convert(point, from: self)
            return tabBarView?.hitTest(tabBarPoint ?? CGPoint.zero, with: event)
        }

        let hitView = super.hitTest(point, with: event)
        return hitView
    }

// MARK: - Public
    override var tintColor: UIColor! {
        get {
            return super.tintColor
        }
        set(tintColor) {
            super.tintColor = tintColor
            tabBarView?.tintColor = tintColor
        }
    }

    override var titleTextAttributes: [NSAttributedString.Key : Any]? {
        didSet{
            var foregroundColor: UIColor? = nil
            if (foregroundColor = titleTextAttributes?[NSAttributedString.Key.foregroundColor] as? UIColor) != nil {
                var tabAttributes = tabBarView?.tabAttributes ?? [:]
                tabAttributes[NSAttributedString.Key.foregroundColor.rawValue] = foregroundColor
                tabBarView?.tabAttributes = tabAttributes
            }
        }
    }

// MARK: - Private

// MARK: - Internal
    func setTabBarRequired(_ `required`: Bool, animated: Bool) {
        if tabBarRequired != `required` {

            // show or hide tab bar view
            let tabVisiblityBlock: (() -> Void)? = {
                    self.tabBarRequired = `required`
                    self.layoutIfNeeded()
                }

            if animated {
                UIView.animate(withDuration: 0.3, animations: {
                    tabVisiblityBlock?()
                })
            } else {
                tabVisiblityBlock?()
            }
        }
    }

// MARK: - Tab Bar data source
    @objc func numberOfItems(for tabBarView: MSSTabBarView) -> Int {
        return 0
    }

    @objc func tabBarView(_ tabBarView: MSSTabBarView, populateTab tab: MSSTabBarCollectionViewCell, at index: Int) {
    }
}
