//
//  SwiftyMercuryReadyTesty.swift
//  SwiftyMercuryReadyTesty
//
//  Created by Stéphane Sercu on 25/06/18.
//  Copyright © 2018 Stéphane Sercu. All rights reserved.
//

import XCTest

class SwiftyMercuryReadyTesty: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    /// URLs that should be succesfully parsed by the API and handled by the MercuryApi client
    let parsableExamples = [
        "http://www.thetransportpolitic.com/2017/07/01/a-generational-failure-as-the-u-s-fantasizes-the-rest-of-the-world-builds-a-new-transport-system/",
        "https://blog.ipinfo.io/api-side-project-to-250-million-requests-with-0-marketing-budget-bb0de01c01f6",
        "http://aging.nautil.us/feature/226/how-aging-research-is-changing-our-lives",
        "https://www.sec.gov/litigation/litreleases/2017/lr23870.htm",
        "https://www.eff.org/alice",
        "https://drikerf.com/building-pixels-a-daily-source-of-inspiration/",
        "https://open.nytimes.com/react-relay-and-graphql-under-the-hood-of-the-times-website-redesign-22fb62ea9764",
        "https://blog.2ndquadrant.com/what-is-select-skip-locked-for-in-postgresql-9-5/",
        "http://biosrhythm.com/?page_id=1453",
        "http://ruslanledesma.com/2016/06/17/why-does-heap-work.html",
        "https://www.youtube.com/watch?v=IuEEEwgdAZs",
    ]
    
    /// URLs that aren't parsable bu Mercury Api but that should be handled by the client
    let nonParsableExamples = ["https://www.flightradar24.com/53.84,2.19/4"]
    
    /// examples of bad urls and other error-causing cases
    let failingExamples = ["notAnURL"]
    
    func testParsableExamples() {
        var exps: [String: XCTestExpectation] = [:]
        for str_urls in parsableExamples {
            exps[str_urls] = expectation(description: str_urls + " should be parsed")
            MercuryApi.shared.parseUrl(url: str_urls, completion: {(resp) -> Void in
                XCTAssertNotNil(resp)
                exps[str_urls]!.fulfill()
            })
        }
        wait(for: Array(exps.values), timeout: 20)
    }
    
    func testNonParsableExamples() {
        var exps: [String: XCTestExpectation] = [:]
        for str_urls in nonParsableExamples {
            exps[str_urls] = expectation(description: str_urls + " shouldn't be parsed")
            MercuryApi.shared.parseUrl(url: str_urls, completion: {(resp) -> Void in
                XCTAssertNil(resp)
                exps[str_urls]!.fulfill()
            })
        }
        wait(for: Array(exps.values), timeout: 20)
    }
    func testFailingExamples() {
        var exps: [String: XCTestExpectation] = [:]
        for str_urls in failingExamples {
            exps[str_urls] = expectation(description: str_urls + " shouldn't be parsed")
            MercuryApi.shared.parseUrl(url: str_urls, completion: {(resp) -> Void in
                XCTAssertNil(resp)
                exps[str_urls]!.fulfill()
            })
        }
        wait(for: Array(exps.values), timeout: 20)
    }
    
}
