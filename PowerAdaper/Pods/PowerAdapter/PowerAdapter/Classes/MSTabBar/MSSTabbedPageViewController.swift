////  Converted to Swift 5.1 by Swiftify v5.1.31847 - https://swiftify.com/
////
////  MSSTabbedPageViewController.swift
////  Paged Tabs Example
////
////  Created by Merrick Sapsford on 27/03/2016.
////  Copyright © 2016 Merrick Sapsford. All rights reserved.
////
//
//import ObjectiveC
//
//class MSSTabbedPageViewController: MSSPageViewController, MSSTabBarViewDataSource, MSSTabBarViewDelegate, UINavigationControllerDelegate {
//    /// The tab bar view.
//    @IBOutlet weak var tabBarView: MSSTabBarView?
//#if !MSS_APP_EXTENSIONS
//    private weak var tabNavigationBar: MSSTabNavigationBar?
//#endif
//    private var allowTabBarRequiredCancellation = false
//
//// MARK: - Lifecycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        provideOutOfBoundsUpdates = false
//    }
//
//#if !MSS_APP_EXTENSIONS
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        // set up navigation bar for tabbed page view if available
//        if type(of: navigationController?.navigationBar) === MSSTabNavigationBar.self && self.tabBarView == nil {
//            let navigationBar = navigationController?.navigationBar as? MSSTabNavigationBar
//            navigationController?.delegate = self
//            tabNavigationBar = navigationBar
//
//            let tabBarView = navigationBar?.tabBarView
//            tabBarView?.dataSource = self
//            tabBarView?.delegate = self
//            self.tabBarView = tabBarView
//            self.tabBarView?.isHidden = false
//
//            let isInitialController = navigationController?.viewControllers.first == self
//            navigationBar?.tabbedPageViewController(self, viewWillAppear: animated, isInitial: isInitialController)
//        }
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//
//        if tabNavigationBar != nil && (tabBarView == tabNavigationBar?.tabBarView) {
//
//            // if next view controller is not tabbed page view controller update navigation bar
//            allowTabBarRequiredCancellation = !(navigationController?.visibleViewController is MSSTabbedPageViewController)
//            if allowTabBarRequiredCancellation {
//                tabNavigationBar?.tabbedPageViewController(self, viewWillDisappear: animated)
//            }
//
//            // remove the current tab bar
//            tabBarView?.isHidden = true
//            tabBarView = nil
//        }
//    }
//
//#endif
//
//// MARK: - Public
//    func setDelegate(_ delegate: MSSPageViewControllerDelegate?) {
//        // only allow self to be page view controller delegate
//        if delegate == self as? MSSPageViewControllerDelegate {
//            super.delegate = delegate
//        }
//    }
//
//// MARK: - Tab bar data source
//    @objc func numberOfItems(for tabBarView: MSSTabBarView?) -> Int {
//        return viewControllers?.count ?? 0
//    }
//
//    @objc func tabBarView(_ tabBarView: MSSTabBarView?, populateTab tab: MSSTabBarCollectionViewCell?, at index: Int) {
//    }
//
//    @objc func defaultTabIndex(for tabBarView: MSSTabBarView?) -> Int {
//        if currentPage == MSSPageViewControllerPageNumberInvalid {
//            // return default page if page has not been moved
//            return defaultPageIndex
//        }
//        return currentPage
//    }
//
//// MARK: - Tab bar delegate
//    @objc func tabBarView(_ tabBarView: MSSTabBarView?, tabSelectedAt index: Int) {
//        if index != currentPage && !animatingPageUpdate && index < (viewControllers?.count ?? 0) {
//            allowScrollViewUpdates = false
//            userInteractionEnabled = false
//
//            self.tabBarView?.setTabIndex(index, animated: true)
//            weak var weakSelf = self
//            moveToPage(at: index) { newViewController, animated, transitionFinished in
//                let strongSelf = weakSelf
//                strongSelf?.allowScrollViewUpdates = true
//                strongSelf?.userInteractionEnabled = true
//            }
//        }
//    }
//
//// MARK: - Page View Controller delegate
//    override func pageViewController(_ pageViewController: MSSPageViewController?, didScrollToPageOffset pageOffset: CGFloat, direction scrollDirection: MSSPageViewControllerScrollDirection) {
//        tabBarView?.tabOffset = pageOffset
//    }
//
//    override func pageViewController(_ pageViewController: MSSPageViewController?, willScrollToPage newPage: Int, currentPage: Int) {
//        tabBarView?.isUserInteractionEnabled = false
//    }
//
//    override func pageViewController(_ pageViewController: MSSPageViewController?, didScrollToPage page: Int) {
//
//        if !isDragging {
//            tabBarView?.isUserInteractionEnabled = true
//        }
//        allowScrollViewUpdates = true
//        userInteractionEnabled = true
//    }
//
//// MARK: - Navigation Controller delegate
//
//#if !MSS_APP_EXTENSIONS
//    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
//
//        // Fix for navigation controller swipe back gesture
//        // Manually set tab bar to hidden if gesture was cancelled
//        weak var transitionCoordinator = navigationController.topViewController?.transitionCoordinator
//        transitionCoordinator?.notifyWhenInteractionEnds({ context in
//            if context?.isCancelled() != nil && self.allowTabBarRequiredCancellation {
//                self.tabNavigationBar?.tabBarRequired = false
//                self.tabNavigationBar?.setNeedsLayout()
//            }
//        })
//    }
//
//#endif
//
//// MARK: - Scroll View delegate
//    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        super.scrollViewWillBeginDragging(scrollView)
//        tabBarView?.isUserInteractionEnabled = false
//    }
//
//    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        if !decelerate {
//            tabBarView?.isUserInteractionEnabled = true
//        }
//    }
//
//    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        tabBarView?.isUserInteractionEnabled = true
//    }
//}
