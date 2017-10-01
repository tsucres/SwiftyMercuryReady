//
//  ScrollableNavBarViewController.swift
//  SwiftyMercuryReady
//
//  Created by Stéphane Sercu on 12/09/17.
//  Copyright © 2017 Stéphane Sercu. All rights reserved.
//

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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if #available(iOS 11, *) { // The method here stopped working in ios11. so.. TODO
            return
        }
        if let navCtrl = navigationController {
            let velocity = scrollView.panGestureRecognizer.velocity(in: scrollView)
            
            var navFrame: CGRect = navCtrl.navigationBar.frame
            var toolFrame: CGRect = navCtrl.toolbar.frame
            
            let navSize: CGFloat = navFrame.size.height - 21
            let toolSize: CGFloat = toolFrame.size.height

            let navFramePercentageHidden: CGFloat = ((20 - navFrame.origin.y) / (navFrame.size.height - 1))
            let toolFramePercentageHidden: CGFloat = 1 - ((UIScreen.main.bounds.height - toolFrame.origin.y) / (toolFrame.size.height - 1))
            
            let scrollOffset: CGFloat = scrollView.contentOffset.y
            let scrollDiff: CGFloat = scrollOffset - self.previousWebviewYOffset
            let scrollHeight: CGFloat = scrollView.frame.size.height
            let scrollContentSizeHeight: CGFloat = scrollView.contentSize.height + scrollView.contentInset.bottom

            if navFrame.origin.y == -navSize && abs(velocity.y) < 300 {
                self.previousWebviewYOffset = scrollOffset
                return
            }
            
            if scrollOffset <= -scrollView.contentInset.top { // Full top
                // We completly show the toolbar and the navbar
                navFrame.origin.y = 20
                toolFrame.origin.y = UIScreen.main.bounds.height - toolSize
                
            } else if (scrollOffset + scrollHeight) >= scrollContentSizeHeight { // Full bottom
                // We completly hide the toolbar and the navbar
                navFrame.origin.y = -navSize
                toolFrame.origin.y = UIScreen.main.bounds.height
            } else {
                // Something in between
                navFrame.origin.y = min(20, max(-navSize, navFrame.origin.y - scrollDiff))
                toolFrame.origin.y = max(UIScreen.main.bounds.height - toolSize, min(UIScreen.main.bounds.height, toolFrame.origin.y + scrollDiff))
            }
            navCtrl.navigationBar.frame = navFrame
            navCtrl.toolbar.frame = toolFrame
            
            updateNavBarButtonItems(alpha: 1 - navFramePercentageHidden)
            updateToolBarButtonItems(alpha: 1 - toolFramePercentageHidden)
            self.previousWebviewYOffset = scrollOffset
            
            
            
        }
        
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.stoppedScrolling()
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.stoppedScrolling()
        }
    }
    
    /// Depending on the current position of the navBar (weither it's
    /// mostly in/out of the bounds of the screen), move the navBar in/out
    /// of the screen.
    private func stoppedScrolling() {
        if let navCtrl = self.navigationController {
            let frame: CGRect = navCtrl.navigationBar.frame
            if frame.origin.y < 20 {
                //self.animateNavBarTo(y:-(frame.size.height - 21))
                self.animateToolBarTo(y: UIScreen.main.bounds.height)
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
                let alpha: CGFloat = frame.origin.y >= y ? 0 : 1
                frame.origin.y = y;
                navCtrl.navigationBar.frame = frame
                self.updateNavBarButtonItems(alpha: alpha)
            })
        }
    }
    private func animateToolBarTo(y: CGFloat) {
        if let navCtrl = self.navigationController {
            UIView.animate(withDuration: 0.2, animations: {
                var frame: CGRect = navCtrl.toolbar.frame;
                let alpha: CGFloat = frame.origin.y >= y ? 0 : 1
                frame.origin.y = y;
                navCtrl.toolbar.frame = frame
                self.updateToolBarButtonItems(alpha: alpha)
            })
        }
    }
}
