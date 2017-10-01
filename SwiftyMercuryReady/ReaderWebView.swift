//
//  ViewController.swift
//  SwiftyMercuryReady
//
//  Created by Stéphane Sercu on 1/07/17.
//  Copyright © 2017 Stéphane Sercu. All rights reserved.
//

import UIKit
import WebKit

protocol ReaderDelegate: NSObjectProtocol {
    func navigationRequested(request:  URLRequest, navigationType: WKNavigationType)
    func contentDidLoad(reader: ReaderWebView, content: MercuryResponse)
    func contentFailedToLoad(reader: ReaderWebView, url: URL?, content: MercuryResponse?)
    func readerInitialized(reader: ReaderWebView)
}
/**
 A WKWebView subclass that loads a template Html that's filled with the data returned by the MercuryApi.
 */
class ReaderWebView: WKWebView, WKNavigationDelegate {
    private let htmlTemplatePath = "HTMLReader/readerTemplate"
    
    private let darkModeBackground: UIColor = #colorLiteral(red: 0.09018597752, green: 0.09020193666, blue: 0.09017866105, alpha: 1)
    private let lightModeBackground: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    
    private var _initialised: Bool = false
    /// Indicates if the template is loaded or not
    var initialized: Bool {
        get {
            return _initialised
        }
    }
    
    private var _url: URL?
    /// The url pointing to the loaded content
    override var url: URL? {
        get {
            return self._url
        }
    }
    
    private var _mercuryResponse: MercuryResponse?
    public var mercuryResponse: MercuryResponse? {
        get {
            return _mercuryResponse
        }
    }
    
    public weak var readerDelegate: ReaderDelegate?
    
    
    /// Availlable content sizes
    enum ReaderContentSize: Int {
        case small = 0
        case medium = 1
        case large = 2
    }
    /// Available themes
    enum ReaderContentTheme: Int {
        case light = 0
        case dark = 1
    }
    
    /// Currently displayed theme
    var readerTheme: ReaderContentTheme = .dark {
        didSet {
            let jsTheme = "setTheme(\(self.readerTheme.rawValue));"
            self.evaluateJavaScript(jsTheme, completionHandler: nil)
            
            if readerTheme == .dark {
                self.backgroundColor = darkModeBackground
                self.scrollView.backgroundColor = darkModeBackground
            } else if readerTheme == .light {
                self.backgroundColor = lightModeBackground
                self.scrollView.backgroundColor = lightModeBackground
            }
        }
    }
    /// Current size of the content
    var readerContentSize: ReaderContentSize = .medium {
        didSet { //TODO: FIXME : Why on earth when I come from .small, the size of the body stops changing? If I set the font-size (in style-sm.css) to something  greater than 29px it works... anything under than that breaks it...
            let jsSize = "setSize(\(self.readerContentSize.rawValue));"
            self.evaluateJavaScript(jsSize, completionHandler: nil)
        }
    }
    
    /// Indicates whether to use a serif font or not
    var fontSerif: Bool = true {
        didSet {
            let jsSerif = "setSerif(\((fontSerif ? 1 : 0)));"
            self.evaluateJavaScript(jsSerif, completionHandler: nil)
        }
    }
    
    /// Fills the template with a title for its content
    func setContentTitle(title: String, completion: ((Any?, Error?) -> Void)? = nil) {
        let jsHeadline = "setHeadline(\"\(escapeHtml(title))\");"
        self.evaluateJavaScript(jsHeadline, completionHandler: completion)
    }
    /// Fills the template body
    func setContent(body: String, completion: ((Any?, Error?) -> Void)? = nil) {
        let jsContent = "setContent(\"\(escapeHtml(body))\");"
        self.evaluateJavaScript(jsContent, completionHandler: completion)
    }
    /// Fills the template with a domain name
    func setContentDomain(domain: String, completion: ((Any?, Error?) -> Void)? = nil) {
        let jsDomain = "setDomain(\"\(domain)\");"
        self.evaluateJavaScript(jsDomain, completionHandler: completion)

    }
    /// Fills the template with an author name
    func setContentAuthor(author: String, completion: ((Any?, Error?) -> Void)? = nil) {
        let jsAuthor = "setAuthor(\"\(author)\");"
        self.evaluateJavaScript(jsAuthor, completionHandler: completion)
    }
    
    /// Fills the template with a publication date
    func setContentDate(date: String, completion: ((Any?, Error?) -> Void)? = nil) {
        let jsDate = "setPublicationDate(\"\(date)\");"
        self.evaluateJavaScript(jsDate, completionHandler: completion)
    }
    
