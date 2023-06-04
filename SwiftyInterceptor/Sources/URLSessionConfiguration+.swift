//
//  URLSessionConfiguration+.swift
//  Interceptor
//
//  Created by Chittapon Thongchim on 25/5/2566 BE.
//

import Foundation

extension URLSessionConfiguration {
    
    static var isSwizzled: Bool = false
    
    static var interceptorDefault: URLSessionConfiguration {
        isSwizzled ? interceptor_default() : .default
    }
    
    class func toggleSwizzle() {
        let defaultSelector = #selector(getter: self.default)
        let defaultStubbySelector = #selector(self.interceptor_default)
        let ephemeralSelector = #selector(getter: self.ephemeral)
        let ephemeralStubbySelector = #selector(self.interceptor_ephemeral)
        if isSwizzled {
            isSwizzled = false
            exchange(defaultStubbySelector, with: defaultSelector)
            exchange(ephemeralStubbySelector, with: ephemeralSelector)
        } else {
            isSwizzled = true
            exchange(defaultSelector, with: defaultStubbySelector)
            exchange(ephemeralSelector, with: ephemeralStubbySelector)
        }
    }
    
    class func registerStubby() {
        if !isSwizzled {
            toggleSwizzle()
        }
    }
    
    class func unregisterStubby() {
        if isSwizzled {
            toggleSwizzle()
        }
    }
    
    func registerClass(_ protocolClass: AnyClass) {
        protocolClasses?.insert(protocolClass, at: 0)
    }
    
    @objc class func interceptor_default() -> URLSessionConfiguration {
        let configuration = interceptor_default()
        configuration.registerClass(ProxyProtocol.self)
        return configuration
    }
    
    @objc class func interceptor_ephemeral() -> URLSessionConfiguration {
        let configuration = interceptor_ephemeral()
        configuration.registerClass(ProxyProtocol.self)
        return configuration
    }
    
    class func exchange(_ selector: Selector, with replacementSelector: Selector) {
        if let method = class_getClassMethod(self, selector),
            let replacementMethod = class_getClassMethod(self, replacementSelector) {
            method_exchangeImplementations(method, replacementMethod)
        }
    }

}
