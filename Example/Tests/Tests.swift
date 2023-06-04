import XCTest
import SwiftyInterceptor
@testable import SwiftyInterceptor_Example

class Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGetPosts() {
        let vc = ViewController()
        vc.loadViewIfNeeded()
        let expected = expectation(description: "posts count should be 4 items")
        Interceptor.stubResponseHandler = { request in
            return .buildEncodable(url: request.url, body: Post.mock())
        }
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { timer in
            if vc.posts.count == 4 {
                timer.invalidate()
                expected.fulfill()
            }
        })
        wait(for: [expected], timeout: 1)
    }
    
}
