//
//  NavBarTitleView.swift
//  SwiftyMercuryReady
//
//  Created by Stéphane Sercu on 11/09/17.
//  Copyright © 2017 Stéphane Sercu. All rights reserved.
//

import UIKit

/// UIView with a title, subtitle and back/forward buttons aimed to be used in a NavBar to control a webView.
class NavBarTitleView: UIView {
    public var itemsColor: UIColor = .white {
        didSet {
            self.titleLabel.textColor = itemsColor
            self.backButton.tintColor = itemsColor
            self.forwardButton.tintColor = itemsColor
            self.subtitleLabel.textColor = itemsColor
        }
    }
    
    public var title: String? {
        get {
            return self.titleLabel.text
        }
        set(value) {
            self.titleLabel.text = value
        }
    }
    
    
    public var subtitle: String? {
        get {
            return self.subtitleLabel.text
        }
        set(value) {
            self.subtitleLabel.text = value
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(backButton)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        backButton.widthAnchor.constraint(equalToConstant: 18).isActive = true
        backButton.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        backButton.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        
        self.addSubview(forwardButton)
        forwardButton.translatesAutoresizingMaskIntoConstraints = false
        forwardButton.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        forwardButton.widthAnchor.constraint(equalToConstant: 18).isActive = true
        forwardButton.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        forwardButton.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        
        
        self.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 20).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: forwardButton.leadingAnchor, constant: -20).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 18).isActive = true
        
        self.addSubview(subtitleLabel)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
        subtitleLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 20).isActive = true
        subtitleLabel.trailingAnchor.constraint(equalTo: forwardButton.leadingAnchor, constant: -20).isActive = true
        subtitleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -4).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .center
        lbl.numberOfLines = 1
        lbl.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.light)
        return lbl
    }()
    
    let subtitleLabel: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .center
        lbl.numberOfLines = 1
        lbl.font = UIFont.systemFont(ofSize: 9, weight: UIFont.Weight.light)
        return lbl
    }()
    
    let backButton: UIButton = {
        let btn = UIButton()
        btn.setImage(#imageLiteral(resourceName: "back").withRenderingMode(.alwaysTemplate), for: .normal)
        
        return btn
    }()
    
    let forwardButton: UIButton = {
        let btn = UIButton()
        btn.setImage(#imageLiteral(resourceName: "forward").withRenderingMode(.alwaysTemplate), for: .normal)
        
        return btn
    }()
}
