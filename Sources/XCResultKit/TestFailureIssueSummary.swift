//
//  File.swift
//  
//
//  Created by David House on 6/30/19.
//
//- TestFailureIssueSummary
//    * Supertype: IssueSummary
//* Kind: object
//* Properties:
//+ testCaseName: String

import Foundation

struct TestFailureIssueSummary: XCResultObject {
    let testCaseName: XCResultString?
    
    init?(_ json: [String : AnyObject]) {
        testCaseName = parse(element: "testCaseName", from: json)
    }
}