    /* This method is used to insert html received by the api in the template. 
        Reason: the insertion is made through javascript and some special 
        characters break the js code.
    */
    private func escapeHtml(_ html: String) -> String {
        let chars: [String: String] = ["\n": "<br />",
                                       "\r": "<br />",
                                       "\t": "",
                                       "\0": "",
                                       "\"": "\\u0022",]
        var result = html
        for (target, fix) in chars {
            result = result.replacingOccurrences(of: target, with: fix)
        }
        return result
    }
    
    private func setLoaderVisibility(_ visible: Bool) {
        let jsLoader = visible ? "showLoader();" : "hideLoader();"
        self.evaluateJavaScript(jsLoader, completionHandler: nil)
    }
    
    convenience init() {
        self.init(frame: .zero, configuration: WKWebViewConfiguration())
    }
    
    
    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        self.navigationDelegate = self
        
        reloadTemplate()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    /**
     Parse the content pointed by the specified URL through the Mercury Api and render the resulting data
     */
    func load(url: URL) {
        self.clearData()
        setLoaderVisibility(true)
        MercuryApi.shared.parseUrl(url: url.absoluteString, completion: {(resp) -> Void in
            if resp == nil {
                self.readerDelegate?.contentFailedToLoad(reader: self, url: url, content: resp)
                return
            }
            self._url = url
            self.load(MercuryResponse: resp!)
            
            
        })
    }
    
    public func clearData() {
        let jsClear = "clearData();"
        self.evaluateJavaScript(jsClear, completionHandler: nil)
    }
    
    public func load(MercuryResponse resp: MercuryResponse) {
        if let respUrl = URL(string: resp.url!) {
            if respUrl.host == self._url!.host && respUrl.path == self._url!.path && respUrl.fragment == self._url!.fragment { // We don't compare the protocol (http/https/other?)
                if resp.content != nil {
                    self._mercuryResponse = resp
                    
                    if !initialized {
                        return // The content will be loaded when the reader finishes loading the template
                    }
                    let group = DispatchGroup()
                    
                    // Fill the reader html (template) with the content received from Mercury
                    group.enter()
                    self.setContentDomain(domain: resp.domain ?? "", completion: {(jsResult, error) -> Void in
                        group.leave()
                    })
                    
                    group.enter()
                    self.setContentAuthor(author: resp.author ?? "", completion: {(jsResult, error) -> Void in
                        group.leave()
                    })
                    
                    group.enter()
                    self.setContentTitle(title: resp.title ?? "", completion: {(jsResult, error) -> Void in
                        group.leave()
                    })
                    
                    if resp.date_published != nil {
                        group.enter()
                        self.setContentDate(date: DateFormatter.localizedString(from: resp.date_published!, dateStyle: .medium, timeStyle: .none), completion: {(jsResult, error) -> Void in
                            group.leave()
                        })
                    }
                    
                    group.enter()
                    self.setContent(body: resp.content!, completion: {(jsResult, error) -> Void in
                        group.leave()
                    })
                    
                    
                    group.notify(queue: .main) {
                        self.setLoaderVisibility(false)
                        self.readerDelegate?.contentDidLoad(reader: self, content: resp)
                    }
                    
                } else {
                    self.readerDelegate?.contentFailedToLoad(reader: self, url: URL(string: resp.url!), content: resp)
                }
            } else {
                // We don't bother filling the content if the user already asked to load another url
                // TODO: (what about redirection?)
                self.readerDelegate?.contentFailedToLoad(reader: self, url: URL(string: resp.url!), content: resp)
            }
            
        } else {
            // Is this possible?
            self.readerDelegate?.contentFailedToLoad(reader: self, url: nil, content: nil)
        }
    }
    
    
    
    /**
     Enable and disable the stylesheets setting the size
     and the theme of the reader according to the current
     configuration.
     */
    private func initReaderCSS() {
        self.fontSerif = false
        self.readerContentSize = .medium
        self.readerTheme = .dark
    }
    
    /**
     Reload the html of the reader (with no content, just the template)
     */
    private func reloadTemplate() {
        let htmlPath = Bundle.main.path(forResource: htmlTemplatePath, ofType: "html")
        let htmlUrl = URL(fileURLWithPath: htmlPath!, isDirectory: false)
        self.loadFileURL(htmlUrl, allowingReadAccessTo: htmlUrl)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if !_initialised {
            initReaderCSS()
            _initialised = true
            self.readerDelegate?.readerInitialized(reader: self)
            
            // In case a load(..) method was called before the initialisation
            if self._mercuryResponse != nil {
                self.load(MercuryResponse: self._mercuryResponse!)
            } else if self._url != nil {
                self.load(url: _url!)
            }
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if navigationAction.navigationType != .reload && navigationAction.request.url?.scheme != "file" {
            self.readerDelegate?.navigationRequested(request: navigationAction.request, navigationType: navigationAction.navigationType)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
}


