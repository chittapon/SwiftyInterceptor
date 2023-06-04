//
//  Mockable.swift
//  Interceptor
//
//  Created by Chittapon Thongchim on 4/6/2566 BE.
//

import Foundation

public protocol Mockable: Encodable {
    var requestPattern: RequestPattern { get }
    var response: Stub { get }
}

public struct RequestPattern: Codable {

    public var method: String
    public var url: PatternMatch

    public init(method: String, url: PatternMatch) {
        self.method = method
        self.url = url
    }

}

public struct PatternMatch: Codable, Hashable {
    
    public enum Kind: String, Codable {
        case equal, wildcard, regexp, path
    }
    
    public let kind: Kind
    public let value: String
    
    
    public init(kind: Kind, value: String) {
        self.kind = kind
        self.value = value
    }
}
