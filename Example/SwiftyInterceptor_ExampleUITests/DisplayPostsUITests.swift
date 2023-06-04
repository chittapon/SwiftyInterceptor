//
//  DisplayPostsUITests.swift
//  SwiftyInterceptor_ExampleUITests
//
//  Created by Chittapon Thongchim on 4/6/2566 BE.
//  Copyright © 2566 BE CocoaPods. All rights reserved.
//

import XCTest
import SwiftyInterceptor

final class DisplayPostsUITests: XCTestCase {

    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        Interceptor.mock(MockPost())
        app = XCUIApplication()
        app.launchEnvironment["INTERCEPTOR_UITESTING_ENABLED"] = "1"
        app.launch()
    }

    override func tearDownWithError() throws {}

    func testDisplayPosts() {
        XCTAssert(app.cells.count == 5)
    }
}

func jsonFromFile(name: String) -> String? {
    guard let url = Bundle(for: DisplayPostsUITests.self).url(forAuxiliaryExecutable: name) else {
        assert(false, "Invalid path")
    }
    let data = (try? Data(contentsOf: url)) ?? Data()
    return String(data: data, encoding: .utf8)
}

struct MockPost: Mockable {
    let requestPattern: RequestPattern = .init(method: "GET", url: .init(kind: .path, value: "posts"))
    let response: Stub = .buildString(url: nil, body: jsonFromFile(name: "response.json"))
}
