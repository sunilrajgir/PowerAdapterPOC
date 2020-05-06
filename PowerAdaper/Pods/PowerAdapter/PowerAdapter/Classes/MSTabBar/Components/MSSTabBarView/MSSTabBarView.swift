//  Converted to Swift 5.1 by Swiftify v5.1.31847 - https://swiftify.com/
//
//  MSSTabBarView.swift
//  TabbedPageViewController
//
//  Created by Merrick Sapsford on 13/01/2016.
//  Copyright © 2016 Merrick Sapsford. All rights reserved.
//

import UIKit

public enum MSSTabTransitionStyle : Int {
    case progressive
    case snap
}

public enum MSSIndicatorStyle : Int {
    case line
    case image
}

//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wdeprecated-declarations"
// defaults
let MSSTabBarViewDefaultHeight: CGFloat = 44.0
let MSSTabBarViewDefaultTabIndicatorHeight: CGFloat = 2.0
let MSSTabBarViewDefaultTabPadding: CGFloat = 8.0
let MSSTabBarViewDefaultTabUnselectedAlpha: CGFloat = 0.3
let MSSTabBarViewDefaultHorizontalContentInset: CGFloat = 8.0
let MSSTabBarViewDefaultTabTitleFormat = "Tab %li"
let MSSTabBarViewDefaultScrollEnabled = false
let MSSTabBarViewMaxDistributedTabs = 5
let MSSTabBarViewTabTransitionSnapRatio: CGFloat = 0.5
let MSSTabBarViewTabOffsetInvalid: CGFloat = -1.0
private var _sizingCell: MSSTabBarCollectionViewCell?

@objc public protocol MSSTabBarViewDataSource: NSObjectProtocol {
    /// The number of items to display in the tab bar.
    /// - Parameter tabBarView:
    /// The tab bar view.
    /// - Returns: the number of tab bar items.
    func numberOfItems(for tabBarView: MSSTabBarView) -> Int
    /// Populate a tab bar item.
    /// - Parameters:
    ///   - tabBarView:
    /// The tab bar view.
    ///   - tab:
    /// The tab to populate.
    ///   - index:
    /// The index of the tab.
    func tabBarView(_ tabBarView: MSSTabBarView, populateTab tab: MSSTabBarCollectionViewCell, at index: Int)

    /// The tab titles to display in the tab bar.
    /// - Parameter tabBarView:
    /// The tab bar view.
    /// - Returns: The array of tab titles.
    func tabTitles(for tabBarView: MSSTabBarView) -> [String]?
    /// The default tab index to to display in the tab bar.
    /// - Parameter tabBarView:
    /// The tab bar view.
    /// - Returns:
    /// The default tab index.
    @objc optional func defaultTabIndex(for tabBarView: MSSTabBarView) -> Int
}

@objc public  protocol MSSTabBarViewDelegate: NSObjectProtocol {
    /// A tab has been selected.
    /// - Parameters:
    ///   - tabBarView:
    /// The tab bar view.
    ///   - index:
    /// The index of the selected tab.
    func tabBarView(_ tabBarView: MSSTabBarView, tabSelectedAt index: Int)
}

