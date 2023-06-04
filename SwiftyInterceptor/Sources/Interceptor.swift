//
//  Interceptor.swift
//  Interceptor
//
//  Created by Chittapon Thongchim on 25/5/2566 BE.
//

import Foundation

public typealias StubResponseHandler = (URLRequest) -> Stub?
public typealias OnResponse = (URLRequest, HTTPURLResponse?, Data?) -> Void

public final class Interceptor: NSObject {
    
    // MARK: - Public
    public static var uiTestingEnabled = false {
        didSet {
            mocker.uiTestingEnabled = uiTestingEnabled
        }
    }
    public static var ignoredHosts: [String] = [] {
        didSet {
            logger.ignoredHosts = ignoredHosts
        }
    }
    public static var logBodyModifier: BodyModifier = LogModifier() {
        didSet {
            logger.bodyModifier = logBodyModifier
        }
    }
    public static var stubResponseHandler: StubResponseHandler? {
        didSet {
            stubber.stubResponseHandler = stubResponseHandler
        }
    }
    
    public static var onResponse: OnResponse?
    
    // MARK: - Internal
    static let logger = InterceptorLogger()
    static let stubber = InterceptorStubber()
    static let mocker = InterceptorMocker()
    static let port = "8888"
    
    @objc public static func configure() {
        let environment = ProcessInfo.processInfo.environment
        uiTestingEnabled = environment["INTERCEPTOR_UITESTING_ENABLED"] == "1"
        enable(true)
    }
    
    @objc public static func enable(_ enable: Bool) {
        if enable {
            URLSessionConfiguration.registerStubby()
            URLProtocol.registerClass(ProxyProtocol.self)
        } else {
            URLSessionConfiguration.unregisterStubby()
            URLProtocol.unregisterClass(ProxyProtocol.self)
        }
    }
    
    public static func mock(_ mock: Mockable) {
        mocker.mock(mock)
    }
}
