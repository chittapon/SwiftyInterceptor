//
//  PostDetailUITests.swift
//  SwiftyInterceptor_ExampleUITests
//
//  Created by Chittapon Thongchim on 4/6/2566 BE.
//  Copyright © 2566 BE CocoaPods. All rights reserved.
//

import XCTest
import SwiftyInterceptor

final class PostDetailUITests: XCTestCase {

    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        Interceptor.mock(MockPost())
        app = XCUIApplication()
        app.launchEnvironment["INTERCEPTOR_UITESTING_ENABLED"] = "1"
        app.launch()
    }

    override func tearDownWithError() throws {}

    func testDisplayPosts() {
        app.tables.cells.allElementsBoundByIndex[4].tap()
        XCTAssert(app.staticTexts["nesciunt quas odio"].exists)
    }
}