public class MSSTabBarView: UIView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    public var tabOffset: CGFloat = 0.0 {
        willSet {
            previousTabOffset = self.tabOffset
        }
        didSet {
            updateTabBar(forTabOffset: tabOffset)
        }
    }
    /// The object that acts as the data source for the tab bar.

    @IBOutlet public weak var dataSource: MSSTabBarViewDataSource? {
        didSet {
            animateDataSourceTransition = false
            reset()
            //        if dataSource?.responds(to: #selector(MSSTabbedPageViewController.defaultTabIndex(for:))) ?? false {
                        defaultTabIndex = dataSource?.defaultTabIndex?(for: self) ?? 0
            //        }
            collectionView?.reloadData()
            setNeedsLayout()
                
        }
    }
    /// The object that acts as a delegate for the tab bar.
    @IBOutlet public weak var delegate: MSSTabBarViewDelegate?
    /// The number of tabs in the tab bar.
    private(set) var tabCount = 0
    /// Whether the tab bar is currently animating a tab change transition.
    private(set) var animatingTabChange = false
    /// Whether the user can manually scroll the tab bar.

    private var _scrollEnabled = false
    public var scrollEnabled: Bool {
        get {
            return collectionView?.isScrollEnabled ?? false
        }
        set(scrollEnabled) {
            collectionView?.isScrollEnabled = scrollEnabled
        }
    }
    /// The background view for the tab bar.

    private var _backgroundView: UIView?
    public var backgroundView: UIView? {
        get {
            _backgroundView
        }
        set(backgroundView) {
            _backgroundView = backgroundView
            mss_addExpandingSubview(backgroundView)
            if let backgroundView = backgroundView {
                sendSubviewToBack(backgroundView)
            }
        }
    }
    /// The internal horizontal label padding value for each tab.
    public var tabPadding : CGFloat!
    /// The content inset for the tabs.
    public var contentInset: UIEdgeInsets!
    /// The sizing style to use for tabs in the tab bar.
    /// MSSTabSizingStyleSizeToFit - size tabs to the size of their contents.
    /// MSSTabSizingStyleDistributed - distribute the tabs equally in the frame of the tab bar (Max 5).
    public var sizingStyle: MSSTabSizingStyle = .sizeToFit
    /// The style for tabs in the tab bar.
    /// MSSTabStyleImage - use images as the content for each tab.
    /// MSSTabStyleText - use text as the content for each tab.
    public var tabStyle: MSSTabStyle! {
        didSet {
            _sizingCell?.tabStyle = tabStyle
            reloadData()
        }
    }
    /// The style for the tab indicator.
    /// MSSIndicatorStyleLine - use a coloured line as the indicator (default).
    /// MSSIndicatorStyleImage - use an image as the indicator.
    public  var indicatorStyle: MSSIndicatorStyle!
    /// The appearance attributes for tabs.
    /// Available attributes:
    /// NSForegroundColorAttributeName, NSFontAttributeName, NSBackgroundColorAttributeName
    public var tabAttributes: [String : Any]? {
        didSet {
            reloadData()
        }
    }
    /// The appearance attributes for selected tabs.
    /// Available attributes:
    /// NSForegroundColorAttributeName, NSFontAttributeName, NSBackgroundColorAttributeName
    public var selectedTabAttributes: [String : Any]?
    /// The appearance attributes for the tab indicator.
    public var indicatorAttributes: [String : Any]? {
        didSet {
            updateIndicatorAppearance()
        }
    }
    /// The transition style for the tabs to use during transitioning.
    public var tabTransitionStyle: MSSTabTransitionStyle!
    /// The transition style for the tab indicator to use during transitioning.
    public var indicatorTransitionStyle: MSSTabTransitionStyle = .progressive
    /// Whether the tab bar contents can be scrolled.

    public var userScrollEnabled: Bool {
        get {
            return scrollEnabled
        }
        set(userScrollEnabled) {
            scrollEnabled = userScrollEnabled
        }
    }
    /// The transition style for the selection indicator to use during transitioning.
    public var selectionIndicatorTransitionStyle: MSSTabTransitionStyle!
    /// The height of the selection indicator.
    public var selectionIndicatorHeight: CGFloat!
    /// The color of the tab selection indicator.
    public  var tabIndicatorColor: UIColor? {
        didSet {
            if indicatorStyle == .line {
                indicatorView?.backgroundColor = tabIndicatorColor
            }
        }
    }
    /// The text color of the tabs.
    public var tabTextColor: UIColor? {
        didSet {
            reloadData()
        }
    }
    /// The font used for the tabs. A nil value uses the default font from the cell nib.
    public var tabTextFont: UIFont? {
        didSet {
            reloadData()
        }
    }

    /// Initialize a tab bar with a specified height.
    /// - Parameter height:
    /// The height for the tab bar.
    /// - Returns: Tab bar instance.

    /// Set the current selected tab index of the tab bar.
    /// - Parameters:
    ///   - index:
    /// The index of the current tab.
    ///   - animated:
    /// Animate the tab index transition.
    public func setTabIndex(_ index: Int, animated: Bool) {
        collectionView?.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: false)
        DispatchQueue.main.async {
            if animated {
                self.animatingTabChange = true
                UIView.animate(withDuration: 0.25, animations: {
                    self.updateTabBar(forTabIndex: index)
                }) { finished in
                    self.animatingTabChange = false
                }
            } else {
                self.updateTabBar(forTabIndex: index)
            }
            
        }
    }

    /// Set the data source of the tab bar.
    /// - Parameters:
    ///   - dataSource:
    /// The data source.
    ///   - animated:
    /// Animate the data source transition.
    public func setDataSource(_ dataSource: MSSTabBarViewDataSource?, animated: Bool) {
        animateDataSourceTransition = animated
        self.dataSource = dataSource
    }

    /// Set the tab and selection indicator transition style.
    func setTransitionStyle(_ transitionStyle: MSSTabTransitionStyle) {
        selectionIndicatorTransitionStyle = transitionStyle
        tabTransitionStyle = transitionStyle
    }

    private var tabTitles: [AnyHashable]?
    private var collectionView: UICollectionView?
    private weak var selectedCell: MSSTabBarCollectionViewCell?
    private var selectedIndexPath: IndexPath?
    private var indicatorContainer: UIView?
    private var indicatorView: UIView?

    private var _lineIndicatorHeight: CGFloat = 0.0
    public var lineIndicatorHeight: CGFloat {
        get {
            _lineIndicatorHeight
        }
        set(lineIndicatorHeight) {
            if lineIndicatorHeight != _lineIndicatorHeight {
                _lineIndicatorHeight = lineIndicatorHeight
                updateIndicatorFrames()
            }
        }
    }
    private var lineIndicatorInset: CGFloat = 0.0
    private var height: CGFloat = 0.0
    private var previousTabOffset: CGFloat = 0.0

    private var _defaultTabIndex = 0
    private var defaultTabIndex: Int {
        get {
            _defaultTabIndex
        }
        set(defaultTabIndex) {
            if tabOffset == MSSTabBarViewTabOffsetInvalid {
                // only allow default to be set if tab is runtime default
                hasRespectedDefaultTabIndex = false
                _defaultTabIndex = defaultTabIndex
            }
        }
    }

    private var _tabDeselectedAlpha: CGFloat = 0.0
    private var tabDeselectedAlpha: CGFloat {
        if _tabDeselectedAlpha == 0.0 {
            return MSSTabBarViewDefaultTabUnselectedAlpha
        } else {
            return _tabDeselectedAlpha
        }
    }
    private var hasRespectedDefaultTabIndex = false
    private var animateDataSourceTransition = false
    
    public var cellNibName : String = "MSSTabBarCollectionViewCell"

