//
//  ArticleReaderController.swift
//  SwiftyMercuryReady
//
//  Created by Stéphane Sercu on 10/09/17.
//  Copyright © 2017 Stéphane Sercu. All rights reserved.
//

import UIKit
import WebKit

struct Constant {
    static let darkReaderBackgroundColor: UIColor = #colorLiteral(red: 0.1529267132, green: 0.1529495716, blue: 0.1529162228, alpha: 1)
    static let darkReaderTextColor: UIColor = .white
    static let darkReaderControlColor: UIColor = #colorLiteral(red: 0.6509314179, green: 0.6510090232, blue: 0.6508957744, alpha: 1)
    
    static let lightReaderBackgroundColor: UIColor = #colorLiteral(red: 0.9724777341, green: 0.9725906253, blue: 0.972425878, alpha: 1)
    static let lightReaderTextColor: UIColor = .black
    static let lightReaderControlColor: UIColor = #colorLiteral(red: 0.5176073313, green: 0.5176702142, blue: 0.5175783634, alpha: 1)
    
    static let browserBackgroundColor: UIColor = .white
    static let browserTextColor: UIColor = .black
    static let browserControlColor: UIColor = #colorLiteral(red: 0.1743344963, green: 0.4776316285, blue: 0.9930145144, alpha: 1)
}

class ArticleReaderController: ScrollableNavBarViewController, WKNavigationDelegate, ReaderDelegate {
    public var url: URL? {
        didSet {
            if url != nil {
                webView.load(URLRequest(url: url!))
            }
        }
    }
    public var isReaderEnabled: Bool = false {
        didSet {
            if viewIfLoaded == nil {
                return
            }
            if isReaderEnabled {
                showReader()
            }
            else {
                hideReader()
            }
            
            // Needed for the navbar: If both scrollviews scrolls at the same time, the navbar goes crazy
            self.webView.scrollView.setContentOffset(self.webView.scrollView.contentOffset, animated: false)
            self.reader.scrollView.setContentOffset(self.reader.scrollView.contentOffset, animated: false)
            
            updateToolbarColors()
            updateNavbarColors()
            updateReaderBackgroundColor()
        }
    }
    
    private var _isReaderAvailable: Bool = false
    public var isReaderAvailable: Bool {
        get {
            return _isReaderAvailable
        }
    }
    
    // Webviews
    let reader = ReaderWebView()
    let webView = WKWebView()
    private var readerTopConstraint: NSLayoutConstraint? // used to animation the apparition/disparition of the reader
    
    // Navbar's items
    private var navBarTitleView: NavBarTitleView?
    private let progressBar = UIProgressView(progressViewStyle: .bar)
    
