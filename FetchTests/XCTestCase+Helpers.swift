//
//  XCTestCase+Helpers.swift
//  FetchTests
//
//  Created by Min-Yang Huang on 2024/10/13.
//

import XCTest

extension XCTestCase {
    func anyURL() -> URL {
        return URL(string: "https://any-url.com")!
    }
    
    func anyData() -> Data {
        return Data("any data".utf8)
    }
    
    func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }
}