// MARK: - Init

    required init?(coder: NSCoder) {
        preconditionFailure()
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        baseInit()
    }

    func baseInit() {

        // General
        tabPadding = MSSTabBarViewDefaultTabPadding
        let horizontalInset = MSSTabBarViewDefaultHorizontalContentInset
        contentInset = UIEdgeInsets(top: 0.0, left: horizontalInset, bottom: 0.0, right: horizontalInset)
        tabOffset = MSSTabBarViewTabOffsetInvalid

        if height == 0.0 {
            height = MSSTabBarViewDefaultHeight
        }

        // Collection view
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView?.dataSource = self
        collectionView?.delegate = self
        scrollEnabled = MSSTabBarViewDefaultScrollEnabled
        tabTextColor = UIColor.black

        // Tab indicator
        indicatorContainer = UIView()
        indicatorStyle = MSSIndicatorStyle.line
        indicatorContainer?.isUserInteractionEnabled = false
        indicatorAttributes = [
        MSSTabIndicatorLineHeight: NSNumber(value: Float(MSSTabBarViewDefaultTabIndicatorHeight)),
        NSAttributedString.Key.foregroundColor.rawValue : tintColor
        ]
    }

// MARK: - Lifecycle
    override public func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)

        if collectionView?.superview == nil {

            // create sizing cell if required
            let nibName = String(NSStringFromClass(MSSTabBarCollectionViewCell.self).split(separator: ".")[1])
            let cellNib = UINib(nibName:nibName , bundle: Bundle(for: MSSTabBarCollectionViewCell.self))
            collectionView?.register(cellNib, forCellWithReuseIdentifier: cellNibName)
                _sizingCell = cellNib.instantiate(withOwner: self, options: nil)[0] as? MSSTabBarCollectionViewCell

            // collection view
            mss_addExpandingSubview(collectionView)
            collectionView?.contentInset = contentInset
            collectionView?.backgroundColor = UIColor.clear
            collectionView?.showsHorizontalScrollIndicator = false
        }

        if indicatorContainer?.superview == nil {
            if let indicatorContainer = indicatorContainer {
                collectionView?.addSubview(indicatorContainer)
            }
            updateIndicator(for: indicatorStyle)
        }
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        updateTabBar(forTabIndex: Int(tabOffset))

        // if default tab has not yet been displayed
        if tabCount > 0 && selectedCell == nil {
            let indexPath = IndexPath(item: defaultTabIndex, section: 0)
            collectionView?.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animateDataSourceTransition)
        }
    }