    // Toolbar's items
    private var undoBarBtnItem: UIBarButtonItem?
    private var refreshBarBtnItem: UIBarButtonItem?
    private var redoBarBtnItem: UIBarButtonItem?
    private var readerBarBtnItem: UIBarButtonItem?
    private var readerBiggerTextBarBtnItem: UIBarButtonItem?
    private var readerSmallerTextBarBtnItem: UIBarButtonItem?
    private var readerThemeBtnItem:UIBarButtonItem?
    private var readerSerifBarBtnItem: UIBarButtonItem?
    
    
    // MARK: - Initialisation
    // ============================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (self.responds(to: #selector(getter: edgesForExtendedLayout))) {
            self.edgesForExtendedLayout = []
        }
        
        setupNavBar()
        setupToolBar()
        setupWebViews()
        
        updateReaderBackgroundColor()
        if #available(iOS 11.0, *) {
            self.webView.scrollView.contentInsetAdjustmentBehavior = .never
            self.reader.scrollView.contentInsetAdjustmentBehavior = .never
            
        }

        
        // They're hidden by default until a history is built
        navBarTitleView?.backButton.isHidden = true
        navBarTitleView?.forwardButton.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isToolbarHidden = false
        self.extendedLayoutIncludesOpaqueBars = true
        self.edgesForExtendedLayout = UIRectEdge.all
        reloadToolbarItems()
        updateNavbarColors()
        updateToolbarColors()
        if #available(iOS 11.0, *) {
            self.view.insetsLayoutMarginsFromSafeArea = false
            self.webView.scrollView.insetsLayoutMarginsFromSafeArea = false
            self.reader.scrollView.insetsLayoutMarginsFromSafeArea = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.title))
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.canGoForward))
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.canGoBack))
    }
    
    private func setupWebViews() {
        // Sets the webView's insets
        self.automaticallyAdjustsScrollViewInsets = false
        
        let navBarHeight = self.navigationController?.navigationBar.frame.height ?? 0
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        self.webView.scrollView.contentInset = UIEdgeInsets(top: navBarHeight + statusBarHeight, left: 0, bottom: 0, right: 0)
        self.reader.scrollView.contentInset = UIEdgeInsets(top: navBarHeight + statusBarHeight, left: 0, bottom: 0, right: 0)
        self.webView.scrollView.scrollIndicatorInsets = UIEdgeInsets(top: navBarHeight + statusBarHeight, left: 0, bottom: 0, right: 0)
        self.reader.scrollView.scrollIndicatorInsets = UIEdgeInsets(top: navBarHeight + statusBarHeight, left: 0, bottom: 0, right: 0)
        
        self.view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        webView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        
        self.view.addSubview(reader)
        reader.translatesAutoresizingMaskIntoConstraints = false
        readerTopConstraint = reader.topAnchor.constraint(equalTo: self.view.topAnchor, constant: self.isReaderEnabled ? 0: self.view.frame.height)// + navBarHeight + 20)
        readerTopConstraint!.isActive = true
        reader.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        reader.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        reader.heightAnchor.constraint(equalTo: self.view.heightAnchor).isActive = true
        
        webView.scrollView.delegate = self
        reader.scrollView.delegate = self
        
        self.webView.navigationDelegate = self
        self.reader.readerDelegate = self
    }
   
    private func setupNavBar() {
        // Title
        navBarTitleView = NavBarTitleView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width - 115, height: (self.navigationController?.navigationBar.bounds.height)!))
        navBarTitleView!.title = ""
        navBarTitleView!.subtitle = ""
        
        self.navigationItem.titleView = navBarTitleView!
       
        // Data binding
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.title), options: .new, context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.canGoBack), options: .new, context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.canGoForward), options: .new, context: nil)
        navBarTitleView?.backButton.addTarget(self, action: #selector(undoWebView), for: .touchUpInside)
        navBarTitleView?.forwardButton.addTarget(self, action: #selector(redoWebView), for: .touchUpInside)
        
        
        self.setupProgressBar()
    }
    
    private func setupProgressBar() {
        // source: https://stackoverflow.com/questions/20018936/add-a-uiprogressview-under-the-navigation-controller
        if let navigationVC = self.navigationController {
            
            navigationVC.navigationBar.addSubview(progressBar)
            // create constraints
            // NOTE: bottom constraint has 1 as constant value instead of 0; this way the progress bar will look like the one in Safari
            let bottomConstraint = NSLayoutConstraint(item: navigationVC.navigationBar, attribute: .bottom, relatedBy: .equal, toItem: progressBar, attribute: .bottom, multiplier: 1, constant: 1)
            let leftConstraint = NSLayoutConstraint(item: navigationVC.navigationBar, attribute: .leading, relatedBy: .equal, toItem: progressBar, attribute: .leading, multiplier: 1, constant: 0)
            let rightConstraint = NSLayoutConstraint(item: navigationVC.navigationBar, attribute: .trailing, relatedBy: .equal, toItem: progressBar, attribute: .trailing, multiplier: 1, constant: 0)
            let heightConstrint = NSLayoutConstraint(item: progressBar, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0.5)
            // add constraints
            progressBar.translatesAutoresizingMaskIntoConstraints = false
            navigationVC.view.addConstraints([bottomConstraint, leftConstraint, rightConstraint, heightConstrint])
        }
    }
    
    /// Set the navbar colors (background and items) according to the current theme and to whether the reader is visible or not.
    private func updateNavbarColors() {
        if !self.isReaderEnabled {
            self.navigationController?.navigationBar.barTintColor = Constant.browserBackgroundColor
            self.navigationController?.navigationBar.backgroundColor = Constant.browserBackgroundColor
            self.navigationController?.navigationBar.isTranslucent = true
            self.navigationController?.navigationBar.tintColor = Constant.browserTextColor
            self.navBarTitleView?.itemsColor = Constant.browserTextColor
            UIApplication.shared.statusBarStyle = .default
        } else if self.reader.readerTheme == .light {
            self.navigationController?.navigationBar.barTintColor = Constant.lightReaderBackgroundColor
            self.navigationController?.navigationBar.backgroundColor = Constant.lightReaderBackgroundColor
            self.navigationController?.navigationBar.isTranslucent = false
            self.navigationController?.navigationBar.tintColor = Constant.lightReaderTextColor
            self.navBarTitleView?.itemsColor = Constant.lightReaderTextColor
            UIApplication.shared.statusBarStyle = .default
        } else if self.reader.readerTheme == .dark {
            self.navigationController?.navigationBar.barTintColor = Constant.darkReaderBackgroundColor
            self.navigationController?.navigationBar.backgroundColor = Constant.darkReaderBackgroundColor
            self.navigationController?.navigationBar.isTranslucent = false
            self.navigationController?.navigationBar.tintColor = Constant.darkReaderTextColor
            self.navBarTitleView?.itemsColor = Constant.darkReaderTextColor
            UIApplication.shared.statusBarStyle = .lightContent
        }
    }
    /// Set the toolbar colors (background and items) according to the current theme and to whether the reader is visible or not.
    private func updateToolbarColors() {
        if !self.isReaderEnabled {
            navigationController?.toolbar.barTintColor = Constant.browserBackgroundColor
            readerBarBtnItem?.tintColor = Constant.browserControlColor
            navigationController?.navigationBar.isTranslucent = true
        } else if self.reader.readerTheme == .light {
            self.readerThemeBtnItem?.tintColor = Constant.darkReaderBackgroundColor
            navigationController?.toolbar.barTintColor = Constant.lightReaderBackgroundColor
            readerBiggerTextBarBtnItem?.tintColor = Constant.lightReaderControlColor
            readerSmallerTextBarBtnItem?.tintColor = Constant.lightReaderControlColor
            readerBarBtnItem?.tintColor = Constant.lightReaderControlColor
            readerSerifBarBtnItem?.tintColor = Constant.lightReaderControlColor
            navigationController?.toolbar.isTranslucent = false
        } else if self.reader.readerTheme == .dark {
            self.readerThemeBtnItem?.tintColor = Constant.lightReaderBackgroundColor
            navigationController?.toolbar.barTintColor = Constant.darkReaderBackgroundColor
            readerBiggerTextBarBtnItem?.tintColor = Constant.darkReaderControlColor
            readerSmallerTextBarBtnItem?.tintColor = Constant.darkReaderControlColor
            readerBarBtnItem?.tintColor = Constant.darkReaderControlColor
            readerSerifBarBtnItem?.tintColor = Constant.darkReaderControlColor
            navigationController?.toolbar.isTranslucent = false
        }
    }
    
    
    private func updateReaderBackgroundColor() {
        if self.reader.readerTheme == .light {
            self.reader.backgroundColor = Constant.lightReaderBackgroundColor
            self.reader.scrollView.backgroundColor = Constant.lightReaderBackgroundColor
            self.view.backgroundColor = Constant.lightReaderBackgroundColor
        } else if self.reader.readerTheme == .dark {
            self.reader.backgroundColor = Constant.darkReaderBackgroundColor
            self.reader.scrollView.backgroundColor = Constant.darkReaderBackgroundColor
            self.view.backgroundColor = Constant.darkReaderBackgroundColor
        }
        
    }
    
    
    private func setupToolBar() {
        self.navigationController?.toolbarItems = []
        
        initToolbarItems() // instanciate toolbar items
    }
    
    private func initToolbarItems() {
        undoBarBtnItem = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: self, action: #selector(undoWebView))
        undoBarBtnItem!.isEnabled = false
        refreshBarBtnItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshWebView))
        redoBarBtnItem = UIBarButtonItem(image: #imageLiteral(resourceName: "forward"), style: .plain, target: self, action: #selector(redoWebView))
        redoBarBtnItem!.isEnabled = false
        readerBarBtnItem = UIBarButtonItem(image: #imageLiteral(resourceName: "reader"), style: .plain, target: self, action: #selector(enableReader))
        readerBarBtnItem!.isEnabled = false
        readerBiggerTextBarBtnItem = UIBarButtonItem(image: #imageLiteral(resourceName: "font-size"), style: .plain, target: self, action: #selector(biggerReader))
        readerSmallerTextBarBtnItem = UIBarButtonItem(image: #imageLiteral(resourceName: "font-size-small"), style: .plain, target: self, action: #selector(smallerReader))
        readerSerifBarBtnItem = UIBarButtonItem(image: #imageLiteral(resourceName: "serif"), style: .plain, target: self, action: #selector(serifBtnTapped))
        
        readerThemeBtnItem = UIBarButtonItem(image: #imageLiteral(resourceName: "color"), style: .plain, target: self, action: #selector(changeReaderTheme))
    }
    
    
    
    // MARK: - Reader management
    // ========================
    
    private func showReader() {
        if (self.readerTopConstraint != nil) {
            self.readerTopConstraint!.constant = 0//-(self.navigationController?.navigationBar.frame.height ?? 0) - 20
            UIView.animate(withDuration: 0.4) {
                self.view.layoutIfNeeded()
            }
        }
        reloadToolbarItems()
    }
    private func hideReader() {
        if (self.readerTopConstraint != nil) {
            self.readerTopConstraint!.constant = webView.frame.height
            UIView.animate(withDuration: 0.4) {
                self.view.layoutIfNeeded()
            }
        }
        reloadToolbarItems()
    }
    
    /// Depending on wether the reader is visible or not, shows/hides the correct toolbar's buttons
    private func reloadToolbarItems() {
        var items: [UIBarButtonItem] = []
        let flexibleSpace = {() -> UIBarButtonItem in return UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil) }
        
        if !isReaderEnabled {
            items = [undoBarBtnItem!, flexibleSpace(), refreshBarBtnItem!, flexibleSpace(), redoBarBtnItem!, flexibleSpace(), readerBarBtnItem!]
        } else {
            items = [readerBiggerTextBarBtnItem!, flexibleSpace(), readerSmallerTextBarBtnItem!, flexibleSpace(), readerSerifBarBtnItem!, flexibleSpace(), readerThemeBtnItem!, flexibleSpace(), readerBarBtnItem!]
        }
        toolbarItems = items
    }
    
    
    // MARK: - Toolbar controls
    // ============================
    
    @objc private func undoWebView() {
        webView.goBack()
    }
    @objc private func refreshWebView() {
        webView.reload()
    }
    @objc private func redoWebView() {
        webView.goForward()
    }
    @objc private func enableReader() {
        self.isReaderEnabled = !self.isReaderEnabled
    }
    @objc private func biggerReader() {
        if self.reader.readerContentSize == .small {
            self.reader.readerContentSize = .medium
        } else if self.reader.readerContentSize == .medium {
            self.reader.readerContentSize = .large
        }
        readerBiggerTextBarBtnItem?.isEnabled = self.reader.readerContentSize != .large
        readerSmallerTextBarBtnItem?.isEnabled = self.reader.readerContentSize != .small
    }
    @objc private func smallerReader() {
        if self.reader.readerContentSize == .large {
            self.reader.readerContentSize = .medium
        } else if self.reader.readerContentSize == .medium {
            self.reader.readerContentSize = .small
        }
        readerBiggerTextBarBtnItem?.isEnabled = self.reader.readerContentSize != .large
        readerSmallerTextBarBtnItem?.isEnabled = self.reader.readerContentSize != .small
    }
    @objc private func changeReaderTheme() {
        if self.reader.readerTheme == .dark {
            self.reader.readerTheme = .light
            
        } else if self.reader.readerTheme == .light {
            self.reader.readerTheme = .dark
        }
        updateToolbarColors()
        updateNavbarColors()
        updateReaderBackgroundColor()
    }
    
    @objc private func serifBtnTapped() {
        self.reader.fontSerif = !self.reader.fontSerif
        if self.reader.fontSerif {
            readerSerifBarBtnItem?.image = #imageLiteral(resourceName: "sansSerif").withRenderingMode(.alwaysTemplate)
        } else {
            readerSerifBarBtnItem?.image = #imageLiteral(resourceName: "serif").withRenderingMode(.alwaysTemplate)
        }
    }
    
    
    
    // MARK: - Navigation delegate
    // ============================
    // New request
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        readerBarBtnItem!.isEnabled = false
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        self.progressBar.isHidden = false
        
        self.reader.load(url: webView.url!)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        self.progressBar.isHidden = true
    }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        self.progressBar.isHidden = true
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            self.progressBar.isHidden = false
            self.progressBar.setProgress(Float(webView.estimatedProgress), animated: true)
        } else if keyPath == "title" {
            navBarTitleView?.title = webView.title
            navBarTitleView?.subtitle = webView.url?.absoluteString
        } else if keyPath == "canGoBack" {
            undoBarBtnItem!.isEnabled = webView.canGoBack
        } else if keyPath == "canGoForward" {
            redoBarBtnItem!.isEnabled = webView.canGoForward
        }
        
    }
    
    
    /// New page loaded
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // progressBar
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        self.progressBar.isHidden = true
        self.progressBar.setProgress(0, animated: false)
        
        // undo - redo
        undoBarBtnItem!.isEnabled = webView.canGoBack
        redoBarBtnItem!.isEnabled = webView.canGoForward
        navBarTitleView!.backButton.isHidden = !(webView.canGoBack || webView.canGoForward)
        navBarTitleView!.forwardButton.isHidden = !(webView.canGoBack || webView.canGoForward)
        navBarTitleView!.backButton.isEnabled = webView.canGoBack
        navBarTitleView!.forwardButton.isEnabled = webView.canGoForward
    }
    
    // MARK: - Reader delegate
    // ============================
    
    /// Define what to do if the user clicks on a link inside the reader
    func navigationRequested(request: URLRequest, navigationType: WKNavigationType) {
        if navigationType != .other {
            self.isReaderEnabled = false
            self.webView.load(request)
        }
    }
    
    func contentDidLoad(reader: ReaderWebView, content: MercuryResponse) {
        self.readerBarBtnItem!.isEnabled = true
    }
    func contentFailedToLoad(reader: ReaderWebView, url: URL?, content: MercuryResponse?) {
        self.isReaderEnabled = false
        self.readerBarBtnItem!.isEnabled = false
    }
    func readerInitialized(reader: ReaderWebView) {
        
    }
}




