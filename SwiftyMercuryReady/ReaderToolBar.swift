//
//  ReaderToolBar.swift
//  SwiftyMercuryReady
//
//  Created by Stéphane Sercu on 12/09/17.
//  Copyright © 2017 Stéphane Sercu. All rights reserved.
//

import UIKit

/// A view that contains some buttons aimed to control a web reader.
class ReaderControlsView: UIView {
    let hMargin: CGFloat = 8
    
    enum SerifBtnState {
        case serif
        case sans
    }
    enum Theme {
        case dark
        case light
    }
    public var serifBtnState: SerifBtnState = .serif {
        didSet {
            if serifBtnState == .sans {
                self.serifBtn.setImage(#imageLiteral(resourceName: "sansSerif"), for: .normal)
            } else if serifBtnState == .serif {
                self.serifBtn.setImage(#imageLiteral(resourceName: "serif"), for: .normal)
            }
            
        }
    }
    public var theme: Theme = .light {
        didSet {
            setItemsColor()
        }
    }
    
    private func setItemsColor() {
        if self.theme == .dark {
            
        } else if self.theme == .light {
            
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(largerFontBtn)
        largerFontBtn.translatesAutoresizingMaskIntoConstraints = false
        largerFontBtn.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        largerFontBtn.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: hMargin).isActive = true
        largerFontBtn.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        self.addSubview(smallerFontBtn)
        smallerFontBtn.translatesAutoresizingMaskIntoConstraints = false
        smallerFontBtn.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        smallerFontBtn.leadingAnchor.constraint(equalTo: self.largerFontBtn.trailingAnchor).isActive = true
        smallerFontBtn.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        smallerFontBtn.widthAnchor.constraint(equalTo: self.largerFontBtn.widthAnchor).isActive = true
        
        self.addSubview(serifBtn)
        serifBtn.translatesAutoresizingMaskIntoConstraints = false
        serifBtn.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        serifBtn.leadingAnchor.constraint(equalTo: self.smallerFontBtn.trailingAnchor, constant: 30).isActive = true
        serifBtn.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        self.addSubview(themeBtn)
        themeBtn.translatesAutoresizingMaskIntoConstraints = false
        themeBtn.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        themeBtn.leadingAnchor.constraint(equalTo: self.serifBtn.trailingAnchor).isActive = true
        themeBtn.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        themeBtn.widthAnchor.constraint(equalTo: self.serifBtn.widthAnchor).isActive = true
        
        
        self.addSubview(readerActivationBtn)
        readerActivationBtn.translatesAutoresizingMaskIntoConstraints = false
        readerActivationBtn.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        readerActivationBtn.leadingAnchor.constraint(equalTo: self.themeBtn.trailingAnchor).isActive = true
        readerActivationBtn.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -hMargin).isActive = true
        readerActivationBtn.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        readerActivationBtn.widthAnchor.constraint(equalTo: self.serifBtn.widthAnchor).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let largerFontBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(#imageLiteral(resourceName: "font-size").withRenderingMode(.alwaysTemplate), for: .normal)
        btn.tintColor = .gray
        return btn
    }()
    let smallerFontBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(#imageLiteral(resourceName: "font-size-small").withRenderingMode(.alwaysTemplate), for: .normal)
        btn.tintColor = .gray
        return btn
    }()
    let serifBtn: UIButton = {
        let btn = UIButton()
        //btn.setImage(.withRenderingMode(.alwaysTemplate), for: .normal)
        btn.tintColor = .gray
        return btn
    }()
    let themeBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(#imageLiteral(resourceName: "color").withRenderingMode(.alwaysTemplate), for: .normal)
        
        return btn
    }()
    let readerActivationBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(#imageLiteral(resourceName: "reader").withRenderingMode(.alwaysTemplate), for: .normal)
        btn.tintColor = .gray
        return btn
    }()
    
}