// MARK: - Collection View data source
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return evaluateDataSource()
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellNibName, for: indexPath) as? MSSTabBarCollectionViewCell
        updateCellAppearance(cell)

        // default contents
        cell?.tabStyle = tabStyle
        cell?.title = title(at: indexPath.row)

        // populate cell
        if let cell = cell {
            dataSource?.tabBarView(self, populateTab: cell, at: indexPath.item)
        }
        
        cell?.selectionProgress = tabDeselectedAlpha

        if (!hasRespectedDefaultTabIndex && indexPath.row == defaultTabIndex) || (selectedIndexPath == indexPath && tabOffset == MSSTabBarViewTabOffsetInvalid) {
            hasRespectedDefaultTabIndex = true
            setTabCellActive(cell, indexPath: indexPath)
        }

        return cell!
    }

// MARK: - Collection View delegate
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        var cellSize = CGSize.zero
        
        let layout = collectionViewLayout as! UICollectionViewFlowLayout

        if sizingStyle == .distributed && tabCount <= MSSTabBarViewMaxDistributedTabs {
            // distributed in frame

            let contentInsetTotal: CGFloat = contentInset.left + contentInset.right
            let totalSpacing = CGFloat(layout.minimumInteritemSpacing * CGFloat.init(integerLiteral: tabCount - 1))
            let totalWidth = collectionView.bounds.size.width - contentInsetTotal - totalSpacing

            return CGSize(width: totalWidth / CGFloat(tabCount), height: collectionView.bounds.size.height)
        } else {
            // wrap tab contents

            // update sizing cell with population
//            if dataSource?.responds(to: #selector(MSSTabbedPageViewController.tabBarView(_:populateTab:at:))) ?? false {
                if let _sizingCell = _sizingCell {
                    dataSource?.tabBarView(self, populateTab: _sizingCell, at: indexPath.item)
                }
//            } else {
                _sizingCell?.title = title(at: indexPath.row)
//            }

            var requiredSize = _sizingCell?.systemLayoutSizeFitting(CGSize(width: 0.0, height: collectionView.bounds.size.height), withHorizontalFittingPriority: .defaultLow, verticalFittingPriority: .required)
            
            let width = requiredSize?.width ?? 0
            requiredSize?.width = width + tabPadding
            cellSize = requiredSize ?? CGSize.zero
        }

        return cellSize
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

//        if delegate?.responds(to: #selector(MSSTabbedPageViewController.tabBarView(_:tabSelectedAt:))) ?? false {
        delegate!.tabBarView(self, tabSelectedAt: indexPath.row)
//        }
    }
    
