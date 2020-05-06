//
//  PAFlipper.swift
//  PowerAdapter_Example
//
//  Created by Prashant Rathore on 07/04/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

public protocol PAFlipperViewDataSource : AnyObject {
    func numberOfPagesinFlipper(_ flipperView : PAFlipperView) -> Int;
}

public protocol PAFlipperViewPageDelegate : AnyObject {
    
    func flipperView(_ flipperView : PAFlipperView, loadPageAt index: Int) -> UIView
    
    func flipperView(_ flipperView : PAFlipperView, willUnload page : UIView, at index: Int)
    
    func flipperView(_ flipperView : PAFlipperView, current page : UIView, at index: Int)
    
    func onPageChanged(_ flipperView : PAFlipperView, pageIndex: Int)
}

public class PAFlipperView : UIView, UIGestureRecognizerDelegate {
    
    //enum forflip direction
    enum PAFlipDirection : Int {
        case FlipDirectionTop
        case FlipDirectionBottom
    }
    
    private var pannedHasFailed = false
    private var pannedInitialized = false
    private var pannedLastPage = 0
    
    private var currentPageIndex = 0
    
    private var flipToPageIndex = 0
    
    private var numberOfPages = 0
    private var backgroundLayer: CALayer?
    private var flipLayer: CALayer?
    private var flipDirection: PAFlipDirection?
    private var startFlipAngle: Float = 0.0
    private var endFlipAngle: Float = 0.0
    private var currentAngle: Float = 0.0
    private var setNextViewOnCompletion = false
    private var animating = false
    private var tapRecognizer: UITapGestureRecognizer?
    private var panRecognizer: UIPanGestureRecognizer?
    
    private var lastPageNotificationIndex = 1
    
    private let previous = Page()
    private let current = Page()
    private let nextPage = Page()
    
    private var currentViewPage : Page?
    private var nextViewPage : Page?
    
    weak var dataSource : PAFlipperViewDataSource? {
        willSet {
            unloadAllPages()
        }
        didSet {
            numberOfPages = 0
            currentPageIndex = -1
            flipToPageIndex = 0
            lastPageNotificationIndex = -1
            //pagecontrol current page
            DispatchQueue.main.async {
                self.numberOfPages = self.dataSource!.numberOfPagesinFlipper(self)
                self.setFirstPage()
            }
        }
    }
    
    func reset() {
        unloadAllPages()
        numberOfPages = 0
        currentPageIndex = -1
        flipToPageIndex = 0
        lastPageNotificationIndex = -1
        DispatchQueue.main.async {
            self.numberOfPages = self.dataSource!.numberOfPagesinFlipper(self)
            self.setFirstPage()
        }
    }
    
