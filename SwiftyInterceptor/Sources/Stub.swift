//
//  Stub.swift
//  Interceptor
//
//  Created by Chittapon Thongchim on 25/5/2566 BE.
//

import Foundation

public final class Stub: Encodable {
    
    public var url: URL?
    public var headers: [String : String]?
    public var status: Int
    public var body: Data?
    public var delay: TimeInterval?
    
    public var response: HTTPURLResponse? {
        guard let url = url else { return nil }
        return HTTPURLResponse(
            url: url,
            statusCode: status,
            httpVersion: nil,
            headerFields: headers
        )
    }
    
    public init(
        url: URL?,
        headers: [String: String]? = nil,
        status: Int = 0,
        body: Data? = nil,
        delay: TimeInterval? = nil
    ) {
        self.url = url
        self.headers = headers
        self.status = status
        self.body = body
        self.delay = delay
    }
    
    public static func buildJSON(url: URL?, body: Any?, status: Int = 200) -> Stub {
        guard let body = body else { return .init(url: url, status: status) }
        var _body: Data?
        if JSONSerialization.isValidJSONObject(body) {
            _body = try? JSONSerialization.data(withJSONObject: body, options: [])
        }
        return .init(url: url, status: status, body: _body)
    }
    
    public static func buildString(url: URL?, body: String?, status: Int = 200) -> Stub {
        guard let body = body else { return .init(url: url, status: status) }
        let _body = body.data(using: .utf8)
        return .init(url: url, status: status, body: _body)
    }
    
    public static func buildEncodable(url: URL?, body: Encodable?, status: Int = 200) -> Stub {
        guard let body = body else { return .init(url: url, status: status) }
        let _body = try? JSONEncoder().encode(body)
        return .init(url: url, status: status, body: _body)
    }

}