// MARK: - Public
    func setTabPadding(_ tabPadding: CGFloat) {
        self.tabPadding = tabPadding
        reloadData()
    }

    func setContentInset(_ contentInsetArg: UIEdgeInsets) {
        self.contentInset = contentInsetArg

        // add selection indicator height to bottom of collection view inset
        var indicatorHeight: CGFloat
        if (indicatorAttributes != nil) {
            indicatorHeight = CGFloat((indicatorAttributes![MSSTabIndicatorLineHeight] as? NSNumber)?.floatValue ?? 0)
        } else {
            indicatorHeight = selectionIndicatorHeight
        }
        contentInset.bottom = contentInsetArg.bottom + indicatorHeight

        collectionView?.contentInset = contentInset
    }

    public func setSizingStyle(_ sizingStyle: MSSTabSizingStyle) {
        if (sizingStyle == .distributed && tabCount <= MSSTabBarViewMaxDistributedTabs) || sizingStyle == .sizeToFit {
            self.sizingStyle = sizingStyle
            reloadData()
        } else {
            print(String(format: "%@ - Distributed tab spacing is unavailable when using a tab count greater than %li", NSStringFromClass(MSSTabBarView.self), MSSTabBarViewMaxDistributedTabs))
        }
    }

    
    override public var tintColor: UIColor! {
        didSet {
            tabIndicatorColor = tintColor
        }
    }

    public func setIndicatorStyle(_ indicatorStyle: MSSIndicatorStyle) {
        if indicatorStyle != self.indicatorStyle {
            self.indicatorStyle = indicatorStyle
            updateIndicator(for: indicatorStyle)
        }
    }

