//
//  ArticlesReaderDemo.swift
//  SwiftyMercuryReady
//
//  Created by Stéphane Sercu on 2/07/17.
//  Copyright © 2017 Stéphane Sercu. All rights reserved.
//

import UIKit

/**
 Model class of an article, containing a title and a url
 */
class Article {
    var title: String
    var url: String
    var domain: String {
        get {
            var dom: String = URL(string: self.url)!.host!
            if dom.hasPrefix("www.") {
                dom = String(dom.dropFirst(4))
            }
            return dom
        }
    }
    
    init(title: String, url: String) {
        self.title = title
        self.url = url
    }
}


/**
 TableView displaying Articles: each cell contains the 
 title of the article and the domain name of the host
 */
class ArticleTableViewController: UITableViewController {
    let articles = [Article(title: "A generational failure: As the U.S. fantasizes, the rest of the world builds a new transport system",
                            url: "http://www.thetransportpolitic.com/2017/07/01/a-generational-failure-as-the-u-s-fantasizes-the-rest-of-the-world-builds-a-new-transport-system/"),
                    Article(title: "How I Took an API Side Project to over 250 Million Daily Requests With a $0 Marketing Budget",
                            url: "https://blog.ipinfo.io/api-side-project-to-250-million-requests-with-0-marketing-budget-bb0de01c01f6"),
                    Article(title: "How Aging Research Is Changing Our Lives",
                            url: "http://aging.nautil.us/feature/226/how-aging-research-is-changing-our-lives"),
                    Article(title: "SEC Files Fraud Charges in Bitcoin and Office Space Investment Schemes",
                            url: "https://www.sec.gov/litigation/litreleases/2017/lr23870.htm"),
                    Article(title: "Saved by Alice",
                            url: "https://www.eff.org/alice"),
                    Article(title: "Building Pixels - A Daily Source of Inspiration",
                            url: "https://drikerf.com/building-pixels-a-daily-source-of-inspiration/"),
                    Article(title: "React, Relay and GraphQL: Under the Hood of the Times Website Redesign",
                            url: "https://open.nytimes.com/react-relay-and-graphql-under-the-hood-of-the-times-website-redesign-22fb62ea9764"),
                    Article(title: "What is SKIP LOCKED for in PostgreSQL 9.5?",
                            url: "https://blog.2ndquadrant.com/what-is-select-skip-locked-for-in-postgresql-9-5/"),
                    Article(title: "WiFi232 – An Internet Hayes Modem for your Retro Computer",
                            url: "http://biosrhythm.com/?page_id=1453"),
                    Article(title: "Why does Heap's algorithm work?",
                            url: "http://ruslanledesma.com/2016/06/17/why-does-heap-work.html"),
                    Article(title: "How SQL Database Engines Work, by the Creator of SQLite (2008) [video]",
                            url:"https://www.youtube.com/watch?v=Z_cX3bzkExE"),
                    Article(title: "OpenAI Five",
                            url:"https://blog.openai.com/openai-five/"),
                    Article(title: "“No Man’s Sky” Displayed on the Amiga 1000",
                            url:"http://www.bytecellar.com/2018/03/14/a-planetary-anachronism-no-mans-sky-beautifully-rendered-on-the-amiga-1000/"),
                    ]
    
    private let cellId = "articleCellid"
    
    override func viewDidLoad() {
        tableView.register(ArticleCell.self, forCellReuseIdentifier: cellId)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 500.0
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
    }
    
	override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barTintColor = .white
        self.navigationController!.navigationBar.backgroundColor = .clear
        self.navigationController!.navigationBar.tintColor = .clear
        self.navigationController!.navigationBar.isTranslucent = true
        self.navigationController!.isToolbarHidden = true
        self.navigationController!.toolbar.isTranslucent = true
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as! ArticleCell
        cell.title = articles[indexPath.row].title
        cell.subtitle = articles[indexPath.row].domain
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = ArticleReaderController()
        
        
        //controller.isReaderEnabled = true
        
        let backItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
        controller.url = URL(string: articles[indexPath.row].url)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
}


/// TableView cell containg a Title and a subtitle under it
class ArticleCell: UITableViewCell {
    var title: String = "title" {
        didSet {
            self.titleLabel.text = title
        }
    }
    var subtitle: String = "subtitle" {
        didSet {
            self.subtitleLabel.text = subtitle
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(subtitleLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
        
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
        subtitleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
        subtitleLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
        subtitleLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.medium)
        lbl.numberOfLines = 0
        return lbl
    }()
    let subtitleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.thin)
        
        return lbl
    }()
}
