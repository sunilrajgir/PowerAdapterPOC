////  Converted to Swift 5.1 by Swiftify v5.1.31847 - https://swiftify.com/
////
////  MSSTabbedPageViewController.h
////  TabbedPageViewController
////
////  Created by Merrick Sapsford on 24/12/2015.
////  Copyright © 2015 Merrick Sapsford. All rights reserved.
////
//
////
////  MSSTabbedPageViewController.m
////  TabbedPageViewController
////
////  Created by Merrick Sapsford on 24/12/2015.
////  Copyright © 2015 Merrick Sapsford. All rights reserved.
////
//
//import ObjectiveC
//import UIKit
//
//enum MSSPageViewControllerScrollDirection : Int {
//    case unknown = -1
//    case backward = 0
//    case forward = 1
//}
//
//enum MSSPageViewControllerInfinitePagingBehavior : Int {
//    /// The infinite page behavior will be standard.
//    /// I.e. Going from last index to index 0 will have a forward transition, 
//    /// index 0 to last index will have a reverse transition.
//    case standard
//    /// The infinite page behavior will be reversed.
//    /// I.e. Going from last index to index 0 will have a reverse transition,
//    /// index 0 to last index will have a forward transition.
//    case reversed
//}
//
//typealias MSSPageViewControllerPageMoveCompletion = (UIViewController?, Bool, Bool) -> Void
//let MSSPageViewControllerPageNumberInvalid = -1
//
//@objc protocol MSSPageViewControllerDelegate: NSObjectProtocol {
//    /// The page view controller has scrolled to a new page offset.
//    /// - Parameters:
//    ///   - pageViewController:
//    /// The page view controller.
//    ///   - pageOffset: 
//    /// The updated page offset.
//    @objc optional func pageViewController(_ pageViewController: MSSPageViewController, didScrollToPageOffset pageOffset: CGFloat, direction scrollDirection: MSSPageViewControllerScrollDirection)
//    /// The page view controller has started a scroll to a new page.
//    /// - Parameters:
//    ///   - pageViewController:
//    /// The page view controller.
//    ///   - newPage:
//    /// The new visible page.
//    ///   - currentPage:
//    /// The new currently visible page.
//    @objc optional func pageViewController(_ pageViewController: MSSPageViewController, willScrollToPage newPage: Int, currentPage: Int)
//    /// The page view controller has completed scroll to a page.
//    /// - Parameters:
//    ///   - pageViewController:
//    /// The page view controller.
//    ///   - page:
//    /// The new currently visible page.
//    @objc optional func pageViewController(_ pageViewController: MSSPageViewController, didScrollToPage page: Int)
//    /// The page view controller has successfully prepared child view controllers ready for display.
//    /// - Parameters:
//    ///   - pageViewController:
//    /// The page view controller.
//    ///   - viewControllers:
//    /// The view controllers inside the page view controller.
//    @objc optional func pageViewController(_ pageViewController: MSSPageViewController, didPrepareViewControllers viewControllers: [AnyHashable])
//    /// The page view controller will display the initial view controller.
//    /// - Parameters:
//    ///   - pageViewController:
//    /// The page view controller.
//    ///   - viewController:
//    /// The initial view controller.
//    @objc optional func pageViewController(_ pageViewController: MSSPageViewController, willDisplayInitialViewController viewController: UIViewController)
//}
//
//@objc protocol MSSPageViewControllerDataSource: NSObjectProtocol {
//    /// The view controllers to display in the page view controller.
//    /// - Parameter pageViewController:
//    /// The page view controller.
//    /// - Returns: The array of view controllers.
//    func viewControllers(for pageViewController: MSSPageViewController) -> [UIViewController]?
//
//    /// The default page index for the page view controller to initially display.
//    /// - Parameter pageViewController:
//    /// The page view controller.
//    /// - Returns: The default page index.
//    @objc optional func defaultPageIndex(for pageViewController: MSSPageViewController) -> Int
//}
//
//class MSSPageViewController: UIViewController, MSSPageViewControllerDelegate, MSSPageViewControllerDataSource, UIScrollViewDelegate, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
//    private var viewHasLoaded = false
//
//    private var _defaultPageIndex = 0
//    var defaultPageIndex: Int {
//        if _defaultPageIndex == 0 && dataSource?.responds(to: #selector(MSSPageViewControllerDataSource.defaultPageIndex(for:))) ?? false {
//            _defaultPageIndex = dataSource?.defaultPageIndex?(for: self) ?? 0
//        }
//        return _defaultPageIndex
//    }
//
//    func setUp(_ viewController: UIViewController?, index: Int) {
//    }
//
//    /// The object that acts as a data source for the page view controller.
//
//    @IBOutlet private weak var _dataSource: MSSPageViewControllerDataSource?
//    @IBOutlet weak var dataSource: MSSPageViewControllerDataSource? {
//        get {
//            if _dataSource != nil {
//                return _dataSource
//            }
//            return self
//        }
//        set(dataSource) {
//            if viewHasLoaded && dataSource != self.dataSource {
//                _dataSource = dataSource
//                setUpPages()
//            }
//        }
//    }
//    /// The object that acts as a delegate for the page view controller.
//
//    @IBOutlet private weak var _delegate: MSSPageViewControllerDelegate?
//    @IBOutlet weak var delegate: MSSPageViewControllerDelegate? {
//        if _delegate != nil {
//            return _delegate
//        }
//        return self
//    }
//    /// The number of pages in the page view controller.
//    private(set) var numberOfPages = 0
//    /// The current active page index of the page view controller.
//    private(set) var currentPage = 0
//    /// The view controllers within the page view controller.
//    private(set) var viewControllers: [UIViewController]?
//    /// Whether page view controller will display the page indicator view.
//    var showPageIndicator = false
//    /// Whether page view controller will provide delegate updates on scroll events.
//    var allowScrollViewUpdates = false
//    /// Whether the user is currently dragging the page view controller.
//
//    private var _isDragging = false
//    var isDragging: Bool {
//        return scrollView?._isDragging ?? false
//    }
//    /// Whether scroll view interaction is enabled on the page view controller.
//
//    private var _scrollEnabled = false
//    var scrollEnabled: Bool {
//        get {
//            return scrollView?._scrollEnabled ?? false
//        }
//        set(scrollEnabled) {
//            scrollView?.isScrollEnabled = scrollEnabled
//        }
//    }
//    /// Whether user interaction is allowed on the page view controller.
//
//    private var _userInteractionEnabled = false
//    var userInteractionEnabled: Bool {
//        get {
//            return pageViewController?.view._userInteractionEnabled ?? false
//        }
//        set(userInteractionEnabled) {
//            pageViewController?.view.isUserInteractionEnabled = userInteractionEnabled
//        }
//    }
//    /// Whether page view controller will provide scroll updates when out of bounds.
//    var provideOutOfBoundsUpdates = false
//    /// Whether the page view controller is currently animating a page update.
//    private(set) var animatingPageUpdate = false
//    /// Allows the page view controller to scroll indefinitely when it reaches end of page range.
//    var infiniteScrollEnabled = false
//    /// The paging behavior to use when infinite scroll is enabled. This adjusts page transition animations
//    /// when using moveToPageAtIndex functions. MSSPageViewControllerInfinitePagingBehaviorStandard by default.
//    var infiniteScrollPagingBehaviour: MSSPageViewControllerInfinitePagingBehavior!
//
//    /// Move page view controller to a page at specific index.
//    /// - Parameter index:
//    /// The index of the page to display.
//    func moveToPage(at index: Int) {
//        moveToPage(at: index) { _,_,_ in }
//    }
//
//    /// Move page view controller to a page at specific index.
//    /// - Parameters:
//    ///   - index:
//    /// The index of the page to display.
//    ///   - completion:
//    /// Completion of the page move.
//    func moveToPage(at index: Int, completion: @escaping (UIViewController?, Bool, Bool) -> Void) {
//        moveToPage(at: index, animated: true, completion: completion)
//    }
//
//    /// Move page view controller to a page at specific index.
//    /// - Parameters:
//    ///   - index:
//    /// The index of the page to display.
//    ///   - animated:
//    /// Whether to animate the page transition.
//    ///   - completion:
//    /// Completion of the page move.
//    func moveToPage(at index: Int, animated: Bool, completion: MSSPageViewControllerPageMoveCompletion) {
//
//        if index != currentPage && !animatingPageUpdate {
//            animatingPageUpdate = true
//            view.isUserInteractionEnabled = false
//
//            var isForwards = index > currentPage
//            if infiniteScrollEnabled && infiniteScrollPagingBehaviour == .standard {
//                if index == 0 && currentPage == (viewControllers?.count ?? 0) - 1 {
//                    // moving to first page
//                    isForwards = true
//                } else if index == (viewControllers?.count ?? 0) - 1 && currentPage == 0 {
//                    // moving to last page
//                    isForwards = false
//                }
//            }
//
//            let viewController = self.viewController(at: index)
//            let direction: UIPageViewController.NavigationDirection = isForwards ? .forward : .reverse
//
//            weak var weakSelf = self
//            pageViewController?.setViewControllers([viewController].compactMap { $0 }, direction: direction, animated: animated) { finished in
//                let strongSelf = weakSelf
//                strongSelf?.updateCurrentPage(index)
//                if completion != nil {
//                    completion(viewController, animated, finished)
//                }
//            }
//        } else {
//            if completion != nil {
//                completion(nil, false, false)
//            }
//        }
//    }
//
//    /// UIScrollViewDelegate
//    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        animatingPageUpdate = false
//    }
//
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//
//        let pageWidth = scrollView.frame.size.width
//        let scrollOffset = scrollView.contentOffset.x - pageWidth
//
//        let currentXOffset = (CGFloat(currentPage) * pageWidth) + scrollOffset
//        var currentPagePosition = currentXOffset / pageWidth
//        let direction: MSSPageViewControllerScrollDirection = currentPagePosition > previousPagePosition ? .forward : .backward
//
//        // check if reached a page as page view controller delegate does not report reliably
//        // occurs when scrollview is continuously dragged
//        if !animatingPageUpdate && scrollView.isDragging {
//            if direction == .forward && currentPagePosition >= CGFloat(currentPage + 1) {
//                updateCurrentPage(currentPage + 1)
//                return // ignore update if we've changed page
//            } else if direction == .backward && currentPagePosition <= CGFloat(currentPage - 1) {
//                updateCurrentPage(currentPage - 1)
//                return
//            }
//        }
//
//        if currentPagePosition != previousPagePosition {
//
//            let minPagePosition: CGFloat = 0.0
//            let maxPagePosition = CGFloat(((viewControllers?.count ?? 0) - 1))
//
//            // limit updates if out of bounds updates are disabled
//            // updates will be limited to min of 0 and max of number of pages
//            let outOfBounds = currentPagePosition < minPagePosition || currentPagePosition > maxPagePosition
//            if outOfBounds {
//                if infiniteScrollEnabled {
//
//                    var integral: Double
//                    var progress = modf(fabs(Float(currentPagePosition)), &integral) // calculate transition progress
//                    var infiniteMaxPosition: CGFloat
//                    if currentPagePosition > 0 {
//                        // upper boundary - going to first page
//                        progress = 1.0 - progress
//                        infiniteMaxPosition = minPagePosition
//                    } else {
//                        // lower boundary - going to max page
//                        infiniteMaxPosition = maxPagePosition
//                    }
//
//                    // calculate relative position on overall transition
//                    var infinitePagePosition = (maxPagePosition - minPagePosition) * progress
//                    if (fmod(progress, 1.0) == 0.0) {
//                        infinitePagePosition = infiniteMaxPosition
//                    }
//
//                    currentPagePosition = infinitePagePosition
//                } else if !provideOutOfBoundsUpdates {
//                    currentPagePosition = max(0.0, min(currentPagePosition, numberOfPages - 1))
//                }
//            }
//
//            // check whether updates are allowed
//            if scrollUpdatesEnabled && allowScrollViewUpdates {
//                if delegate?.responds(to: #selector(MSSTabbedPageViewController.pageViewController(_:didScrollToPageOffset:direction:))) ?? false {
//                    delegate?.pageViewController?(self, didScrollToPageOffset: currentPagePosition, direction: direction)
//                }
//            }
//
//            previousPagePosition = currentPagePosition
//        }
//    }
//
//    private var pageViewController: UIPageViewController?
//    private var previousPagePosition: CGFloat = 0.0
//
//    private weak var _scrollView: UIScrollView?
//    private weak var scrollView: UIScrollView? {
//        if _scrollView == nil {
//            for subview in pageViewController?.view.subviews ?? [] {
//                if (subview is UIScrollView) {
//                    _scrollView = subview as? UIScrollView
//                    break
//                }
//            }
//        }
//        return _scrollView
//    }
//    private var scrollUpdatesEnabled = false
//
//// MARK: - Init
//    override init() {
//        super.init()
//            baseInit()
//    }
//
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//            baseInit()
//    }
//
//    func baseInit() {
//        provideOutOfBoundsUpdates = true
//        showPageIndicator = false
//        allowScrollViewUpdates = true
//        scrollUpdatesEnabled = true
//        infiniteScrollEnabled = false
//        currentPage = MSSPageViewControllerPageNumberInvalid
//    }
//
//// MARK: - Lifecycle
//    override func loadView() {
//        super.loadView()
//
//        if pageViewController == nil {
//            pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
//            pageViewController?.dataSource = self
//            pageViewController?.delegate = self
//        }
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        viewHasLoaded = true
//
//        pageViewController?.mss_add(toParentViewController: self, atZIndex: 0)
//        scrollView?.delegate = self
//
//        setUpPages()
//    }
//
//    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//
//        // disable scroll updates during rotation
//        scrollUpdatesEnabled = false
//        super.viewWillTransition(to: size, with: coordinator)
//        coordinator.animate(alongsideTransition: nil) { context in
//            self.scrollUpdatesEnabled = true
//        }
//    }
//
//// MARK: - Public
//
//// MARK: - Internal
//    func setUpPages() {
//
//        // view controllers
//        if dataSource?.responds(to: #selector(MSSPageViewControllerDataSource.viewControllers(for:))) ?? false {
//            viewControllers = dataSource?.viewControllers(for: self)
//        }
//
//        if (viewControllers?.count ?? 0) > 0 {
//            setUpViewControllers(viewControllers)
//
//            numberOfPages = viewControllers?.count ?? 0
//            currentPage = defaultPageIndex
//
//            if delegate?.responds(to: #selector(MSSPageViewControllerDelegate.pageViewController(_:didPrepareViewControllers:))) ?? false {
//                if let viewControllers = viewControllers {
//                    delegate?.pageViewController?(self, didPrepareViewControllers: viewControllers)
//                }
//            }
//
//            // display initial page
//            let viewController = self.viewController(at: currentPage)
//            if delegate?.responds(to: #selector(MSSPageViewControllerDelegate.pageViewController(_:willDisplayInitialViewController:))) ?? false {
//                if let viewController = viewController {
//                    delegate?.pageViewController?(self, willDisplayInitialViewController: viewController)
//                }
//            }
//            pageViewController?.setViewControllers([viewController].compactMap { $0 }, direction: .forward, animated: false)
//            scrollView?.isUserInteractionEnabled = true
//        } else {
//            scrollView?.isUserInteractionEnabled = false // disable scroll view if no pages
//        }
//    }
//
//    func setUpViewControllers(_ viewControllers: [AnyHashable]?) {
//        let index = 0
//        for viewController in viewControllers ?? [] {
//            guard let viewController = viewController as? UIViewController else {
//                continue
//            }
//            viewController.pageViewController = self
//            viewController.pageIndex = index
//            setUp(viewController, index: index)
//
//            index += 1
//        }
//    }
//
//    func viewController(at index: Int) -> UIViewController? {
//        if index < (viewControllers?.count ?? 0) {
//            return viewControllers?[index]
//        }
//        return nil
//    }
//
//    func indexOf(_ viewController: UIViewController?) -> Int {
//        if (viewControllers?.count ?? 0) > 0 {
//            if let viewController = viewController {
//                return viewControllers?.firstIndex(of: viewController) ?? NSNotFound
//            }
//            return 0
//        }
//        return NSNotFound
//    }
//
//    func updateCurrentPage(_ currentPage: Int) {
//        var currentPage = currentPage
//        if currentPage == self.currentPage {
//            return
//        }
//
//        if infiniteScrollEnabled {
//            if currentPage >= numberOfPages {
//                currentPage = 0
//            } else if currentPage < 0 {
//                currentPage = numberOfPages - 1
//            }
//        }
//
//        // has reached page
//        animatingPageUpdate = false
//        view.isUserInteractionEnabled = true
//
//        if currentPage >= 0 && currentPage < numberOfPages {
//            self.currentPage = currentPage
//            if delegate?.responds(to: #selector(MSSTabbedPageViewController.pageViewController(_:didScrollToPage:))) ?? false {
//                delegate?.pageViewController?(self, didScrollToPage: self.currentPage)
//            }
//        }
//    }
//
//// MARK: - Scroll View delegate
//
//// MARK: - Page View Controller data source
//    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
//        let currentIndex = indexOf(viewController)
//        var nextIndex = currentIndex
//
//        if nextIndex != NSNotFound {
//            if nextIndex != ((viewControllers?.count ?? 0) - 1) {
//                // standard increment
//                nextIndex += 1
//            } else if infiniteScrollEnabled {
//                // end of pages - reset to first if infinite scrolling
//                nextIndex = 0
//            }
//            if nextIndex != currentIndex {
//                return self.viewController(at: nextIndex)
//            }
//        }
//        return nil
//    }
//
//    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
//        let currentIndex = indexOf(viewController)
//        var nextIndex = currentIndex
//
//        if nextIndex != NSNotFound {
//            if nextIndex != 0 {
//                // standard decrement
//                nextIndex -= 1
//            } else if infiniteScrollEnabled {
//                // first index - reset to end if infinite scrolling
//                nextIndex = (viewControllers?.count ?? 0) - 1
//            }
//            if nextIndex != currentIndex {
//                return self.viewController(at: nextIndex)
//            }
//        }
//        return nil
//    }
//
//    func presentationCount(for pageViewController: UIPageViewController) -> Int {
//        if showPageIndicator {
//            return numberOfPages
//        }
//        return 0
//    }
//
//    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
//        if showPageIndicator {
//            return currentPage
//        }
//        return 0
//    }
//
//// MARK: - Page View Controller delegate
//    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
//
//        if delegate?.responds(to: #selector(MSSTabbedPageViewController.pageViewController(_:willScrollToPage:currentPage:))) ?? false {
//            let currentPage = self.currentPage
//            let nextPage = indexOf(pendingViewControllers.first)
//
//            delegate?.pageViewController?(self, willScrollToPage: nextPage, currentPage: currentPage)
//        }
//    }
//
//    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
//
//        if completed {
//            let index = indexOf(pageViewController.viewControllers?.first)
//            if index != NSNotFound {
//                updateCurrentPage(index)
//            }
//        }
//    }
//
//// MARK: - MSSPageViewController data source
//    @objc func viewControllers(for pageViewController: MSSPageViewController?) -> [AnyHashable]? {
//        return nil
//    }
//}
//
//extension UIViewController {
//    /// The page view controller of the parent
//
//    weak var pageViewController: MSSPageViewController? {
//        return objc_getAssociatedObject(self, #selector(pageViewController)) as? MSSPageViewController
//    }
//    /// The index of the current view controller
//
//    var pageIndex: Int {
//        return (objc_getAssociatedObject(self, #selector(PDFActionRemoteGoTo.pageIndex)) as? NSNumber)?.intValue ?? 0
//    }
//
//    func setPage(_ pageViewController: MSSPageViewController?) {
//        objc_setAssociatedObject(self, #selector(pageViewController), pageViewController, .OBJC_ASSOCIATION_ASSIGN)
//    }
//
//    func setPageIndex(_ pageIndex: Int) {
//        objc_setAssociatedObject(self, #selector(PDFActionRemoteGoTo.pageIndex), NSNumber(value: pageIndex), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//    }
//}