// MARK: - Tab Bar State
    func updateTabBar(forTabOffset tabOffset: CGFloat) {

        // calculate the percentage progress of the current tab transition
        var integral: Float = 0
        let progress = CGFloat(modff(Float(tabOffset), &integral))
        let isBackwards = !(tabOffset >= previousTabOffset)

        if tabOffset <= 0.0 {
            // stick at bottom of tab bar

            let firstTabCell = collectionViewCell(atTabIndex: 0)
            updateTabs(withCurrentTabCell: firstTabCell, nextTabCell: firstTabCell, progress: 1.0, backwards: false)
            updateIndicatorView(withCurrentTabCell: firstTabCell, nextTabCell: firstTabCell, progress: 1.0)
        } else if tabOffset >= CGFloat(tabCount - 1) {
            // stick at top of tab bar

            let lastTabCell = collectionViewCell(atTabIndex: tabCount - 1)
            updateTabs(withCurrentTabCell: lastTabCell, nextTabCell: lastTabCell, progress: 1.0, backwards: false)
            updateIndicatorView(withCurrentTabCell: lastTabCell, nextTabCell: lastTabCell, progress: 1.0)
        } else {
            // update as required
            if progress != 0.0 {

                // get the current and next tab cells
                let currentTabIndex = isBackwards ? Int(ceil(tabOffset)) : Int(floor(tabOffset))
                let nextTabIndex = max(0, min(tabCount - 1, isBackwards ? Int(floor(tabOffset)) : Int(ceil(tabOffset))))

                let currentTabCell = collectionViewCell(atTabIndex: currentTabIndex)
                let nextTabCell = collectionViewCell(atTabIndex: nextTabIndex)

                // update tab bar components
                if currentTabCell != nextTabCell && (currentTabCell != nil && nextTabCell != nil) {
                    updateTabs(withCurrentTabCell: currentTabCell, nextTabCell: nextTabCell, progress: progress, backwards: isBackwards)
                    updateIndicatorView(withCurrentTabCell: currentTabCell, nextTabCell: nextTabCell, progress: progress)
                }
            } else {
                // finished update - on a tab cell

                let index = Int(floor(tabOffset))
                let selectedCell = collectionViewCell(atTabIndex: index)
                var indexPath: IndexPath? = nil
                if let selectedCell = selectedCell {
                    indexPath = collectionView?.indexPath(for: selectedCell)
                }

                if selectedCell != nil && indexPath != nil {
                    setTabCellActive(selectedCell, indexPath: indexPath)
                }
            }
        }
    }

    func updateTabBar(forTabIndex tabIndex: Int) {
        let cell = collectionViewCell(atTabIndex: tabIndex)
        if cell != nil {

            // update tab offsets
            previousTabOffset = tabOffset
            tabOffset = CGFloat(tabIndex)

            // update tab bar cells
            setTabCellsInactiveExceptTabIndex(tabIndex)
            setTabCellActive(cell, indexPath: IndexPath(item: tabIndex, section: 0))
        }
    }

    func setTabCellsInactiveExceptTabIndex(_ index: Int) {
        for item in 0..<tabCount {
            if item != index {
                let cell = collectionViewCell(atTabIndex: item)
                setTabCellInactive(cell)
            }
        }
    }

    func setTabCellActive(_ cell: MSSTabBarCollectionViewCell?, indexPath: IndexPath?) {
        selectedCell = cell
        selectedIndexPath = indexPath

        cell?.selectionProgress = 1.0

        if animateDataSourceTransition {
            UIView.animate(withDuration: 0.25, animations: {
                self.updateIndicatorViewFrame(withXOrigin: cell?.frame.origin.x ?? 0.0, andWidth: cell?.frame.size.width ?? 0.0, accountForPadding: true)
            })
        } else {
            updateIndicatorViewFrame(withXOrigin: cell?.frame.origin.x ?? 0.0, andWidth: cell?.frame.size.width ?? 0.0, accountForPadding: true)
        }
    }

    func setTabCellInactive(_ cell: MSSTabBarCollectionViewCell?) {
        cell?.selectionProgress = tabDeselectedAlpha
    }

    func updateTabs(withCurrentTabCell currentTabCell: MSSTabBarCollectionViewCell?, nextTabCell: MSSTabBarCollectionViewCell?, progress: CGFloat, backwards isBackwards: Bool) {
        var progress = progress

        // Calculate updated alpha values for tabs
        progress = isBackwards ? 1.0 - progress : progress

        if tabTransitionStyle == .progressive {
            // progressive

            let unselectedAlpha = tabDeselectedAlpha
            let alphaDiff = (1.0 - unselectedAlpha) * progress
            let nextAlpha = unselectedAlpha + alphaDiff
            let currentAlpha = 1.0 - alphaDiff

            currentTabCell?.selectionProgress = currentAlpha
            nextTabCell?.selectionProgress = nextAlpha
        } else {
            // snap

            let currentAlpha = (progress > MSSTabBarViewTabTransitionSnapRatio) ? tabDeselectedAlpha : 1.0
            let targetAlpha = (progress > MSSTabBarViewTabTransitionSnapRatio) ? 1.0 : tabDeselectedAlpha

            let requiresUpdate = nextTabCell?.selectionProgress != targetAlpha
            if requiresUpdate {
                UIView.animate(withDuration: 0.25, animations: {
                    currentTabCell?.selectionProgress = currentAlpha
                    nextTabCell?.selectionProgress = targetAlpha
                })
            }
        }
    }

    func updateIndicatorView(withCurrentTabCell currentTabCell: MSSTabBarCollectionViewCell?, nextTabCell: MSSTabBarCollectionViewCell?, progress: CGFloat) {
        var currentTabCell = currentTabCell
        var nextTabCell = nextTabCell
        if tabCount == 0 {
            return
        }

        // calculate the upper and lower x origins for cells
        let newTabX = nextTabCell?.frame.origin.x ?? 0.0
        let currentTabX = currentTabCell?.frame.origin.x ?? 0.0
        let upperXPos = max(newTabX, currentTabX )
        let lowerXPos = min(newTabX, currentTabX)

        // swap cells according to which has lowest X origin
        let backwards = nextTabCell?.frame.origin.x == lowerXPos
        if backwards {
            let temp = nextTabCell
            nextTabCell = currentTabCell
            currentTabCell = temp
        }

        var newX: CGFloat = 0.0
        var newWidth: CGFloat = 0.0

        if indicatorTransitionStyle == .progressive {

            // calculate width difference
            let currentTabWidth = currentTabCell?.frame.size.width ?? 0.0
            let nextTabWidth = nextTabCell?.frame.size.width ?? 0.0
            let widthDiff = (nextTabWidth - currentTabWidth) * progress

            // calculate new frame for indicator
            newX = lowerXPos + ((upperXPos - lowerXPos) * progress)
            newWidth = currentTabWidth + widthDiff

            updateIndicatorViewFrame(withXOrigin: newX, andWidth: newWidth, accountForPadding: true)
        } else if indicatorTransitionStyle == .snap {

            let cell = progress > MSSTabBarViewTabTransitionSnapRatio ? nextTabCell : currentTabCell

            newX = cell?.frame.origin.x ?? 0.0
            newWidth = cell?.frame.size.width ?? 0.0

            let requiresUpdate = indicatorContainer?.frame.origin.x != newX
            if requiresUpdate {
                UIView.animate(withDuration: 0.25, animations: {
                    self.updateIndicatorViewFrame(withXOrigin: newX, andWidth: newWidth, accountForPadding: true)
                })
            }
        }
    }

    func updateIndicatorViewFrame(withXOrigin xOrigin: CGFloat, andWidth width: CGFloat, accountForPadding padding: Bool) {
        var xOrigin = xOrigin
        var width = width
        if tabCount == 0 {
            return
        }

        if padding {
            let tabInternalPadding = tabPadding
            width = width - tabInternalPadding!
            xOrigin = xOrigin + tabInternalPadding! / 2.0
        }

        indicatorContainer?.frame = CGRect(x: xOrigin, y: 0.0, width: width, height: bounds.size.height)
        updateIndicatorFrames()
        updateCollectionViewScrollOffset()
    }

    func updateCollectionViewScrollOffset() {
        if sizingStyle != .distributed {

            // scroll collection view to center selection indicator if possible
            let collectionViewWidth = (collectionView?.bounds.size.width ?? 0.0) - contentInset.left - contentInset.right
            let scrollViewX = max(0, (indicatorContainer?.center.x ?? 0.0) - (collectionViewWidth / 2.0))
            collectionView?.scrollRectToVisible(CGRect(x: scrollViewX, y: collectionView?.frame.origin.y ?? 0.0, width: collectionViewWidth, height: collectionView?.frame.size.height ?? 0.0), animated: false)
        }
    }

    func collectionViewCell(atTabIndex tabIndex: Int) -> MSSTabBarCollectionViewCell? {
        if tabIndex >= 0 && tabIndex < tabCount {
            let indexPath = IndexPath(item: tabIndex, section: 0)
            return collectionView?.cellForItem(at: indexPath) as? MSSTabBarCollectionViewCell
        }
        return nil
    }

