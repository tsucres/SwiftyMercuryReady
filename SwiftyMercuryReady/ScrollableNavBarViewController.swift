//
//  ScrollableNavBarViewController.swift
//  SwiftyMercuryReady
//
//  Created by Stéphane Sercu on 12/09/17.
//  Copyright © 2017 Stéphane Sercu. All rights reserved.
//

// Warning: This code is a mess. It is a nightmare to debug.

import UIKit

class ScrollableNavBarViewControllerTest: ScrollableNavBarViewController {
    let scrollView = UIScrollView()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isToolbarHidden = false
        
        
        self.view.addSubview(scrollView)
        scrollView.frame = self.view.frame
        /*scrollView.translatesAutoresizingMaskIntoConstraints = false
        //scrollView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        */
        scrollView.contentSize = CGSize(width: self.view.bounds.width, height: 2*self.view.bounds.height)
        scrollView.backgroundColor = .yellow
        
        scrollView.delegate = self
    }
}

/**
 *  UIViewController that hide/show the navigationBar and the toolbar according to the scroll of a child element.
 *  Inspired by [this post](https://stackoverflow.com/questions/19819165/imitate-facebook-hide-show-expanding-contracting-navigation-bar)
 */
class ScrollableNavBarViewController: UIViewController, UIScrollViewDelegate {
    private var previousWebviewYOffset: CGFloat = 0
    
    private func getOrigins() -> (CGFloat?, CGFloat?, CGFloat?, CGFloat?) {
        if let navCtrl = navigationController {
            // 20 pt on classic screen, 44 on iPhone X
            let statusBarHeight = UIApplication.shared.statusBarFrame.height
            
            let bottomSafeAreaHeight:CGFloat = getBottomSafeHeight()
            
            let navFrame: CGRect = navCtrl.navigationBar.frame
            let toolFrame: CGRect = navCtrl.toolbar.frame
            
            // 49 on iPhone X, 44 on classic screen
            let toolSize: CGFloat = toolFrame.size.height
            
            // Y position of the navbar when it is completely visible
            let navbarVisibleOriginY: CGFloat = statusBarHeight
            
            // Y position of the navbar when it is completely hidden
            let navbarHiddenOriginY: CGFloat = -(navFrame.size.height - statusBarHeight - 1)
            
            // Y position of the toolbar when it is completely visible
            let toolbarVisibleOriginY:CGFloat = UIScreen.main.bounds.height - toolSize - bottomSafeAreaHeight
            
            // Y position of the toolbar when it is completely hidden
            let toolbarHiddenOriginY: CGFloat = UIScreen.main.bounds.height
            
            return (navbarVisibleOriginY, navbarHiddenOriginY, toolbarVisibleOriginY, toolbarHiddenOriginY)
        }
        return (nil, nil, nil, nil)
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let navCtrl = navigationController {
            let velocity = scrollView.panGestureRecognizer.velocity(in: scrollView)
            
            var navFrame: CGRect = navCtrl.navigationBar.frame
            var toolFrame: CGRect = navCtrl.toolbar.frame
            
            let (navbarVisibleOriginY, navbarHiddenOriginY, toolbarVisibleOriginY, toolbarHiddenOriginY) = getOrigins()
            
            let scrollOffset: CGFloat = scrollView.contentOffset.y
            let scrollInset: CGFloat = scrollView.contentInset.top
            let scrollDiff: CGFloat = scrollOffset - self.previousWebviewYOffset
            let scrollHeight: CGFloat = scrollView.frame.size.height
            let scrollContentSizeHeight: CGFloat = scrollView.contentSize.height + scrollView.contentInset.bottom
            
            if navFrame.origin.y == navbarVisibleOriginY && toolFrame.origin.y == toolbarVisibleOriginY && velocity.y > 0 {
                // If both bars are visible and the user scrolls up => nothing to do
                self.previousWebviewYOffset = scrollOffset
                return
            }
            // The following are the conditions to unfold the navbar...
            if navFrame.origin.y == navbarHiddenOriginY && // If navbar is already hidden
                toolFrame.origin.y == UIScreen.main.bounds.height && // the toolbar too
                abs(velocity.y) < 300 && // and velocity is small
                scrollOffset + scrollInset >= navFrame.size.height { // and we are not at top edge of the scroll content
                // then we don't change the position of the navbar nor the position of the toolbar
                self.previousWebviewYOffset = scrollOffset
                return
            }
            
            if scrollOffset <= -scrollInset { // Full top
                // We completly show the toolbar and the navbar
                navFrame.origin.y = navbarVisibleOriginY!
                toolFrame.origin.y = toolbarVisibleOriginY!
                
            } else if (scrollOffset + scrollHeight + scrollInset) >= scrollContentSizeHeight { // Full bottom
                // We completly hide the toolbar and the navbar
                navFrame.origin.y = navbarHiddenOriginY!
                toolFrame.origin.y = toolbarHiddenOriginY!
            } else {
                // Something in between
                navFrame.origin.y = min(navbarVisibleOriginY!, max(navbarHiddenOriginY!, navFrame.origin.y - scrollDiff))
                toolFrame.origin.y = max(toolbarVisibleOriginY!, min(toolbarHiddenOriginY!, toolFrame.origin.y + scrollDiff))
            }
            navCtrl.navigationBar.frame = navFrame
            navCtrl.toolbar.frame = toolFrame
            
            let navFramePercentageHidden: CGFloat = ((navbarVisibleOriginY! - navFrame.origin.y) / (navbarVisibleOriginY! - navbarHiddenOriginY!))
            let toolFramePercentageHidden: CGFloat = 1 + (toolFrame.origin.y - toolbarHiddenOriginY!)/(toolbarHiddenOriginY! - toolbarVisibleOriginY!)
            updateNavBarButtonItems(alpha: 1 - navFramePercentageHidden)
            updateToolBarButtonItems(alpha: 1 - toolFramePercentageHidden)
            
            self.previousWebviewYOffset = scrollOffset
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.stoppedScrolling(scrollView: scrollView)
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.stoppedScrolling(scrollView: scrollView)
        }
    }
    
