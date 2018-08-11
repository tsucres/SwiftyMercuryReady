//
//  SwiftyMercuApi.swift
//  SwiftyMercuryReady
//
//  Created by Stéphane Sercu on 1/07/17.
//  Copyright © 2017 Stéphane Sercu. All rights reserved.
//

import Foundation

/**
 Interface to the Mercury api. 
 Just send an url and retrieve the parsed content 
 of the page the url points to.
 */
open class MercuryApi {
    private var apiKey = ""
    private let apiUrl = "https://mercury.postlight.com/parser?url="
    
    private init() {
        var keys: NSDictionary?
        if let path = Bundle.main.path(forResource: "keys", ofType: "plist") {
            keys = NSDictionary(contentsOfFile: path)
        }
        if let mercuryKey = keys?["mercuryApiKey"] {
            self.apiKey = mercuryKey as! String
        } else {
            fatalError("API key not found.")
        }
    }
    
    public static let shared = MercuryApi()
    
    public func parseUrl(url: String, completion: ((MercuryResponse?) -> Void)!) {
        var req = URLRequest(url: URL(string: self.apiUrl + url)!)
        req.addValue(self.apiKey, forHTTPHeaderField: "x-api-key")
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        getJson(request: req, completion: { json -> Void in
            if json == nil {
                completion(nil)
            } else {
                if (json!.count == 1 && (((json!["message"] as? String) != nil))) ||
                    (json!.count == 2 && (((json!["messages"] as? String) != nil)) && (((json!["error"] as? Int) != nil))) {
                    completion(nil) // Error
                } else {
                    completion(MercuryResponse(fromJson: json!))
                }
            }
        })
    }
    
    /// Helper function which send HTTP req. and parse the json content in the response (if any)
    private func getJson(request: URLRequest, completion: @escaping ([String: Any]?) -> Void) {
        var req = request
        req.cachePolicy = .returnCacheDataElseLoad
        let task = URLSession.shared.dataTask(with: req, completionHandler: {(data, response, error) -> Void in
            
            guard let responseData = data else {
                print("Error: did not receive data") // TODO: error handling
                DispatchQueue.main.async(execute: { ()->() in
                    completion(nil)
                })
                return
            }
            
            guard let JSON = try? JSONSerialization.jsonObject(with: responseData, options: .mutableContainers) as! [String: Any]
                else {
                    DispatchQueue.main.async(execute: { ()->() in
                        completion(nil)
                    })
                    return
            }
            DispatchQueue.main.async(execute: { ()->() in
                completion(JSON)
            })
        })
        task.resume()
    }
}

/// Abstraction of a typical json response sent by the api.
open class MercuryResponse {
    init(fromJson json: [String: Any]) {
        self.title = json["title"] as? String
        self.author = json["author"] as? String
        self.content = json["content"] as? String
        if let dateString = json["date_published"] as? String {
            self.date_published = parseDate(date: dateString)
        }
        self.lead_image_url = json["lead_image_url"] as? String
        self.dek = json["dek"] as? String
        self.url = json["url"] as? String // TODO: URL instead of String
        self.domain = json["domain"] as? String
        self.excerpt = json["excerpt"] as? String
        self.word_count = json["word_count"] as? Int
        self.direction = json["direction"] as? String
        self.total_pages = json["total_pages"] as? Int
        self.rendered_pages = json["rendered_pages"] as? Int
        self.next_page_url = json["next_page_url"] as? String
    }
    
    /// Transform the date returned by the API (string format: 2017-06-13T00:14:56.000Z) to a Date object
    private func parseDate(date: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return dateFormatter.date(from: date)!
    }
    
    var title: String?
    var author: String?
    var content: String?
    var date_published: Date?
    var lead_image_url: String?
    var dek: String?
    var url: String?
    var domain: String?
    var excerpt: String?
    var word_count: Int?
    var direction: String?
    var total_pages: Int?
    var rendered_pages: Int?
    var next_page_url: String?
}