// MARK: - Internal
    func evaluateTabTitles() -> [AnyHashable]? {
        let tabTitles = dataSource?.tabTitles(for: self)
        return tabTitles
    }

    func evaluateDataSource() -> Int {
        var tabCount = 0
////        if dataSource?.responds(to: #selector(MSSTabbedPageViewController.numberOfItems(for:))) ?? false {
//            tabCount = dataSource?.numberOfItems(for: self) ?? 0
////        } else if dataSource?.responds(to: #selector(MSSTabBarViewDataSource.tabTitles(for:))) ?? false {

            tabTitles = evaluateTabTitles()
            tabCount = tabTitles?.count ?? 0
//        }
        self.tabCount = tabCount
        return tabCount
    }

    func title(at index: Int) -> String? {
        if tabTitles != nil {
            return tabTitles?[index] as? String
        } else {
            return String(format: MSSTabBarViewDefaultTabTitleFormat, index + 1)
        }
    }

    func reset() {
        selectedCell = nil
        selectedIndexPath = nil
        hasRespectedDefaultTabIndex = false
        tabOffset = MSSTabBarViewTabOffsetInvalid
        previousTabOffset = MSSTabBarViewTabOffsetInvalid
    }

    

    public func reloadData() {
        if tabOffset == MSSTabBarViewTabOffsetInvalid {
            hasRespectedDefaultTabIndex = false
        }
        collectionView?.reloadData()
    }

    func updateCellAppearance(_ cell: MSSTabBarCollectionViewCell?) {

        // default appearance
        if tabAttributes != nil {
            if let tabTextColor = tabAttributes![MSSTabTextColor] as? UIColor ??  tabAttributes![NSAttributedString.Key.foregroundColor.rawValue] as? UIColor {

                cell?.textColor = tabTextColor
            }

            if let tabTextFont = tabAttributes![MSSTabTextFont] as? UIFont ??  tabAttributes![NSAttributedString.Key.font.rawValue] as? UIFont {
                cell?.textFont = tabTextFont
            }

            if let tabBackgroundColor = tabAttributes![NSAttributedString.Key.backgroundColor.rawValue] as? UIColor {
                cell?.tabBackgroundColor = tabBackgroundColor
            }

            if let alphaEffectEnabled = tabAttributes![MSSTabTransitionAlphaEffectEnabled] as? NSNumber {
                cell?.alphaEffectEnabled = alphaEffectEnabled.boolValue
            }

            
            if let deselectedAlphaValue = tabAttributes![MSSTabTitleAlpha] as? NSNumber {
                _tabDeselectedAlpha = CGFloat(deselectedAlphaValue.floatValue )
            }
        } else {
            cell?.textColor = self.tabTextColor
            if (self.tabTextFont != nil) {
                cell?.textFont = self.tabTextFont
            }
        }

        // selected appearance
        if (selectedTabAttributes != nil) {
            if let selectedTabTextColor = selectedTabAttributes![MSSTabTextColor] as? UIColor ??  selectedTabAttributes![NSAttributedString.Key.foregroundColor.rawValue] as? UIColor {

                cell?.selectedTextColor = selectedTabTextColor
            }

            if let selectedTabTextFont = selectedTabAttributes![MSSTabTextFont] as? UIFont ??  selectedTabAttributes![NSAttributedString.Key.font.rawValue] as? UIFont {

                cell?.selectedTextFont = selectedTabTextFont
            }

            if let selectedTabBackgroundColor = selectedTabAttributes![NSAttributedString.Key.backgroundColor.rawValue] as? UIColor {
                cell?.selectedTabBackgroundColor = selectedTabBackgroundColor
            }
        }

        cell?.backgroundColor = UIColor.clear
        cell?.setContentBottomMargin(CGFloat((indicatorAttributes![MSSTabIndicatorLineHeight] as? NSNumber)?.floatValue ?? 0.0))
    }

    func updateIndicator(for indicatorStyle: MSSIndicatorStyle) {
        indicatorContainer?.mss_clearSubviews()

        var indicatorView: UIView?
        switch indicatorStyle {
            case .line:
                let indicatorLineView = UIView()
                indicatorContainer?.addSubview(indicatorLineView)

                indicatorView = indicatorLineView
            case .image:
                let imageView = UIImageView()
                imageView.contentMode = .bottom
                indicatorContainer?.addSubview(imageView)

                indicatorView = imageView

        }

        self.indicatorView = indicatorView
        updateIndicatorAppearance()
    }

    func updateIndicatorAppearance() {
        if (indicatorAttributes != nil) {

            switch indicatorStyle {
                case .line:

                    if let indicatorColor = indicatorAttributes![NSAttributedString.Key.foregroundColor.rawValue] as? UIColor {
                        indicatorView?.backgroundColor = indicatorColor
                    }

                    if let indicatorHeight = indicatorAttributes![MSSTabIndicatorLineHeight] as? NSNumber {
                        lineIndicatorHeight = CGFloat(indicatorHeight.floatValue )
                    }
                case .image:
                    let indicatorImageView = indicatorView as? UIImageView

                    if let indicatorImage = indicatorAttributes![MSSTabIndicatorImage] as? UIImage {
                        indicatorImageView?.image = indicatorImage.withRenderingMode(.alwaysTemplate)
                    }

                    if let indicatorTintColor = indicatorAttributes![MSSTabIndicatorImageTintColor] as? UIColor {
                        indicatorImageView?.tintColor = indicatorTintColor
                    }
                default:
                    break
            }
        }
    }

    func updateIndicatorFrames() {
        let containerBounds = indicatorContainer?.bounds

        var height: CGFloat = 0.0
        switch indicatorStyle {
            case .line:
                height = lineIndicatorHeight
            case .image:
                height = indicatorContainer?.bounds.size.height ?? 0.0
            default:
                break
        }

        indicatorView?.frame = CGRect(x: 0.0, y: (containerBounds?.size.height ?? 0.0) - height, width: containerBounds?.size.width ?? 0.0, height: height)
    }
}