    /// Depending on the current position of the navBar (weither it's
    /// mostly in/out of the bounds of the screen), move the navBar in/out
    /// of the screen.
    private func stoppedScrolling(scrollView: UIScrollView) {
        if let navCtrl = self.navigationController {
            let frame: CGRect = navCtrl.navigationBar.frame
            
            // The y distance left for the navbar to be completely hidden
            let dy = frame.origin.y + frame.size.height - getTopSafeHeight() - 1
            if dy > 0 { // If not completly hidden
                let currentContentOffset = scrollView.contentOffset
                if dy > 0.6*frame.height {
                    scrollView.setContentOffset(CGPoint(x: currentContentOffset.x, y: currentContentOffset.y - frame.height + dy + 1), animated: true)
                    self.animateNavBarFullShow()
                    self.animateToolBarFullShow()
                } else {
                    scrollView.setContentOffset(CGPoint(x: currentContentOffset.x, y:  currentContentOffset.y + dy), animated: true)
                    self.animateNavBarFullHide()
                    self.animateToolBarFullHide()
                }
                
            } else {
                self.animateToolBarFullHide() // On the iphone X, the toolbar is bigger than the navbar, so it may happen that the navbar is completely hidden but that toolbar isn't
            }
        }
        
    }
    
    /// Set the alpha of each item in the NavBar
    private func updateNavBarButtonItems(alpha: CGFloat) {
        if let items = navigationItem.leftBarButtonItems {
            for (_, item) in items.enumerated() { // TODO: isn't navigationBar.tintColor sufficient for every items?
                item.tintColor = item.tintColor?.withAlphaComponent(alpha)
            }
        }
        if let items = navigationItem.rightBarButtonItems {
            for (_, item) in items.enumerated() {
                item.tintColor = item.tintColor?.withAlphaComponent(alpha)
            }
        }
        if let titleView = self.navigationItem.titleView {
            titleView.tintColor = titleView.tintColor.withAlphaComponent(alpha)
            titleView.alpha = alpha
        }
        self.navigationController?.navigationBar.tintColor = self.navigationController?.navigationBar.tintColor.withAlphaComponent(alpha)
    }
    private func updateToolBarButtonItems(alpha: CGFloat) {
        if let items = toolbarItems {
            for (_, item) in items.enumerated() {
                item.tintColor = item.tintColor?.withAlphaComponent(alpha)
            }
        }
        self.navigationController?.toolbar.tintColor = self.navigationController?.toolbar.tintColor.withAlphaComponent(alpha)
    }
    
    /// Move the NavBar to the specified y
    /// If the specified y is out (in) of the screen bounds, the alpha of the navBar is also progressively set to 0 (1).
    private func animateNavBarTo(y: CGFloat) {
        if let navCtrl = self.navigationController {
            UIView.animate(withDuration: 0.2, animations: {
                var frame: CGRect = navCtrl.navigationBar.frame;
                let alpha: CGFloat = frame.origin.y > y ? 0 : 1
                frame.origin.y = y;
                navCtrl.navigationBar.frame = frame
                self.updateNavBarButtonItems(alpha: alpha)
            })
        }
    }
    
    private func animateNavBarFullShow() {
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        self.animateNavBarTo(y:statusBarHeight)
    }
    private func animateNavBarFullHide() {
        let y = -((self.navigationController?.navigationBar.frame.size.height ?? 0) - self.getTopSafeHeight() - 1)
        self.animateNavBarTo(y:y)
    }
    private func animateToolBarTo(y: CGFloat) {
        if let navCtrl = self.navigationController {
            UIView.animate(withDuration: 0.2, animations: {
                var frame: CGRect = navCtrl.toolbar.frame;
                let alpha: CGFloat = frame.origin.y < y ? 0 : 1
                frame.origin.y = y;
                navCtrl.toolbar.frame = frame
                self.updateToolBarButtonItems(alpha: alpha)
            })
        }
    }
    
    private func animateToolBarFullShow() {
        let toolSize = (self.navigationController?.toolbar.frame.height ?? 0)
        let bottomSafeAreaHeight:CGFloat = getBottomSafeHeight()
        animateToolBarTo(y: UIScreen.main.bounds.height - toolSize - bottomSafeAreaHeight)
    }
    private func animateToolBarFullHide() {
        animateToolBarTo(y: UIScreen.main.bounds.height)
    }
    
    private func getTopSafeHeight() -> CGFloat {
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        return statusBarHeight
    }
    
    private func getBottomSafeHeight() -> CGFloat {
        var bottomSafeAreaHeight:CGFloat = 0.0
        if #available(iOS 11.0, *) {
            bottomSafeAreaHeight = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0.0
        }
        return bottomSafeAreaHeight
    }
}
