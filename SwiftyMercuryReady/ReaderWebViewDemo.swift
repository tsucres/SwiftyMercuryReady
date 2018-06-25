//
//  ReaderWebViewDemo.swift
//  SwiftyMercuryReady
//
//  Created by Stéphane Sercu on 10/09/17.
//  Copyright © 2017 Stéphane Sercu. All rights reserved.
//

import UIKit

class ReaderWebViewController: UIViewController {
    private let readerWebView = ReaderWebView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(readerWebView)
        readerWebView.translatesAutoresizingMaskIntoConstraints = false
        readerWebView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        readerWebView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        readerWebView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        readerWebView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        
        //readerWebView.load(url: URL(string: "https://www.eff.org/alice")!)
        //readerWebView.load(url: URL(string: "https://www.flightradar24.com/FIN6KC/f31526e")!)
        readerWebView.load(url: URL(string: "https://blog.openai.com/openai-five/")!)
        
        let btnTheme = UIButton()
        btnTheme.setTitle("Theme", for: .normal)
        self.view.addSubview(btnTheme)
        btnTheme.backgroundColor = .blue
        btnTheme.translatesAutoresizingMaskIntoConstraints = false
        btnTheme.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30).isActive = true
        btnTheme.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 100).isActive = true
        btnTheme.addTarget(self, action: #selector(themeBtnTapped), for: .touchUpInside)
        
        let btnSize = UIButton()
        btnSize.setTitle("Size", for: .normal)
        btnSize.backgroundColor = .blue
        self.view.addSubview(btnSize)
        btnSize.translatesAutoresizingMaskIntoConstraints = false
        btnSize.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30).isActive = true
        btnSize.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 150).isActive = true
        btnSize.addTarget(self, action: #selector(sizeThemeTapped), for: .touchUpInside)
        
        let btnSerif = UIButton()
        btnSerif.setTitle("Serif", for: .normal)
        btnSerif.backgroundColor = .blue
        self.view.addSubview(btnSerif)
        btnSerif.translatesAutoresizingMaskIntoConstraints = false
        btnSerif.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30).isActive = true
        btnSerif.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 200).isActive = true
        btnSerif.addTarget(self, action: #selector(serifBtnTapped), for: .touchUpInside)
        
        UIApplication.shared.statusBarStyle = .lightContent
        
    }
    
    
    @objc func themeBtnTapped() {
        if readerWebView.readerTheme == .light {
            UIApplication.shared.statusBarStyle = .lightContent
            readerWebView.readerTheme = .dark
        } else {
            UIApplication.shared.statusBarStyle = .default
            readerWebView.readerTheme = .light
        }
        
    }
    @objc func serifBtnTapped() {
        readerWebView.fontSerif = !readerWebView.fontSerif
    }
    
    @objc func sizeThemeTapped() {
        if readerWebView.readerContentSize == .large {
            readerWebView.readerContentSize = .small
        } else if readerWebView.readerContentSize == .medium {
            readerWebView.readerContentSize = .large
        } else if readerWebView.readerContentSize == .small {
            readerWebView.readerContentSize = .medium
        }
    }

}