    weak var delegate : PAFlipperViewPageDelegate?
    
    
    //#pragma init method
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupGestures()
    }
    
    private func setupGestures() {
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
        panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panned(_:)))
        panRecognizer?.delegate = self
        addGestureRecognizer(panRecognizer!)
        addGestureRecognizer(tapRecognizer!)
    }
    
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func unloadAllPages() {
        unloadPage(previous)
        unloadPage(current)
        unloadPage(nextPage)
    }
    
    func initFlip() {
        
        let currentView = currentViewPage?.view
        let nextView = nextViewPage?.view
        //create image from UIView
        let currentImage = image(byRenderingView: currentView)
        let newImage = image(byRenderingView: nextView)
        
        currentView?.alpha = 0
        nextView?.alpha = 0
        
        backgroundLayer = CALayer()
        backgroundLayer?.frame = bounds
        backgroundLayer?.zPosition = -300000
        
        //create top & bottom layer
        var rect = bounds
        rect.size.height /= 2
        
        let topLayer = CALayer()
        topLayer.frame = rect
        topLayer.masksToBounds = true
        topLayer.contentsGravity = .bottom
        
        backgroundLayer?.addSublayer(topLayer)
        
        rect.origin.y = rect.size.height
        
        let bottomLayer = CALayer()
        bottomLayer.frame = rect
        bottomLayer.masksToBounds = true
        bottomLayer.contentsGravity = .top
        
        backgroundLayer?.addSublayer(bottomLayer)
        
        if flipDirection == .FlipDirectionBottom {
            // flip from top to bottom
            topLayer.contents = newImage?.cgImage
            bottomLayer.contents = currentImage?.cgImage
        } else {
            //flip from bottom to top
            topLayer.contents = currentImage?.cgImage
            bottomLayer.contents = newImage?.cgImage
        }
        
        if let backgroundLayer = backgroundLayer {
            layer.addSublayer(backgroundLayer)
        }
        
        rect.origin.y = 0
        
        flipLayer = CATransformLayer()
        flipLayer?.anchorPoint = CGPoint(x: 0.5, y: 1.0)
        flipLayer?.frame = rect
        
        if let flipLayer = flipLayer {
            layer.addSublayer(flipLayer)
        }
        
        let backLayer = CALayer()
        backLayer.frame = flipLayer?.bounds ?? CGRect.zero
        backLayer.isDoubleSided = false
        backLayer.masksToBounds = true
        
        flipLayer?.addSublayer(backLayer)
        
        let frontLayer = CALayer()
        frontLayer.frame = flipLayer?.bounds ?? CGRect.zero
        frontLayer.isDoubleSided = false
        frontLayer.masksToBounds = true
        frontLayer.transform = CATransform3DMakeRotation(.pi, 1.0, 0.0, 0)
        
        flipLayer?.addSublayer(frontLayer)
        
        if flipDirection == .FlipDirectionBottom {
            backLayer.contents = currentImage?.cgImage
            backLayer.contentsGravity = .bottom
            
            frontLayer.contents = newImage?.cgImage
            frontLayer.contentsGravity = .top
            
            var transform = CATransform3DMakeRotation(0.0, 1.0, 0.0, 0.0)
            transform.m34 = -1.0 / 500.0
            
            flipLayer?.transform = transform
            
            startFlipAngle = 0
            currentAngle = startFlipAngle
            endFlipAngle = .pi
        } else {
            backLayer.contentsGravity = .bottom
            backLayer.contents = newImage?.cgImage
            
            frontLayer.contents = currentImage?.cgImage
            frontLayer.contentsGravity = .top
            
            var transform = CATransform3DMakeRotation(.pi, 1.0, 0.0, 0.0)
            transform.m34 = 1.0 / 500.0
            
            flipLayer?.transform = transform
            
            startFlipAngle = .pi
            currentAngle = startFlipAngle
            endFlipAngle = 0
        }
    }
    
    //#pragma flip
    @objc func flipPage() {
        setFlipProgress(1.0, setDelegate: true, animate: true)
    }
    
    func setFlipProgress(_ progress: Float, setDelegate: Bool, animate: Bool) {
        if animate {
            animating = true
        }
        
        let angle = startFlipAngle + progress * (endFlipAngle - startFlipAngle)
        
        let duration = animate ? 0.5 * abs((angle - currentAngle) / (endFlipAngle - startFlipAngle)) : 0
        
        currentAngle = angle
        
        var finalTransform = CATransform3DIdentity
        finalTransform.m34 = 1.0 / 1500.0
        finalTransform = CATransform3DRotate(finalTransform, CGFloat(angle), 1.0, 0.0, 0.0)
        
        flipLayer?.removeAllAnimations()
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(CFTimeInterval(duration))
        
        flipLayer?.transform = finalTransform
        
        CATransaction.commit()
        
        if setDelegate {
            perform(#selector(cleanupFlip), with: nil, afterDelay: TimeInterval(duration))
        }
    }
    
    private func copyPage(_ page : Page, to: Page) {
        to.isValid = page.isValid
        to.position = page.position
        to.view = page.view
    }
    
    //clear flip & background layer
    @objc func cleanupFlip() {
        
        backgroundLayer?.removeFromSuperlayer()
        flipLayer?.removeFromSuperlayer()
        
        backgroundLayer = nil
        flipLayer = nil
        
        animating = false
        
        if setNextViewOnCompletion {
            current.view?.removeFromSuperview()
            if(flipDirection == .FlipDirectionBottom) {
                unloadPage(nextPage)
                copyPage(current, to: nextPage)
                copyPage(previous, to: current)
                currentPageIndex = current.position
                delegate?.flipperView(self, current: current.view!, at: current.position)
                initPage(previous, with: previous.position - 1)
            } else {
                unloadPage(previous)
                copyPage(current, to: previous)
                copyPage(nextPage, to: current)
                currentPageIndex = current.position
                delegate?.flipperView(self, current: current.view!, at: current.position)
                initPage(nextPage, with: nextPage.position + 1)
            }
            
        } else {
            nextViewPage?.view?.removeFromSuperview()
        }
        
        postPageChangeNotification()
        currentViewPage = current
        nextViewPage = nil
        current.view?.alpha = 1
    }
    
    
    private func postPageChangeNotification() {
        if(currentViewPage == nil) {
            return
        }
        if(lastPageNotificationIndex != currentPageIndex) {
            let canNotify = lastPageNotificationIndex >= 0
            lastPageNotificationIndex = currentPageIndex
            let index = currentPageIndex
            if(canNotify) {
                DispatchQueue.main.async {
                    self.delegate?.onPageChanged(self, pageIndex: index)
                }
            }
        }
    }
    
    //#pragma selector
    @objc func animationDidStop(_ animationID: String?, finished: NSNumber?, context: UnsafeMutableRawPointer?) {
        cleanupFlip()
    }
    
    //#pragma setter
    func setCurrentPage(_ page: Int) {
        
        if !canSetCurrentPage(page) {
            return
        }
        
        setNextViewOnCompletion = true
        animating = true
        
        nextViewPage?.view?.alpha = 0
        
        UIView.beginAnimations("", context: nil)
        UIView.setAnimationDuration(0.5)
        UIView.setAnimationDelegate(self)
        UIView.setAnimationDidStop(#selector(animationDidStop(_:finished:context:)))
        
        nextViewPage?.view?.alpha = 1
        
        UIView.commitAnimations()
    }
    
    public func setCurrentPage(_ page: Int, animated: Bool) {
        flipToPageIndex = page
        if !canSetCurrentPage(page) {
            return
        }
        
        setNextViewOnCompletion = true
        animating = true
        
        if animated {
            initFlip()
            perform(#selector(flipPage), with: nil, afterDelay: 0.001)
        } else {
            animationDidStop(nil, finished: NSNumber(value: false), context: nil)
        }
        
    }
    
    
    private func prepareInitialPages(_ showPage : Int) {
        initPage(previous, with: showPage - 2 )
        initPage(current, with: showPage - 1)
        initPage(nextPage, with: showPage)
    }
    
    private func preparePagesForFlip(_ page : Int) {
        if(page > currentPageIndex) {
            reInitPage(nextPage, with: page)
        }
        else if( page < currentPageIndex ) {
            reInitPage(previous, with: page)
        }
    }
    
    private func reInitPage(_ page : Page, with index : Int) {
        if(index != page.position) {
            unloadPage(page)
        }
        initPage(page, with: index)
    }
    
    private func initPage(_ page : Page, with index : Int) {
        if(index != page.position) {
            if(index >= 0 && index < numberOfPages) {
                page.isValid = true
                page.view = delegate!.flipperView(self, loadPageAt: index)
                page.position = index
            }
        }
        
    }
    
    private func unloadPage(_ page : Page) {
        if(page.isValid && page.position >= 0 && page.position < numberOfPages) {
            delegate?.flipperView(self, willUnload: page.view!, at: page.position)
        }
        page.view?.removeFromSuperview()
        page.reset()
    }
    
    
    @objc func setFirstPage() {
        prepareInitialPages(flipToPageIndex)
        setCurrentPage(flipToPageIndex, animated: false)
    }
    
    func canSetCurrentPage(_ page: Int) -> Bool {
        if (page == currentPageIndex || page >= numberOfPages) {
            return false
        }
        
        preparePagesForFlip(page)
        
        if(page < currentPageIndex) {
            flipDirection = .FlipDirectionBottom
            nextViewPage = previous
        }
        else {
            flipDirection = .FlipDirectionTop
            nextViewPage = nextPage
        }
        
        if(nextViewPage?.view != nil) {
            addSubview(nextViewPage!.view!)
        }
        return true
    }
    
    //#pragma Gesture recognizer handler
    @objc func tapped(_ recognizer: UITapGestureRecognizer?) {
        
        if !animating {
            if recognizer?.state == .recognized {
                var newPage: Int
                
                if (recognizer?.location(in: self).y ?? 0.0) < (bounds.size.height - bounds.origin.y) / 2 {
                    newPage = max(0, currentPageIndex - 1)
                } else {
                    newPage = min(currentPageIndex + 1, numberOfPages - 1)
                }
                
                setCurrentPage(newPage, animated: true)
            }
        }
    }
    
    
    
    
    public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let translation = self.panRecognizer!.translation(in: self)
        let isVerticalPan = abs(translation.y) > abs(translation.x)
        return isVerticalPan && (translation.y < 0.0 || current.position > 0 )  && gestureRecognizer === panRecognizer
    }
    
    
    @objc func panned(_ recognizer: UIPanGestureRecognizer?) {
        
        if !animating {
            
            let translation = CGFloat(recognizer?.translation(in: self).y ?? 0.0)
            
            var progress = translation / bounds.size.height
            
            if flipDirection == .FlipDirectionTop {
                progress = min(progress, 0)
            } else {
                progress = max(progress, 0)
            }
            
            switch recognizer?.state {
            case .began:
                self.pannedHasFailed = false
                self.pannedInitialized = false
                animating = false
                setNextViewOnCompletion = false
            case .changed:
                if !self.pannedHasFailed {
                    if !self.pannedInitialized {
                        
                        self.pannedLastPage = currentPageIndex
                        if translation > 0 {
                            if currentPageIndex > 0 {
                                _ = canSetCurrentPage(currentPageIndex - 1)
                            } else {
                                self.pannedHasFailed = true
                                return
                            }
                        } else {
                            if currentPageIndex < numberOfPages - 1 {
                                _ = canSetCurrentPage(currentPageIndex + 1)
                            } else {
                                self.pannedHasFailed = true
                                return
                            }
                        }
                        self.pannedHasFailed = false
                        self.pannedInitialized = true
                        setNextViewOnCompletion = false
                        
                        initFlip()
                    }
                    setFlipProgress(Float(abs(progress)), setDelegate: false, animate: false)
                }
            case .failed:
                setFlipProgress(0.0, setDelegate: true, animate: true)
                currentPageIndex = self.pannedLastPage
            case .recognized:
                if self.pannedHasFailed {
                    setFlipProgress(0.0, setDelegate: true, animate: true)
                    currentPageIndex = self.pannedLastPage
                    return
                }
                if abs(Float((CGFloat(translation) + (recognizer?.velocity(in: self).y ?? 0.0) / 4) / bounds.size.height)) > 0.5 {
                    setNextViewOnCompletion = true
                    setFlipProgress(1.0, setDelegate: true, animate: true)
                } else {
                    setFlipProgress(0.0, setDelegate: true, animate: true)
                    currentPageIndex = self.pannedLastPage
                }
            default:
                break
            }
        }
    }
    
    //return UIView as UIImage by rendering view
    func image(byRenderingView view: UIView?) -> UIImage? {
        
        let viewAlpha = view?.alpha ?? 0.0
        view?.alpha = 1
        
        UIGraphicsBeginImageContext(view?.bounds.size ?? CGSize.zero)
        if let context = UIGraphicsGetCurrentContext() {
            view?.layer.render(in: context)
        }
        let resultingImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        view?.alpha = viewAlpha
        return resultingImage
    }
}


class Page {
    var view : UIView?
    var position : Int = -1
    var isValid = false
    
    func reset() {
        view = nil
        position = -1
        isValid = false
    }
}
