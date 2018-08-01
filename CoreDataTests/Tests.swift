//
//  Test1.swift
//  CoreDataTests
//
//  Created by Sergey Garazha on 8/1/18.
//  Copyright © 2018 Mindful, Inc. All rights reserved.
//

import XCTest
@testable import TestCoreData

class Tests: XCTestCase {
    
    let testClass1 = Test1()
    let testClass2 = Test2()
    let testClass3 = Test3()
    
    func test1() {
        XCTAssert(testClass1.start())
    }
    
    func test2() {
        XCTAssert(testClass2.start())
    }
    
    func test3() {
        XCTAssert(testClass3.start())
    }
}
